. "$(dirname "$0")/../assert.sh"

start() {
	jq -n --arg event "$1" --argjson input "$2" '{hook_event_name: $event, session_id: "s", tool_name: "mcp__Claude_Code_Remote__create_session", tool_input: $input}'
}

args=$(sh "$root/scripts/session-args.sh" issue 12)
passes 'スクリプトの出力そのまま' dispatch-guard.sh "$(start PreToolUse "$args")"
denies '書き換えた引数' dispatch-guard.sh "$(start PreToolUse "$(printf '%s' "$args" | jq '.title = "12"')")"

max=$(sed -n 's/.*最大\([0-9][0-9]*\)本.*/\1/p' "$root/.claude/skills/dispatch/SKILL.md" | head -n 1)
for _ in $(seq "$max"); do start PostToolUse "$args" | sh "$root/.claude/hooks/dispatch-guard.sh"; done
denies '上限を超えた本数' dispatch-guard.sh "$(start PreToolUse "$args")"

finish
