#!/bin/sh
. "$(dirname "$0")/lib.sh"

input=$(cat)
printf '%s' "$input" | jq -e '.tool_name == "mcp__github__issue_write" and .tool_input.method == "create"' >/dev/null 2>&1 || exit 0
found=$(printf '%s' "$input" | jq '.tool_input | {title, body, labels}' | sh "$root/scripts/issue-shape.sh" --issue 2>/dev/null) || exit 0
[ -n "$found" ] || exit 0
deny "$(printf 'issue が型に合わない（→ .github/ISSUE_TEMPLATE/）:\n%s' "$(printf '%s\n' "$found" | sed 's/^/- /')")"
