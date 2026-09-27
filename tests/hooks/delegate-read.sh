. "$(dirname "$0")/../assert.sh"

big=$(mktemp)
head -c 20000 /dev/zero > "$big"
denies '大きいファイルの素の cat' delegate-read.sh "$(bash_input "cat $big")"
passes '範囲を絞った Read' delegate-read.sh "$(jq -n --arg path "$big" '{tool_name: "Read", tool_input: {file_path: $path, offset: 1, limit: 10}}')"
rm -f "$big"

finish
