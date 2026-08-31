#!/bin/sh

set -eu

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

failed=0

for file in $(git ls-files --cached --others --exclude-standard | LC_ALL=C sort); do
  if LC_ALL=C grep -n '[[:blank:]]$' "$file" >/dev/null; then
    echo "FAIL: trailing whitespace in $file" >&2
    LC_ALL=C grep -n '[[:blank:]]$' "$file" >&2
    failed=1
  fi

  if LC_ALL=C grep -n "$(printf '\r')" "$file" >/dev/null; then
    echo "FAIL: carriage return in $file" >&2
    failed=1
  fi
done

for script in tools/*.sh; do
  if ! sh -n "$script"; then
    echo "FAIL: shell syntax error in $script" >&2
    failed=1
  fi
done

for field in Name Version Date Title Author Maintainer Description License; do
  if ! grep -q "^${field}: " DESCRIPTION; then
    echo "FAIL: DESCRIPTION lacks field: $field" >&2
    failed=1
  fi
done

if [ "$failed" -ne 0 ]; then
  echo "FAIL: M00 formatting and sanity checks failed" >&2
  exit 1
fi

echo "PASS: M00/M01 formatting and sanity checks"
