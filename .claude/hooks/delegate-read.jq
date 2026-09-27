def opaque: test("\\.(png|jpe?g|gif|webp|bmp|ico|svg|pdf|woff2?|ttf|otf|mp4|zip|gz)$"; "i");
def unquote: sub("^[\"'](?<v>.*)[\"']$"; "\(.v)");

if .agent_id then empty
elif .tool_name == "Read" then
	.tool_input | select(.offset == null and .limit == null) | .file_path | strings
elif .tool_name == "Bash" then
	.tool_input.command | strings
	| capture("^\\s*cat\\s+(?:--\\s+)?(?<p>\"[^\"]+\"|'[^']+'|[^-\\s'\"|;&<>()$`][^\\s'\"|;&<>()$`]*)\\s*$")
	| .p | unquote
else empty end
| select(opaque | not)
