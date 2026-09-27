include "command";

def shape: "claude/<主題>-<英数字4〜6>";
def trunk: "main";

def named:
	if . == trunk then "\(trunk) を直接動かすものは通さない。作業は \(shape) のブランチに置く"
	elif test("^claude/[a-z0-9]+(?:-[a-z0-9]+)*-[a-z0-9]{4,6}$") then empty
	else "ブランチ名 \(if . == "" then "（不明）" else . end) が規約に合わない。\(shape) で切る" end;

def deny: "deny\t\(.)";

def parse:
	. as $found
	| {at: 1, values: []}
	| until(.at >= ($found | length) or ($found[.at] | startswith("-") | not);
		(($found[.at] | capture("^(?<k>--[a-z-]+)=(?<v>[\\s\\S]*)$")) // null) as $attached
		| if $attached and ($attached.k | IN("-c", "--config-env", "-C", "--git-dir", "--work-tree", "--namespace")) then .values += [$attached.v] | .at += 1
		elif $found[.at] | IN("-c", "--config-env", "-C", "--git-dir", "--work-tree", "--namespace") then .values += [$found[.at + 1] // ""] | .at += 2
		else .at += 1 end)
	| {values, subcommand: ($found[.at] // ""), args: $found[.at + 1:]};

def pushed($head):
	. as $args
	| (reduce range(0; length) as $at ({skip: false, positional: []};
		if .skip then .skip = false
		elif $args[$at] | IN("-o", "--push-option", "--repo", "--receive-pack", "--exec") then .skip = true
		elif $args[$at] | startswith("-") then .
		else .positional += [$args[$at]] end) | .positional) as $positional
	| ($positional[0] // "origin") as $remote
	| (if ($positional | length) > 1 then $positional[1:] else ["HEAD"] end) as $specs
	| (any($args[]; test("^(?:-[a-zA-Z]*f[a-zA-Z]*|--force(?:-with-lease|-if-includes)?(?:=.*)?)$")) or any($specs[]; startswith("+"))) as $force
	| $specs[]
	| (sub("^\\+"; "") | split(":")) as $parts
	| ($parts[1] // $parts[0]) as $reference
	| (if $reference == "HEAD" or $reference == "" then $head else $reference | sub("^refs/heads/"; "") end) as $target
	| (($target | named | deny), (if $force then "force\t\($remote)\t\($target)" else empty end));

def created($flag):
	. as $args
	| (first(range(0; length) | select($args[.] | test($flag)))) as $at
	| $args[$at + 1] // "" | named | deny;

def branched:
	[.[] | select(startswith("-"))] as $flags
	| [.[] | select(startswith("-") | not)] as $positional
	| if ($positional | length) == 0 then empty
	elif any($flags[]; test("^(?:-[mMcC]|--move|--copy)$")) then $positional[-1] | named | deny
	elif all($flags[]; test("^(?:-f|--force|-t|--track|--no-track|-q|--quiet)$")) then $positional[0] | named | deny
	else empty end;

def git($head):
	invoked("git") | select(. != null) | parse
	| .args as $args
	| ("rebase は履歴を書き換える。\(trunk) をマージして解消する" | deny) as $rebase
	| if .subcommand == "commit" and ($args | index("--amend")) then "--amend は履歴を書き換える。新しいコミットを積む" | deny
	elif .subcommand == "rebase" then $rebase
	elif .subcommand == "pull" and any($args[]; test("^(?:-[a-zA-Z]*r[a-zA-Z]*|--rebase(?:=(?!false).*)?)$")) then $rebase
	elif any(.values[]; test("^pull\\.rebase=(?!false)"; "i")) then $rebase
	elif .subcommand == "push" then $args | pushed($head)
	elif .subcommand == "branch" then $args | branched
	elif .subcommand == "checkout" then $args | created("^(?:-[bB]|--orphan)$")
	elif .subcommand == "switch" then $args | created("^(?:-[cC]|--create|--force-create|--orphan)$")
	elif .subcommand == "worktree" then $args | created("^-[bB]$")
	else empty end;

(.tool_name // "") as $name
| if $name | startswith("mcp__github__") then
	($name | ltrimstr("mcp__github__")) as $tool
	| if $tool | IN("merge_pull_request", "enable_pr_auto_merge") then "マージするかは書き手が判断する" | deny
	elif $tool == "create_branch" then .tool_input.branch // "" | named | deny
	else empty end
elif $name == "Bash" then
	.tool_input.command | strings | segments | git($head)
else empty end
