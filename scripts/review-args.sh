#!/bin/sh
set -u

dir=$(cd "$(dirname "$0")" && pwd)
skill="$(dirname "$dir")/.claude/skills/review"

fail() {
	printf '%s\n' "$@" >&2
	cat >&2 <<'USAGE'

使い方: sh scripts/review-args.sh findings.json（省くと標準入力）

渡す JSON:
  { "reason": "判定の理由1文",
    "verified": "CI の check は緑",
    "comments": [
      { "grade": "must", "path": "server/src/x.ts", "line": 12,
        "heading": "日付の境界が UTC になる", "body": "理由。\n代案。" }
    ] }

判定・バッジ・件数の上限は review スキルから読む。
出力の JSON が PR に投稿するレビュー。REVIEW_OUT があれば、そのファイルにも書く。
USAGE
	exit 1
}

review=$(cat "${1:-/dev/stdin}" 2>/dev/null) || fail 'レビューの JSON を読めない'
printf '%s' "$review" | jq -e 'type == "object"' >/dev/null 2>&1 || fail 'レビューの JSON を標準入力に渡す'

it=$(cat "$skill/SKILL.md" "$skill"/references/*.md 2>/dev/null | jq -Rs -L "$dir" 'include "review-args"; rules')
printf '%s' "$it" | jq -e -L "$dir" 'include "review-args"; complete' >/dev/null 2>&1 || fail "判定とグレードを .claude/skills/review から読めない"

found=$(printf '%s' "$review" | jq -r -L "$dir" --argjson it "$it" 'include "review-args"; findings($it)')
[ -z "$found" ] || fail "$found"

out=$(printf '%s' "$review" | jq -L "$dir" --argjson it "$it" 'include "review-args"; args($it)')
[ -n "${REVIEW_OUT:-}" ] && printf '%s\n' "$out" > "$REVIEW_OUT"
printf '%s\n' "$out"
