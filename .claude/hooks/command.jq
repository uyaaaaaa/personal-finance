def without_heredocs:
	reduce split("\n")[] as $line ({kept: [], ends: []};
		if (.ends | length) > 0 then
			if ($line | gsub("^\\s+|\\s+$"; "")) == .ends[0] then .ends |= .[1:] else . end
		else
			.kept += [$line]
			| .ends += [$line | scan("<<-?\\s*([\"']?)([A-Za-z_][A-Za-z0-9_]*)\\1") | .[1]]
		end)
	| .kept | join("\n");

def tokens:
	without_heredocs
	| [scan("\\d*(?:>>|<<-?|[<>])&?\\d*|&&|\\|\\||[;|&\\n(){}]|\"(?:[^\"\\\\]|\\\\.)*\"|'[^']*'|[^\\s;|&\\n(){}\"']+")];

def separator: IN("&&", "||", ";", "|", "&", "\n", "(", ")", "{", "}");

def unquote: sub("^\"(?<v>[\\s\\S]*)\"$"; "\(.v)") | sub("^'(?<v>[\\s\\S]*)'$"; "\(.v)");

def segments:
	tokens as $all
	| reduce range(0; $all | length) as $at ({found: [[]], skip: false};
		if .skip then .skip = false
		elif ($all[$at] | separator) then .found += [[]]
		elif ($all[$at] | test("^\\d*[<>]+")) then .skip = ($all[$at] | test("^\\d*[<>]+$"))
		else .found[-1] += [$all[$at] | unquote] end)
	| .found[];

def invoked($name):
	. as $found
	| (first(range(0; length) | select(($found[.] | test("^[A-Za-z_][A-Za-z0-9_]*=")) or $found[.] == "env" | not)) // length) as $at
	| if ($found[$at] // "" | sub("^.*/"; "")) == $name then $found[$at:] else null end;
