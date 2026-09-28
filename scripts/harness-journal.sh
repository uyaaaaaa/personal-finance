#!/bin/sh
set -u

journal=harness/journal
ledger=harness/ledger

usage() {
	[ $# -gt 0 ] && printf '%s\n\n' "$@" >&2
	cat >&2 <<'USAGE'
使い方:
  sh scripts/harness-journal.sh append <PR番号>   # 本文は標準入力
  sh scripts/harness-journal.sh pending
  sh scripts/harness-journal.sh ledger
  sh scripts/harness-journal.sh save <journalのSHA>  # 台帳は標準入力
USAGE
	exit 1
}

head_of() {
	git fetch --quiet origin "refs/heads/$1" 2>/dev/null || return 1
	git rev-parse FETCH_HEAD
}

stdin() {
	body=$(cat)
	[ -n "$(printf '%s' "$body" | tr -d '[:space:]')" ] || usage '本文が空。標準入力から渡す。'
	printf '%s\n' "$body"
}

commit_files() {
	branch=$1 message=$2
	shift 2
	attempt=0
	while :; do
		parent=$(head_of "$branch") || parent=
		index=$(mktemp)
		rm -f "$index"
		if (
			export GIT_INDEX_FILE="$index"
			if [ -n "$parent" ]; then git read-tree "$parent"; else git read-tree --empty; fi
			while [ $# -gt 0 ]; do
				blob=$(git hash-object -w "$2") && git update-index --add --cacheinfo "100644,$blob,$1" || exit 1
				shift 2
			done
			tree=$(git write-tree)
			commit=$(git commit-tree "$tree" ${parent:+-p "$parent"} -m "$message")
			git push --quiet origin "$commit:refs/heads/$branch"
		); then
			rm -f "$index"
			return 0
		fi
		rm -f "$index"
		attempt=$((attempt + 1))
		[ "$attempt" -lt 3 ] || return 1
	done
}

consumed_journal() {
	at=$(head_of "$ledger") || return 0
	git cat-file -p "$at:state.json" 2>/dev/null | jq -r '.journal // empty'
}

command=${1:-}
[ $# -gt 0 ] && shift
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

case $command in
append)
	[ $# -eq 1 ] && printf '%s' "$1" | grep -Eq '^[1-9][0-9]*$' || usage 'append に渡すのは PR の番号1つだけ。'
	stdin > "$work/body" || exit 1
	path="$(date -u +%Y/%m/%d)/$(date -u +%H%M%S)-pr$1.md"
	commit_files "$journal" "PR #$1 で受けた指摘を書き留める" "$path" "$work/body" || exit 1
	echo "$path"
	;;
pending)
	[ $# -eq 0 ] || usage 'pending に引数は無い。'
	at=$(head_of "$journal") || exit 0
	seen=$(consumed_journal)
	git ls-tree -r --name-only "$at" | sort > "$work/all"
	if [ -n "$seen" ]; then git ls-tree -r --name-only "$seen" | sort > "$work/seen"; else : > "$work/seen"; fi
	comm -23 "$work/all" "$work/seen" > "$work/new"
	[ -s "$work/new" ] || exit 0
	echo "journal: $at"
	while IFS= read -r path; do
		printf '\n## %s\n\n' "$path"
		git cat-file -p "$at:$path"
	done < "$work/new"
	;;
ledger)
	[ $# -eq 0 ] || usage 'ledger に引数は無い。'
	at=$(head_of "$ledger") || exit 0
	git cat-file -p "$at:LEDGER.md" 2>/dev/null
	exit 0
	;;
save)
	[ $# -eq 1 ] && printf '%s' "$1" | grep -Eq '^[0-9a-f]{7,40}$' || usage 'save に渡すのは pending が出した journal の SHA1つだけ。'
	stdin > "$work/ledger" || exit 1
	jq -n --arg journal "$1" '{journal: $journal}' > "$work/state"
	commit_files "$ledger" '台帳を畳み直す' LEDGER.md "$work/ledger" state.json "$work/state" || exit 1
	echo "$1"
	;;
*) usage ;;
esac
