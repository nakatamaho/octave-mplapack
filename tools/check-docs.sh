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
  docs/examples/tiered/README.md
  docs/examples/tiered/MIGRATION.md
  docs/examples/tiered/GLOSSARY.md
  docs/math-rendering-migration.md
  tools/check-tiered-math.sh
  tools/check-github-math.sh
  tools/check-smoke-matrices.sh
  tools/check-smoke-matrices.py
  tools/dump_smoke_matrices.m
  tools/format_smoke_matrices.py
  AGENTS.md
)
for path in "${required[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "FAIL: missing documentation artifact: $path" >&2
    fail=1
  fi
done

# Keep the GitHub rendering contract permanent rather than relying only on
# the current checker implementation.  These policy statements are part of
# the repository's documentation Definition of Done.
agents=AGENTS.md
for policy in \
  'GitHub Markdown is the source of truth for mathematical documentation.' \
  'Use fenced math blocks' \
  'Do not put display mathematics inside Markdown table cells' \
  'For piecewise definitions in GitHub Markdown, use the standard'; do
  if ! grep -Fq "$policy" "$agents"; then
    echo "FAIL: AGENTS.md is missing GitHub math policy: $policy" >&2
    fail=1
  fi
done
agents_policy_text=$(tr '\n' ' ' < "$agents")
if [[ "$agents_policy_text" != *"A documentation change is incomplete if its equations do not render correctly on GitHub."* ]]; then
  echo "FAIL: AGENTS.md is missing GitHub rendering Definition-of-Done rule" >&2
  fail=1
fi

manual=doc/mplapack-interop.texi
tiered_root=docs/examples/tiered
families="neig-tier-s neig-tier-a svd-tier-s svd-tier-a"
for family in $families; do
  family_readme="$tiered_root/$family/README.md"
  if [[ ! -f "$family_readme" ]]; then
    echo "FAIL: missing tiered family README: $family_readme" >&2
    fail=1
    continue
  fi
  while IFS= read -r example; do
    stem=$(basename "$example" .m)
    detail="$tiered_root/$family/$stem.md"
    if [[ ! -f "$detail" ]]; then
      echo "FAIL: split example has no matching detail document: $example" >&2
      fail=1
      continue
    fi
    count=$(find "$tiered_root/$family" -maxdepth 1 -type f -name "$stem.md" | wc -l)
    if [[ "$count" -ne 1 ]]; then
      echo "FAIL: expected exactly one detail document for $example, got $count" >&2
      fail=1
    fi
    if ! grep -Fq "$example" "$detail"; then
      echo "FAIL: detail document does not name its example: $detail" >&2
      fail=1
    fi
    if ! grep -Fq "$stem.m" "$family_readme" || ! grep -Fq "$stem.md" "$family_readme"; then
      echo "FAIL: family README omits split case: $example" >&2
      fail=1
    fi
  done < <(find examples/tiered/"$family" -maxdepth 1 -type f -name '*.m' | LC_ALL=C sort)
  while IFS= read -r detail; do
    detail_example=$(grep -o 'examples/[A-Za-z0-9_./-]*\.m' "$detail" | head -1 || true)
    if [[ -z "$detail_example" ]] || [[ ! -f "$detail_example" ]]; then
      echo "FAIL: detail document has no existing corresponding example: $detail" >&2
      fail=1
    fi
  done < <(find "$tiered_root/$family" -maxdepth 1 -type f -name '*.md' ! -name README.md | LC_ALL=C sort)
done

for family in $families; do
  if ! grep -Fq "$family/README.md" "$tiered_root/README.md"; then
    echo "FAIL: master tiered README omits family: $family" >&2
    fail=1
  fi
done
if ! grep -Fq '@section Tiered worked examples' "$manual" \
   || ! grep -Fq 'docs/examples/tiered/README.md' "$manual"; then
  echo "FAIL: manual does not point to the tiered worked-example section" >&2
  fail=1
fi

# The four historical entry points remain indexes. Every split case must be
# reachable from its original tier file, while the full runners retain QA.
for family in $families; do
  case "$family" in
    neig-tier-s) index_file=examples/14_neig_tier_s.m ;;
    neig-tier-a) index_file=examples/15_neig_tier_a.m ;;
    svd-tier-s) index_file=examples/14_svd_tier_s.m ;;
    svd-tier-a) index_file=examples/15_svd_tier_a.m ;;
  esac
  while IFS= read -r example; do
    if ! grep -Fq "$example" "$index_file"; then
      echo "FAIL: historical index omits split example: $example" >&2
      fail=1
    fi
  done < <(find examples/tiered/"$family" -maxdepth 1 -type f -name '*.m' | LC_ALL=C sort)
done

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

if [[ -x tools/check-tiered-math.sh ]]; then
  if ! tools/check-tiered-math.sh; then
    fail=1
  fi
else
  echo "FAIL: missing tools/check-tiered-math.sh" >&2
  fail=1
fi

if [[ -x tools/check-github-math.sh ]]; then
  if ! tools/check-github-math.sh; then
    fail=1
  fi
else
  echo "FAIL: missing tools/check-github-math.sh" >&2
  fail=1
fi

if [[ -x tools/check-smoke-matrices.sh ]]; then
  if ! tools/check-smoke-matrices.sh; then
    fail=1
  fi
else
  echo "FAIL: missing tools/check-smoke-matrices.sh" >&2
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo "FAIL: DOC00 documentation consistency checks" >&2
  exit 1
fi
echo "PASS: DOC00 documentation consistency checks"
