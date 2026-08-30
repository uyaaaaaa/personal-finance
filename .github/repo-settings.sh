#!/bin/sh
# 設定の正はこのスクリプトと ruleset-main.json であり、GitHub の管理画面ではない。
set -eu

repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
dir=$(dirname "$0")

# main の履歴を 1 PR = 1 コミットに保つ。squash コミットの件名と本文は PR から生成し、
# commit-msg hook が検証した件名が main の履歴に残るようにする。
gh api -X PATCH "repos/$repo" \
  -F allow_squash_merge=true \
  -F allow_merge_commit=false \
  -F allow_rebase_merge=false \
  -F delete_branch_on_merge=true \
  -f squash_merge_commit_title=PR_TITLE \
  -f squash_merge_commit_message=PR_BODY \
  --silent

# ruleset は名前ではなく ID で識別されるため、再実行時は同名のものを引いて置き換える。
id=$(gh api "repos/$repo/rulesets" --jq 'map(select(.name == "main")) | .[0].id // ""')
if [ -n "$id" ]; then
  gh api -X PUT "repos/$repo/rulesets/$id" --input "$dir/ruleset-main.json" --silent
else
  gh api -X POST "repos/$repo/rulesets" --input "$dir/ruleset-main.json" --silent
fi

echo "applied: $repo"
