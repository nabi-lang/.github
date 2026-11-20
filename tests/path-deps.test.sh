#!/bin/sh
. "$(dirname "$0")/lib.sh"
pd=$root/lib/path-deps.sh

# origin/<repo>.git: the org's repositories
repo() { # <name> <nabion body>
	mkdir -p "$SHIM/origin/$1.git"
	printf '%s\n' "$2" > "$SHIM/origin/$1.git/nabi.nabion"
	git -C "$SHIM/origin/$1.git" init -q -b main
	git -C "$SHIM/origin/$1.git" -c user.name=t -c user.email=t@t add -A
	git -C "$SHIM/origin/$1.git" -c user.name=t -c user.email=t@t commit -q -m init
}
repo linalg 'Package { name: "linalg", deps: {} }'
repo special 'Package { name: "special", deps: {} }'
repo json 'Package { name: "json", deps: {} }'
repo table 'Package { name: "table", deps: { "json": Dep::path("../json") } }'
NABI_DEPS_BASE=file://$SHIM/origin
export NABI_DEPS_BASE

t_case "direct and renamed"
mkdir -p "$SHIM/w1/stats"
printf 'Package {\n    deps: {\n        "linalg": Dep::path("../linalg"),\n        "specfun": Dep::path("../special", package: "special"),\n    },\n}\n' > "$SHIM/w1/stats/nabi.nabion"
out=$(sh "$pd" "$SHIM/w1/stats")
eq "$(echo "$out" | tr '\n' ' ')" "linalg special "
[ -f "$SHIM/w1/linalg/nabi.nabion" ] || fail "linalg not cloned"
[ -f "$SHIM/w1/special/nabi.nabion" ] || fail "special not cloned"

t_case "transitive"
mkdir -p "$SHIM/w2/plot"
printf 'Package { deps: { "table": Dep::path("../table") } }\n' > "$SHIM/w2/plot/nabi.nabion"
out=$(sh "$pd" "$SHIM/w2/plot")
eq "$(echo "$out" | tr '\n' ' ')" "table json "
[ -f "$SHIM/w2/json/nabi.nabion" ] || fail "json not cloned"

t_case "present kept, none"
mkdir -p "$SHIM/w3/plot" "$SHIM/w3/table"
printf 'Package { deps: { "table": Dep::path("../table") } }\n' > "$SHIM/w3/plot/nabi.nabion"
printf 'Package { deps: {} }\n' > "$SHIM/w3/table/nabi.nabion"
eq "$(sh "$pd" "$SHIM/w3/plot")" "" "nothing cloned"
eq "$(sh "$pd" "$SHIM/w3/table")" "" "no deps"

t_case "missing repo"
mkdir -p "$SHIM/w4/x"
printf 'Package { deps: { "nope": Dep::path("../nope") } }\n' > "$SHIM/w4/x/nabi.nabion"
err=$(sh "$pd" "$SHIM/w4/x" 2>&1) && fail "a missing repo passed"
has "$err" "cannot clone $NABI_DEPS_BASE/nope.git, a path dependency of x"
err=$(sh "$pd" "$SHIM/w4/none" 2>&1) && fail "no manifest passed"
has "$err" "has no nabi.nabion"
