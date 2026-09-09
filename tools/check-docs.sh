#!/usr/bin/env bash
set -euo pipefail

# Lightweight deterministic consistency checks for DOC00.

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"
fail=0

required=(
  doc/mplapack-interop.texi
  docs/public-api-inventory.md
  docs/backend-map.md
  docs/advanced-numerics-compatibility.md
  docs/octave-script-compatibility.md
  docs/precision-semantics.md
  docs/doxygen/Doxyfile
  docs/doxygen/mainpage.dox
  tools/build-docs.sh
  tools/test-doc-examples.sh
)
for path in "${required[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "FAIL: missing documentation artifact: $path" >&2
    fail=1
  fi
done

manual=doc/mplapack-interop.texi
inventory=docs/public-api-inventory.md

for chapter in \
  "Introduction" "Installation and package loading" "Creating @code{mp} values" \
  "Precision model" "Real and complex values" "Arithmetic and comparisons" \
  "Dense matrices and indexing" "Matrix factorizations and linear solves" \
  "Eigenvalues, SVD, Schur and QZ" "Matrix functions" \
  "Elementary and special functions" "Polynomial operations" "Set operations" \
  "Serialization and save/load" "Graphics" "Arbitrary-precision random numbers" \
  "Interpolation" "Nonlinear equations" "Numerical integration" "Optimization" \
  "Performance notes" "Octave compatibility" "Deferred and unsupported functionality" \
  "Troubleshooting" "API quick reference"; do
  if ! grep -Fq "@chapter $chapter" "$manual"; then
    echo "FAIL: manual chapter missing: $chapter" >&2
    fail=1
  fi
done

public_methods=$(find inst/@mp -maxdepth 1 -type f -name '*.m' -printf '%f\n' | sed 's/\.m$//' | LC_ALL=C sort)
public_functions=$(find inst -maxdepth 1 -type f -name '*.m' -printf '%f\n' | sed 's/\.m$//' | LC_ALL=C sort)
while IFS= read -r name; do
  [[ -n "$name" ]] || continue
  if ! grep -Fq "| \`$name\` |" "$inventory"; then
    echo "FAIL: public @mp method missing from inventory: $name" >&2
    fail=1
  fi
  if ! grep -Fq "@code{$name}" "$manual"; then
    echo "FAIL: public @mp method missing from manual: $name" >&2
    fail=1
  fi
  if ! grep -Fq '@deftypefn' "inst/@mp/$name.m"; then
    echo "FAIL: public @mp method missing help text: $name" >&2
    fail=1
  fi
done <<< "$public_methods"
while IFS= read -r name; do
  [[ -n "$name" ]] || continue
  if ! grep -Fq "| \`$name\` |" "$inventory"; then
    echo "FAIL: package function missing from inventory: $name" >&2
    fail=1
  fi
  if ! grep -Fq "@code{$name}" "$manual"; then
    echo "FAIL: package function missing from manual: $name" >&2
    fail=1
  fi
  if ! grep -Fq '@deftypefn' "inst/$name.m"; then
    echo "FAIL: package function missing help text: $name" >&2
    fail=1
  fi
done <<< "$public_functions"

for path in $(grep -o 'docs/todo/[A-Za-z0-9._/-]*\.md' "$inventory" | LC_ALL=C sort -u); do
  if [[ ! -f "$path" ]]; then
    echo "FAIL: missing TODO link target: $path" >&2
    fail=1
  fi
done

for path in docs/public-api-inventory.md docs/backend-map.md \
            docs/advanced-numerics-compatibility.md docs/precision-semantics.md; do
  [[ -f "$path" ]] || continue
  if grep -Eq 'does not provide inv\(mp\)|builtin[[:space:]]+double[[:space:]]+fallback' "$path"; then
    echo "FAIL: stale or unsafe precision claim in $path" >&2
    fail=1
  fi
done

for link in docs/public-api-inventory.md docs/advanced-numerics-compatibility.md \
            doc/mplapack-interop.texi examples/01_scalar_precision.m; do
  if ! grep -Fq "$link" README.md; then
    echo "FAIL: README missing documentation landing link/reference: $link" >&2
    fail=1
  fi
done

if ! grep -Fq 'MPLAPACK 3.0.1 release candidate' NEWS.md; then
  echo "FAIL: NEWS lacks current MPLAPACK release-candidate wording" >&2
  fail=1
fi
if ! grep -Fq 'D04' NEWS.md; then
  echo "FAIL: NEWS lacks D04 release context" >&2
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo "FAIL: DOC00 documentation consistency checks" >&2
  exit 1
fi
echo "PASS: DOC00 documentation consistency checks"
