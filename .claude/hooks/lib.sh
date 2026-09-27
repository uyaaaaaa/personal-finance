root=${CLAUDE_PROJECT_DIR:-$(pwd)}

deny() {
	jq -n --arg reason "$1" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
}

state_file() {
	dir=${CLAUDE_HOOK_STATE_DIR:-${TMPDIR:-/tmp}/claude-hook-state}
	mkdir -p "$dir"
	printf '%s/%s.%s' "$dir" "$(printf '%s' "$1" | tr -c 'A-Za-z0-9_-' _)" "$2"
}
