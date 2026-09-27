. "$(dirname "$0")/../assert.sh"

review() {
	printf '%s' "$1" | sh "$root/scripts/review-args.sh" 2>/dev/null
}

[ "$(review '{"reason":"r","verified":"v","comments":[{"grade":"must","path":"a","line":1,"heading":"h","body":"b"}]}' | jq -r .event)" = REQUEST_CHANGES ] || fail 'must があれば Request changes'
review '{"comments":[{"grade":"imo","path":"a","line":1,"heading":"h","body":"b"},{"grade":"nits","path":"a","line":1,"heading":"h","body":"b"},{"grade":"nits","path":"a","line":1,"heading":"h","body":"b"}]}' >/dev/null && fail 'imo と nits の上限を超えたら落とす'

finish
