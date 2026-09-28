def form:
	(.structure | split("\n") | map(select(. != "") | split("\t"))) as $rows
	| .prose as $prose
	| ([$rows[] | select(.[0] == "field" and .[1] != "markdown")]) as $inputs
	| {
		kind: (first($rows[] | select(.[0] == "kind") | .[1]) // null),
		sections: [$inputs[] | {name: .[2], required: (.[3] == "true"), checklist: (.[4] == "true")}],
		length: (($prose | capture("本文(?<n>\\d+)行以内").n | tonumber) // null),
		items: (($prose | capture("1節(?<n>\\d+)項目以内").n | tonumber) // null),
		oneLine: ($prose | test("1項目1行")),
		unprefixed: ($prose | test("接頭辞は付けない"))
	};

def complete:
	length > 0 and all(.[];
		(.kind | type) == "string"
		and any(.sections[]; .required)
		and any(.sections[]; .checklist)
		and (.length | type) == "number"
		and (.items | type) == "number");

def item: test("^\\s*[-*]\\s+");

def split_sections($names):
	reduce .[] as $line ({sections: [], outside: 0};
		($line | capture("^#{2,3}\\s+(?<h>\\S.*?)\\s*$") // null) as $heading
		| if $heading == null then
			if (.sections | length) == 0 then .outside += (if ($line | gsub("\\s"; "")) == "" then 0 else 1 end)
			else .sections[-1].lines += [$line] end
		else
			.sections += [{heading: $heading.h, name: (first($names[] as $n | select($heading.h | startswith($n)) | $n) // null), lines: []}]
		end);

def spanned:
	reduce .[] as $line ({item: false, found: false};
		if .found then .
		elif ($line | gsub("\\s"; "")) == "" then .item = false
		elif $line | item then .item = true
		elif .item then .found = true
		else . end) | .found;

def in_section($it):
	.name as $name
	| [.lines[] | select(item)] as $items
	| first($it.sections[] | select(.name == $name)) as $spec
	| (if ($items | length) > $it.items then "## \($name) が \($items | length) 項目（1節\($it.items)項目以内）" else empty end),
	(if $spec.checklist and (($items | length) == 0 or any($items[]; test("^\\s*[-*]\\s+\\[[ xX]\\]\\s+") | not)) then "## \($name) を - [ ] のチェックリストで書く" else empty end),
	(if $it.oneLine and (.lines | spanned) then "## \($name) の項目が2行にまたがっている" else empty end);

def shaped($it):
	(sub("\\s+$"; "") | split("\n")) as $lines
	| [$it.sections[].name] as $names
	| ($lines | split_sections($names)) as $split
	| [$split.sections[] | select(.name != null) | .name] as $written
	| (if ($lines | length) > $it.length then "本文が \($lines | length) 行（\($it.length)行以内）" else empty end),
	(if $split.outside > 0 then "節の見出しの外に本文がある" else empty end),
	($split.sections[] | select(.name == null) | "型に無い節: ## \(.heading)"),
	($it.sections[] | select(.required and (.name | IN($written[]) | not)) | "## \(.name) が無い"),
	($written | unique[] as $n | select([$written[] | select(. == $n)] | length > 1) | "## \($n) が2つある"),
	(if $written != [$names[] | select(IN($written[]))] then "節は \($names | join(" → ")) の順に並べる" else empty end),
	($split.sections[] | select(.name != null) | in_section($it));

def findings($forms):
	[(.labels // [])[] | if type == "string" then . else .name end | strings] as $names
	| (first($forms[] | select(.kind | IN($names[]))) // $forms[0]) as $it
	| (.title | strings // "") as $title
	| (if $it.unprefixed and ($title | test("^(?:\\[[^\\]]+\\]|[A-Za-z][\\w .-]*(?:\\([^)]*\\))?\\s*[:：])")) then "タイトルに分類の接頭辞が付いている" else empty end),
	([$forms[].kind] as $all
		| [$names[] | select(IN($all[]))] as $kinds
		| if ($kinds | length) == 1 then empty
		else "ラベルは \($all | join(" / ")) から1つ（\(if ($kinds | length) == 0 then "今はなし" else "今は \($kinds | join(" / "))" end)）" end),
	(.body | strings // "" | shaped($it));
