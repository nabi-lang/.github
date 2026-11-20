#!/bin/sh
# Print the package repositories of release/pipeline.json in an order that
# publishes each one after the packages its Dep::path(..) dependencies name.
#
#   publish-order.sh <workspace>     (the directory holding the checkouts)
#
# A package whose path dependency has no `version:` cannot be published
# (`nabi publish` rejects it); that is an error here too. A cycle is an
# error.
set -eu
lib=$(cd "$(dirname "$0")" && pwd)

[ $# -eq 1 ] || {
	echo "usage: publish-order.sh <workspace>" >&2
	exit 2
}
ws=$1
manifest=${NABI_PIPELINE:-$lib/../release/pipeline.json}

pkgs=$(jq -r '.components[] | select(.kind == "package") | .repo | sub(".*/"; "")' "$manifest")
edges=$(mktemp)
trap 'rm -f "$edges"' EXIT
bad=0
for p in $pkgs; do
	f=$ws/$p/nabi.nabion
	[ -f "$f" ] || {
		echo "publish-order: no $f" >&2
		exit 1
	}
	echo "$p $p" >> "$edges"
	# one Dep::path(..) per match, also several on one line
	for d in $(grep -o 'Dep::path("\.\./[A-Za-z0-9_.-]*"[^)]*)' "$f" | tr ' ' '~'); do
		dep=$(echo "$d" | sed 's/^Dep::path("\.\.\/\([^"]*\)".*/\1/')
		case $d in
		*version:*) ;;
		*)
			echo "publish-order: $p depends on ../$dep with no version; write Dep::path(\"../$dep\", version: \"^0.1\")" >&2
			bad=1
			;;
		esac
		echo "$dep $p" >> "$edges"
	done
done
[ "$bad" -eq 0 ] || exit 1
# tsort exits 0 on a cycle on some systems; its warning is the signal.
err=$(mktemp)
trap 'rm -f "$edges" "$err"' EXIT
out=$(tsort "$edges" 2> "$err") || true
if [ -s "$err" ]; then
	echo "publish-order: the path dependencies have a cycle:" >&2
	cat "$err" >&2
	exit 1
fi
echo "$out"
