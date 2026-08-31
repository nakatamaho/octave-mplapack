#!/bin/sh

set -eu

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

for command_name in git gh octave mkoctfile pkg-config c++ make; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "FAIL: mandatory M00 command is unavailable: $command_name" >&2
    exit 1
  fi
done

if ! gh auth status >/dev/null 2>&1; then
  echo "FAIL: mandatory M00 GitHub authentication is unavailable" >&2
  exit 1
fi

if ! pkg-config --exists 'mplapack_mpfr >= 3.0.0'; then
  echo "FAIL: mandatory MPLAPACK MPFR development interface is unavailable" >&2
  exit 1
fi

echo "PASS: mandatory M00 prerequisites"
tools/check-tree.sh
tools/check-format.sh
echo "PASS: required M00 checks"
echo "SKIP: M01+ native and numerical tests are outside M00 scope"
