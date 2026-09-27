def rules:
	([scan("(?m)^\\|\\s*`([a-z]+)`\\s*\\|[^|]*\\|\\s*`(!\\[[^\\]]*\\]\\([^)]*\\))`\\s*\\|") | {key: .[0], value: .[1]}] | from_entries) as $grades
	| {
		grades: $grades,
		order: [scan("(?m)^\\|\\s*`([a-z]+)`\\s*\\|[^|]*\\|\\s*`!\\[") | .[0]],
		judgments: [scan("(?m)^\\|\\s*`([A-Za-z][A-Za-z ]*)`\\s*\\|\\s*([^|]+?)\\s*\\|\\s*$")
			| select($grades[.[0]] == null)
			| {name: .[0], needs: [.[1] | scan("`([a-z]+)`\\s*が(\\d+)件(以上)?") | {grade: .[0], count: (.[1] | tonumber), orMore: (.[2] != null)}]}],
		total: ((capture("合計(?<n>\\d+)件まで").n | tonumber) // null),
		soft: ((capture("うち(?<g>(?:\\s*`[a-z]+`\\s*(?:と\\s*)?)+)は合わせて\\d+件まで").g | [scan("`([a-z]+)`") | .[0]]) // []),
		softTotal: ((capture("は合わせて(?<n>\\d+)件まで").n | tonumber) // null),
		lines: ((capture("合わせて(?<n>\\d+)行以内").n | tonumber) // null),
		bodyLines: ((capture("\\|\\s*本文\\s*\\|\\s*(?<n>\\d+)行以内").n | tonumber) // null)
	};

def complete:
	(.grades | length) > 0
	and (.judgments | length) > 0
	and any(.judgments[]; .needs == [])
	and ([.total, .softTotal, .lines, .bodyLines] | all(type == "number"))
	and (.soft | length) > 0;

def text: if type == "string" then gsub("^\\s+|\\s+$"; "") else "" end;
def rows: text | split("\n") | map(select(test("^\\s*$") | not));
def prose:
	reduce .[] as $line ({inside: false, kept: []};
		if $line | test("^\\s*```") then .inside |= not
		elif .inside then .
		else .kept += [$line] end) | .kept;

def counted($it): . as $comments | [$it.order[] as $g | {key: $g, value: ([$comments[] | select(.grade? == $g)] | length)} | select(.value > 0)] | from_entries;

def verdict($it):
	counted($it) as $counts
	| (first($it.judgments[] | select(.needs != [] and all(.needs[]; if .orMore then ($counts[.grade] // 0) >= .count else ($counts[.grade] // 0) == .count end)))
		// first($it.judgments[] | select(.needs == [])));

def in_comment($at; $it):
	"\($at + 1)件目" as $where
	| if type != "object" then "\($where): 指摘は { grade, path, line, heading, body } で渡す"
	else
		(if $it.grades[.grade | strings] == null then "\($where): 型に無いグレード（\($it.order | join(" / ")) から1つ）" else empty end),
		(if (.path | text) == "" then "\($where): path が無い" else empty end),
		(if (.line | type) != "number" or .line != (.line | floor) or .line < 1 then "\($where): line は差分に付く行番号で渡す" else empty end),
		(if (.heading | text) == "" then "\($where): 見出しが無い" else empty end),
		((.body | rows) as $body
			| (if ($body | length) == 0 then "\($where): 本文が無い"
			elif ($body | prose | length) > $it.bodyLines then "\($where): 本文が \($body | prose | length) 行（\($it.bodyLines)行以内）"
			else empty end),
			(if ($body | length) + 1 > $it.lines then "\($where): コメントが \(($body | length) + 1) 行（\($it.lines)行以内）" else empty end))
	end;

def findings($it):
	(.comments | if type == "array" then . else [] end) as $comments
	| ($comments | counted($it)) as $counts
	| (if (.comments | type) != "array" then "comments は配列で渡す（0件なら空配列）" else empty end),
	(if ($comments | length) > $it.total then "指摘が \($comments | length) 件（合計\($it.total)件まで）" else empty end),
	([$it.soft[] as $g | $counts[$g] // 0] | add) as $soft
	| (if $soft > $it.softTotal then "\($it.soft | join(" と ")) が \($soft) 件（合わせて\($it.softTotal)件まで）" else empty end),
	(range(0; $comments | length) as $at | $comments[$at] | in_comment($at; $it)),
	(if ($comments | verdict($it) | .needs) != [] then
		(if (.reason | text) == "" then "判定の理由1文を reason に入れる" else empty end),
		(if (.verified | text) == "" then "実測の状態を verified に入れる" else empty end)
	else empty end);

def args($it):
	(.comments | verdict($it)) as $chosen
	| (.comments | counted($it)) as $counts
	| {event: ($chosen.name | ascii_upcase | gsub("\\s+"; "_"))}
	+ (if $chosen.needs != [] then {body: ([
		"**判定: \($chosen.name)** — \(.reason | text)",
		"",
		"- \($counts | to_entries | map("\(.key) \(.value)") | join(" / "))",
		"- 実測: \(.verified | text)"
	] | join("\n"))} else {} end)
	+ (if (.comments | length) > 0 then {comments: [.comments[] | {path: (.path | text), line, body: "\($it.grades[.grade]) **\(.heading | text)**\n\n\(.body | text)"}]} else {} end);
