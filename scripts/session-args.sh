#!/bin/sh
set -u

usage() {
	[ $# -gt 0 ] && printf '%s\n\n' "$@" >&2
	cat >&2 <<'USAGE'
使い方:
  sh scripts/session-args.sh issue <番号>
  sh scripts/session-args.sh task <スラッグ> <プロンプト>

出力の JSON をそのまま create_session に渡す。
USAGE
	exit 1
}

tail=${SESSION_SUFFIX:-$(LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 6)}
kind=${1:-}
[ $# -gt 0 ] && shift

case $kind in
issue)
	[ $# -eq 1 ] && printf '%s' "$1" | grep -Eq '^[1-9][0-9]*$' || usage 'issue に渡すのは番号1つだけ。'
	title="issue #$1"
	branch="claude/issue-$1-$tail"
	body="#$1 に対応して PR を出す。"
	;;
task)
	slug=${1:-}
	printf '%s' "$slug" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$' || usage 'スラッグは英小文字・数字・ハイフンで書く。'
	case $slug in issue-*) usage 'issue- で始まるスラッグは、issue のブランチと見分けが付かない。' ;; esac
	shift
	body=$(printf '%s\n' "$@")
	[ -n "$(printf '%s' "$body" | tr -d '[:space:]')" ] || usage 'プロンプトが空。'
	title=$slug
	branch="claude/$slug-$tail"
	;;
*) usage ;;
esac

jq -n --arg title "$title" --arg prompt "$(printf '%s\n作業ブランチは %s にする。\n答えを待てる相手はいない。' "$body" "$branch")" \
	'{source_url: "https://github.com/uyaaaaaa/personal-finance", title: $title, prompt: $prompt}'
