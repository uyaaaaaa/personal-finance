function flush() {
	if (type != "") printf "field\t%s\t%s\t%s\t%s\n", type, name, required, checklist
	type = ""; name = ""; required = "false"; checklist = "false"
}
function scalar(line) {
	sub(/^[^:]*:[ \t]*/, "", line)
	gsub(/^['"]|['"][ \t]*$/, "", line)
	return line
}
/^labels:/ { line = $0; sub(/^labels:[ \t]*\[?[ \t]*/, "", line); sub(/[,\]].*$/, "", line); printf "kind\t%s\n", line; next }
/^[ \t]*- type:/ { flush(); type = scalar($0); next }
/^[ \t]*label:/ { name = scalar($0); next }
/^[ \t]*required:[ \t]*true/ { required = "true"; next }
/^[ \t]*value:[ \t]*['"]?-[ \t]+\[ \]/ { checklist = "true"; next }
END { flush() }
