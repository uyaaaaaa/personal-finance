. "$(dirname "$0")/../assert.sh"

denies 'main への push' git-guard.sh "$(bash_input 'git push origin main')"
denies '規約外のブランチ' git-guard.sh "$(bash_input 'git status && git checkout -b feature/x')"
denies 'オプションを挟んだ rebase' git-guard.sh "$(bash_input 'git -C . rebase main')"
denies 'amend' git-guard.sh "$(bash_input 'git commit --amend')"
denies 'マージ' git-guard.sh '{"tool_name":"mcp__github__merge_pull_request","tool_input":{}}'
passes '規約どおりのブランチ' git-guard.sh "$(bash_input 'git push -u origin claude/fix-sum-a1b2c3')"
passes '引用とヒアドキュメントの中' git-guard.sh "$(bash_input "git commit -m 'git rebase' && cat <<EOF
git push origin main
EOF")"
passes '判定できない入力' git-guard.sh 'not json'

finish
