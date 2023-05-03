#!/bin/bash

function die() {
  echo "$@" >&2
  exit 1
}

if which git >/dev/null; then
  if git diff --name-only --cached | grep -E '^list/no-free-gtld/dist/ublock_origin.txt'; then
    current_tag="[local]"
  else
    current_tag="$(git rev-parse HEAD)"
  fi
else
  if [ -z "$CI" ]; then
    current_tag="[unknown]"
  else
    die "In CI environment, git must be usable."
  fi
fi

self="$(dirname "$0")"
subdir="$(realpath -e "$self/..")"
(cd "$subdir" && pwsh -File "$self/fetch_exception.ps1")
dist="$subdir/dist/ublock_origin.txt"
rm "$dist" 2>/dev/null || true
touch "$dist"

echo "! SPDX-License-Identifier: CC-BY-4.0" >> "$dist"
echo "! Generated-Date: $(date '+%Y-%m-%dT%H:%M:%S,%N%z')" >> "$dist"
echo "! Git-Commit: ${current_tag}" >> "$dist"
echo "! Description: This file blocks access to 'free gTLD', one may feel this is pedantic." >> "$dist"
echo "! Blanket rules" >> "$dist"
echo "*.tk" >> "$dist"
echo "*.ml" >> "$dist"
echo "*.ga" >> "$dist"
echo "*.cf" >> "$dist"
echo "*.gq" >> "$dist"
echo "! Known exception, fetched from Wikidata" >> "$dist"
sed -E 's/^(.*)$/@@\1/g' < "$(dirname "$0")/../intermediate/known_exempt_hosts.txt" >> "$dist"
