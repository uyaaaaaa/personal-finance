. "$(dirname "$0")/../assert.sh"

signed=$(jq -n '{tool_name: "mcp__github__update_pull_request", tool_input: {body: "## やったこと\n\n- a\n\n---\n🤖 Generated with [Claude Code](https://claude.com/claude-code)\n\nhttps://claude.ai/code/session_x"}}')
[ "$(printf '%s' "$signed" | sh "$root/.claude/hooks/pr-guard.sh" | jq -r .hookSpecificOutput.updatedInput.body)" = "$(printf '## やったこと\n\n- a')" ] || fail '署名を落とす'
passes '署名の無い本文' pr-guard.sh '{"tool_name":"mcp__github__update_pull_request","tool_input":{"body":"a\n---\nb"}}'

finish
