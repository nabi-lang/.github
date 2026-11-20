#!/bin/sh
# Make the labels of a repository match labels.json: each label is
# updated (color, description) or created. Labels not in the file are
# left alone, so nothing a human added is lost.
#
#   labels.sh [--dry-run] <owner/name>...
#
# --dry-run prints what it would do and calls nothing. Needs gh (GH_TOKEN
# with issues: write on each repository) and jq.
set -eu
lib=$(cd "$(dirname "$0")" && pwd)
. "$lib/retry.sh"
. "$lib/gh.sh"

file=${LABELS_FILE:-$lib/../labels.json}
dry=false
if [ "${1:-}" = --dry-run ]; then
	dry=true
	shift
fi
[ $# -ge 1 ] || {
	echo "usage: labels.sh [--dry-run] <owner/name>..." >&2
	exit 2
}
[ "$(jq -r .schema "$file")" = 1 ] || {
	echo "::error::labels: $file is not schema 1; update lib/labels.sh with it" >&2
	exit 2
}

for repo; do
	jq -c '.labels[]' "$file" | while IFS= read -r l; do
		name=$(printf '%s\n' "$l" | jq -r .name)
		if [ "$dry" = true ]; then
			echo "$repo: $name"
			continue
		fi
		in=$(mktemp)
		printf '%s\n' "$l" | jq '{new_name: .name, color, description}' > "$in"
		rc=0
		gh_api PATCH "repos/$repo/labels/$(gh_urlencode "$name")" --input "$in" > /dev/null 2>&1 || rc=$?
		if [ "$rc" -ne 0 ] && [ "$(gh_status)" = 404 ]; then
			printf '%s\n' "$l" | jq '{name, color, description}' > "$in"
			gh_api POST "repos/$repo/labels" --input "$in" > /dev/null
			echo "$repo: created $name"
		elif [ "$rc" -ne 0 ]; then
			rm -f "$in"
			echo "::error::labels: $repo: updating \"$name\" failed (HTTP $(gh_status))" >&2
			exit 1
		else
			echo "$repo: updated $name"
		fi
		rm -f "$in"
	done
done
