#!/bin/sh
. "$(dirname "$0")/lib.sh"

min=${CLAUDE_DELEGATE_READ_MIN_BYTES:-16000}
target=$(jq -r -f "$(dirname "$0")/delegate-read.jq" 2>/dev/null) || exit 0
[ -n "$target" ] && [ -f "$target" ] || exit 0
bytes=$(wc -c < "$target" | tr -d ' ')
[ "$bytes" -ge "$min" ] || exit 0
deny "$bytes バイト。Agent(subagent_type: \"read\") に聞く。原文が要るなら Read に offset / limit を付ける。"
