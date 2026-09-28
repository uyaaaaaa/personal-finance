#!/bin/sh
. "$(dirname "$0")/lib.sh"

input=$(cat)
event=$(printf '%s' "$input" | jq -r '.hook_event_name // ""' 2>/dev/null) || exit 0
count=$(state_file "$(printf '%s' "$input" | jq -r '.session_id // "none"')" dispatch)

if [ "$event" = UserPromptSubmit ]; then
	echo 0 > "$count"
	exit 0
fi

printf '%s' "$input" | jq -e '.tool_name // "" | test("^mcp__.+__create_session$")' >/dev/null 2>&1 || exit 0
max=$(sed -n 's/.*最大\([0-9][0-9]*\)本.*/\1/p' "$root/.claude/skills/dispatch/SKILL.md" 2>/dev/null | head -n 1)
[ -n "$max" ] || exit 0
held=$(cat "$count" 2>/dev/null || echo 0)

if [ "$event" = PostToolUse ]; then
	printf '%s' "$input" | jq -e '.tool_response.isError or .tool_response.is_error' >/dev/null 2>&1 && exit 0
	echo $((held + 1)) > "$count"
	exit 0
fi

script=scripts/session-args.sh
given=$(printf '%s' "$input" | jq -c '.tool_input // {}')
if ! printf '%s' "$given" | jq -e '(.title | type) == "string" and (.prompt | type) == "string"' >/dev/null; then
	deny "title と prompt が無い。sh $script <種類> の出力をそのまま渡す"
	exit 0
fi

title=$(printf '%s' "$given" | jq -r .title)
prompt=$(printf '%s' "$given" | jq -r .prompt)
branch=$(printf '%s\n' "$prompt" | sed -n 's/^作業ブランチは \([^ ]*\) にする。$/\1/p' | head -n 1)
tail=${branch##*-}
if [ -n "$branch" ] && ! printf '%s' "$tail" | grep -Eq '^[a-z0-9]{6}$'; then
	deny "ブランチ名の接尾辞が $script の形と違う: $branch"
	exit 0
fi

number=$(printf '%s' "$title" | sed -n 's/^issue #\([1-9][0-9]*\)$/\1/p')
if [ -n "$number" ]; then
	want=$(SESSION_SUFFIX=$tail sh "$root/$script" issue "$number" 2>/dev/null)
else
	body=$(printf '%s\n' "$prompt" | grep -v '^作業ブランチは .* にする。$' | sed '$d')
	want=$(SESSION_SUFFIX=$tail sh "$root/$script" task "$title" "$body" 2>/dev/null)
fi

differs=$(jq -rn --argjson given "$given" --argjson want "${want:-null}" \
	'if $want == null then $given | keys | join(" / ") else [($given + $want) | keys[] | select($given[.] != $want[.])] | join(" / ") end')
if [ -n "$differs" ]; then
	deny "$script の出力と違う（$differs）。出力を書き換えずに渡す"
	exit 0
fi

[ "$held" -ge "$max" ] && deny "この発火で既に $held 本起こしている。1回の発火に最大${max}本"
exit 0
