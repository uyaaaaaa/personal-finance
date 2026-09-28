. "$(dirname "$0")/../assert.sh"

denies '型に合わない issue' issue-guard.sh '{"tool_name":"mcp__github__issue_write","tool_input":{"method":"create","title":"fix: 合計","labels":["bug"],"body":"## ゴール\n- a"}}'
passes '型に合う issue' issue-guard.sh '{"tool_name":"mcp__github__issue_write","tool_input":{"method":"create","title":"合計が合う","labels":["bug"],"body":"## ゴール\n- a\n## 現状\n- b\n## 完了条件\n- [ ] c"}}'

finish
