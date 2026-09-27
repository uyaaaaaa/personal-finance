#!/bin/sh
. "$(dirname "$0")/lib.sh"

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // ""' 2>/dev/null) || exit 0

blocking() {
	branch=$(git -C "$root" rev-parse --abbrev-ref HEAD 2>/dev/null)
	if [ -z "$branch" ]; then
		echo 'HEAD のブランチ名を読めない'
		return
	fi
	if [ "$branch" = main ] || [ "$branch" = HEAD ]; then
		echo 'main から PR は出せない。claude/<主題>-<英数字4〜6> のブランチに移す'
		return
	fi
	head=$(printf '%s' "$input" | jq -r '.tool_input.head | strings')
	if [ -n "$head" ] && [ "$head" != "$branch" ]; then
		echo "head が $head で、出す前の条件を測る作業ツリー（$branch）と違う"
		return
	fi
	if ! dirty=$(git -C "$root" status --short 2>/dev/null); then
		echo 'git status を読めない'
		return
	fi
	if [ -n "$dirty" ]; then
		printf 'コミットしていない変更が残っている:\n%s\n' "$dirty"
		return
	fi
	if ! git -C "$root" rev-parse --verify --quiet "refs/remotes/origin/$branch" >/dev/null; then
		echo "push していない: origin/$branch が無い"
		return
	fi
	ahead=$(git -C "$root" rev-list --count "refs/remotes/origin/$branch..HEAD")
	[ "$ahead" = 0 ] || echo "push していない: origin/$branch より $ahead コミット先"
}

case $tool in
mcp__github__create_pull_request)
	reason=$(blocking)
	if [ -n "$reason" ]; then
		deny "$reason"
		exit 0
	fi
	;;
mcp__github__update_pull_request) ;;
*) exit 0 ;;
esac

body=$(printf '%s' "$input" | jq -r -f "$(dirname "$0")/pr-guard.jq" 2>/dev/null) || exit 0
[ -n "$body" ] || exit 0
printf '%s' "$input" | jq --arg body "$body" '{hookSpecificOutput: {hookEventName: "PreToolUse", updatedInput: (.tool_input + {body: $body})}, systemMessage: "本文の署名を落とした"}'
