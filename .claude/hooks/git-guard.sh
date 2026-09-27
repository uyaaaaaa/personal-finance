#!/bin/sh
. "$(dirname "$0")/lib.sh"

head=$(git -C "$root" rev-parse --abbrev-ref HEAD 2>/dev/null)
found=$(jq -r -L "$(dirname "$0")" --arg head "$head" -f "$(dirname "$0")/git-guard.jq" 2>/dev/null) || exit 0

printf '%s\n' "$found" | while IFS="$(printf '\t')" read -r kind first second; do
	case $kind in
	deny)
		deny "$first"
		exit 1
		;;
	force)
		git -C "$root" merge-base --is-ancestor "refs/remotes/$first/$second" "refs/remotes/$first/main" 2>/dev/null && continue
		deny "force push は他の checkout を壊す。$first/$second は main に入りきっていない"
		exit 1
		;;
	esac
done
exit 0
