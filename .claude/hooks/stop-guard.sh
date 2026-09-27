#!/bin/sh
. "$(dirname "$0")/lib.sh"

input=$(cat)
printf '%s' "$input" | jq -e '.hook_event_name == "Stop" and (.agent_id | not)' >/dev/null 2>&1 || exit 0
session=$(printf '%s' "$input" | jq -r '.session_id // "none"')
blocked=$(state_file "$session" stop-guard)

cd "$root" || exit 0
dirty=$(git status --porcelain 2>/dev/null)
ahead=$(git rev-list --count HEAD --not --remotes 2>/dev/null || echo 0)

block() {
	grep -qx "$1" "$blocked" 2>/dev/null && return 1
	echo "$1" >> "$blocked"
	jq -n --arg reason "$2" '{decision: "block", reason: $reason}'
}

if [ -n "$dirty" ]; then
	block commit 'コミットしていない変更がある。コンテナが消えると失われる' && exit 0
fi
if [ "$ahead" -gt 0 ]; then
	block push "push していないコミットが $ahead 件ある。コンテナが消えると失われる"
fi
exit 0
