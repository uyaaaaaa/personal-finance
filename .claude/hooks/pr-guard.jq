def signature: test("^[\\s_🤖]*Generated (?:with|by) \\[Claude Code\\]|^\\s*https://claude\\.ai/code/session_|^\\s*Co-Authored-By:.*Claude|^\\s*Claude-Session:");
def filler: test("^\\s*(?:[-*_]{3,})?\\s*$");

def unsigned:
	split("\n") as $lines
	| (reduce range(($lines | length) - 1; -1; -1) as $at ({top: ($lines | length), done: false};
		if .done then .
		elif $lines[$at] | signature then .top = $at
		elif $lines[$at] | filler then .
		else .done = true end) | .top) as $top
	| if $top == ($lines | length) then null
	else
		($top | until(. == 0 or ($lines[. - 1] | filler | not); . - 1)) as $cut
		| $lines[:$cut] | join("\n") | sub("\\s+$"; "")
	end;

.tool_input.body | strings | unsigned | select(. != null)
