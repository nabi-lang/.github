#!/bin/sh
# Clone the sibling path dependencies of a package, transitively.
#
#   path-deps.sh <dir>
#
# Every Dep::path("../<repo>") in <dir>/nabi.nabion is cloned from
# $NABI_DEPS_BASE/<repo>.git into ../<repo> beside <dir>, then its own
# path dependencies, and so on. A directory that is already there is kept.
#
# Environment: NABI_DEPS_BASE (https://github.com/nabi-lang).
set -eu
lib=$(cd "$(dirname "$0")" && pwd)
. "$lib/retry.sh"

: "${NABI_DEPS_BASE:=https://github.com/nabi-lang}"

[ $# -eq 1 ] || {
	echo "usage: path-deps.sh <dir>" >&2
	exit 2
}
[ -f "$1/nabi.nabion" ] || {
	echo "::error::path-deps: $1 has no nabi.nabion" >&2
	exit 1
}
base=$(cd "$1/.." && pwd)
todo=$(cd "$1" && pwd)
while [ -n "$todo" ]; do
	next=
	for d in $todo; do
		# every match, also several on one line
		deps=$(grep -o 'Dep::path("\.\./[A-Za-z0-9_.-]*"' "$d/nabi.nabion" | sed 's/.*\///; s/"$//' | tr '\n' ' ') || true
		for p in $deps; do
			[ -d "$base/$p" ] && continue
			retry -- git clone -q --depth 1 "$NABI_DEPS_BASE/$p.git" "$base/$p" ||
				{
					echo "::error::path-deps: cannot clone $NABI_DEPS_BASE/$p.git, a path dependency of $(basename "$d")" >&2
					exit 1
				}
			echo "$p"
			next="$next $base/$p"
		done
	done
	todo=$next
done
