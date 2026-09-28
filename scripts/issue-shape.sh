#!/bin/sh
set -u

dir=$(cd "$(dirname "$0")" && pwd)
root=$(dirname "$dir")
templates="$root/.github/ISSUE_TEMPLATE"

forms() {
	for file in "$templates"/*.yml; do
		case $(basename "$file") in config.yml) continue ;; esac
		jq -n --rawfile prose "$file" --arg structure "$(awk -f "$dir/issue-forms.awk" "$file")" '{prose: $prose, structure: $structure}'
	done | jq -s -L "$dir" 'include "issue-shape"; map(form)'
}

if ! it=$(forms 2>/dev/null) || ! printf '%s' "$it" | jq -e -L "$dir" 'include "issue-shape"; complete' >/dev/null 2>&1; then
	echo "型を .github/ISSUE_TEMPLATE/ から読めない" >&2
	exit 1
fi

case ${1:-} in
--issue)
	jq -r -L "$dir" --argjson forms "$it" 'include "issue-shape"; findings($forms)'
	exit 0
	;;
esac

if ! issues=$(jq -c 'if type == "array" then .[] elif type == "object" then . else error end' 2>/dev/null); then
	echo "issue の JSON を標準入力に渡す（1件でも配列でもよい）" >&2
	echo "使い方: sh scripts/issue-shape.sh < issues.json" >&2
	exit 1
fi

dropped=0
printf '%s\n' "$issues" | {
	while IFS= read -r issue; do
		where="#$(printf '%s' "$issue" | jq -r '.number // "?"')"
		found=$(printf '%s' "$issue" | jq -r -L "$dir" --argjson forms "$it" 'include "issue-shape"; findings($forms)')
		if [ -z "$found" ]; then
			echo "$where 型に合う"
			continue
		fi
		dropped=$((dropped + 1))
		echo "$where 落とす:"
		printf '%s\n' "$found" | sed 's/^/  /'
	done
	[ "$dropped" -eq 0 ]
}
