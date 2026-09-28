root=$(cd "$(dirname "$0")/../.." && pwd)
export CLAUDE_PROJECT_DIR="$root"
CLAUDE_HOOK_STATE_DIR=$(mktemp -d)
export CLAUDE_HOOK_STATE_DIR
trap 'rm -rf "$CLAUDE_HOOK_STATE_DIR"' EXIT
failed=0

fail() {
	echo "FAIL $(basename "$0"): $1" >&2
	failed=1
}

denies() {
	name=$1 hook=$2 input=$3
	printf '%s' "$input" | sh "$root/.claude/hooks/$hook" | jq -e '.hookSpecificOutput.permissionDecision == "deny" or .decision == "block"' >/dev/null 2>&1 || fail "$name"
}

passes() {
	name=$1 hook=$2 input=$3
	[ -z "$(printf '%s' "$input" | sh "$root/.claude/hooks/$hook")" ] || fail "$name"
}

bash_input() {
	jq -n --arg command "$1" '{tool_name: "Bash", tool_input: {command: $command}}'
}

finish() {
	exit "$failed"
}
