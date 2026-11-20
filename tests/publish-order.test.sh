#!/bin/sh
. "$(dirname "$0")/lib.sh"
po=$root/lib/publish-order.sh

ws=$SHIM/ws
pkg() { # <name> <deps>
	mkdir -p "$ws/$1"
	printf 'Package {\n    name: "%s",\n    deps: {\n%s    },\n}\n' "$1" "$2" > "$ws/$1/nabi.nabion"
}
printf '{"components": [%s]}\n' \
	'{"kind": "package", "repo": "o/plot"}, {"kind": "package", "repo": "o/table"}, {"kind": "site", "repo": "o/site"}, {"kind": "package", "repo": "o/json"}, {"kind": "package", "repo": "o/stats"}, {"kind": "package", "repo": "o/special"}' \
	> "$SHIM/pipeline.json"
NABI_PIPELINE=$SHIM/pipeline.json
export NABI_PIPELINE
pkg json ''
pkg special ''
pkg table '        "json": Dep::path("../json", version: "^0.1"),\n'
pkg plot '        "table": Dep::path("../table", version: "^0.1", optional: true),\n'
pkg stats '        "specfun": Dep::path("../special", version: "^0.1", package: "special"),\n'

t_case "dependencies first"
out=$(sh "$po" "$ws")
pos() { echo "$out" | grep -nx "$1" | cut -d: -f1; }
[ "$(echo "$out" | wc -l | tr -d ' ')" = 5 ] || fail "want 5 packages, got [$out]"
[ "$(pos json)" -lt "$(pos table)" ] || fail "json after table: [$out]"
[ "$(pos table)" -lt "$(pos plot)" ] || fail "table after plot: [$out]"
[ "$(pos special)" -lt "$(pos stats)" ] || fail "special after stats: [$out]"

t_case "a path dependency without a version"
pkg table '        "json": Dep::path("../json"),\n'
if err=$(sh "$po" "$ws" 2>&1); then fail "passed: $err"; fi
has "$err" 'write Dep::path("../json", version: "^0.1")'

t_case "a cycle"
pkg table '        "json": Dep::path("../json", version: "^0.1"),\n'
pkg json '        "plot": Dep::path("../plot", version: "^0.1"),\n'
if err=$(sh "$po" "$ws" 2>&1); then fail "passed: $err"; fi
has "$err" "cycle"
