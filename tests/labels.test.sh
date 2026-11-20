#!/bin/sh
. "$(dirname "$0")/lib.sh"
l=$root/lib/labels.sh
n=$(jq '.labels | length' "$root/labels.json")
state '{repos: {"nabi-lang/json": {labels: [
	{name: "type: bug", color: "000000", description: "old"},
	{name: "mine", color: "111111", description: "kept"}]}}}'
labels() { jq -c '.repos["nabi-lang/json"].labels' "$SHIM/state.json"; }

t_case "dry run calls nothing"
out=$(sh "$l" --dry-run nabi-lang/json)
has "$out" "nabi-lang/json: type: bug"
eq "$(calls .)" 0

t_case "updates a label that is there, creates the rest, keeps others"
out=$(sh "$l" nabi-lang/json)
has "$out" "updated type: bug"
has "$out" "created good first issue"
eq "$(labels | jq -r '.[] | select(.name == "type: bug") | .color')" d73a4a
eq "$(labels | jq -r '.[] | select(.name == "mine") | .description')" kept
eq "$(labels | jq 'length')" $((n + 1))

t_case "a second run creates nothing"
out=$(sh "$l" nabi-lang/json)
hasnt "$out" "created"
eq "$(calls '^POST ')" 0

t_case "a 502 is retried, not doubled"
fault 1 502 '^PATCH repos/nabi-lang/json/labels/alarm$'
sh "$l" nabi-lang/json > /dev/null 2>&1
eq "$(labels | jq 'length')" $((n + 1))

t_case "a 403 stops with the label named"
fault 1 403 '^PATCH repos/nabi-lang/json/labels/type%3A%20bug$'
rc=0
out=$(sh "$l" nabi-lang/json 2>&1) || rc=$?
eq "$rc" 1
has "$out" 'updating "type: bug" failed (HTTP 403)'
