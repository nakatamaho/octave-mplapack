#!/usr/bin/env bash
set -euo pipefail

# Static contract checks for the 44 one-case NEIG/SVD mathematical pages.
# This checks documentation structure and links only; it does not execute
# numerical examples.

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

fail=0
detail_root="docs/examples/tiered"
mapfile -t details < <(find "$detail_root"/neig-tier-s "$detail_root"/neig-tier-a \
                              "$detail_root"/svd-tier-s "$detail_root"/svd-tier-a \
                              -maxdepth 1 -type f -name '*.md' ! -name README.md |
                     LC_ALL=C sort)

if [[ "${#details[@]}" -ne 44 ]]; then
  echo "FAIL: expected 44 detailed tiered case pages, found ${#details[@]}" >&2
  fail=1
fi

required_headings=(
  "## Quick idea"
  "## Mathematical problem"
  "## Why this problem is numerically difficult"
  "## What the Octave example computes"
  "## Diagnostics"
  "## Backward error versus forward error"
  "## What arbitrary precision changes"
  "## Reading the output"
  "## Common mistakes"
  "## References"
  "## Project provenance"
)

for file in "${details[@]}"; do
  [[ -f "$file" ]] || {
    echo "FAIL: missing detail page: $file" >&2
    fail=1
    continue
  }

  words=$(wc -w < "$file")
  if [[ "$words" -lt 1000 ]]; then
    echo "FAIL: detail page is too short ($words words): $file" >&2
    fail=1
  fi

  previous_line=0
  for heading in "${required_headings[@]}"; do
    line=$(rg -n -m1 -F "$heading" "$file" | cut -d: -f1 || true)
    if [[ -z "$line" ]]; then
      echo "FAIL: $file missing heading: $heading" >&2
      fail=1
    elif [[ "$line" -le "$previous_line" ]]; then
      echo "FAIL: $file headings are out of order near: $heading" >&2
      fail=1
    else
      previous_line="$line"
    fi
  done

  dollar_count=$(rg -o '\$\$' "$file" | wc -l)
  if [[ "$dollar_count" -eq 0 || $((dollar_count % 2)) -ne 0 ]]; then
    echo "FAIL: unbalanced or absent $$ math delimiters: $file" >&2
    fail=1
  fi

  if rg -n -F -e '\(' -e '\)' -e '\[' -e '\]' "$file" >/dev/null; then
    echo "FAIL: raw LaTeX delimiters are forbidden; use Markdown \$...\$ or \$\$...\$\$: $file" >&2
    fail=1
  fi

  if rg -n -i 'undefined|TODO|PLACEHOLDER|localhost|example\.com' "$file" >/dev/null; then
    echo "FAIL: placeholder or incomplete content in detail page: $file" >&2
    fail=1
  fi

  math_problem=$(awk '
    /^## Mathematical problem$/ { inside=1; next }
    /^## / && inside { exit }
    inside { print }
  ' "$file")
  if [[ -z "$math_problem" ]] || ! printf '%s\n' "$math_problem" | rg -F -q '$$'; then
    echo "FAIL: Mathematical problem section lacks a display equation: $file" >&2
    fail=1
  fi

  if awk 'index($0, sprintf("%c", 96)) == 1 { found=1 } END { exit !found }' "$file"; then
    echo "FAIL: fenced blocks are not allowed in detailed math pages: $file" >&2
    fail=1
  fi

  if [[ "$file" == *"/neig-tier-"* ]]; then
    if ! rg -q 'A[[:space:]]*V|A V' "$file" ||
       ! rg -F -q 'r_{\mathrm{eig}}' "$file"; then
      echo "FAIL: NEIG page lacks eigenproblem/residual definition: $file" >&2
      fail=1
    fi
  else
    if ! rg -q 'A=U.*V|A[[:space:]]*=.*U.*V' "$file" ||
       ! rg -F -q 'r_{\mathrm{svd}}' "$file"; then
      echo "FAIL: SVD page lacks SVD/reconstruction residual definition: $file" >&2
      fail=1
    fi
  fi

  references=$(awk '
    /^## References$/ { inside=1; next }
    /^## / && inside { exit }
    inside { print }
  ' "$file")
  if [[ -z "$references" ]] || ! printf '%s\n' "$references" | rg -q 'https://'; then
    echo "FAIL: References must contain an external URL: $file" >&2
    fail=1
  fi
  if printf '%s\n' "$references" | rg -qi 'TODO|PLACEHOLDER|localhost|example\.com'; then
    echo "FAIL: placeholder/local URL in References: $file" >&2
    fail=1
  fi
  if printf '%s\n' "$references" | rg -q 'DOI[[:space:]]*:' &&
     ! printf '%s\n' "$references" | rg -q 'https://doi\.org/'; then
    echo "FAIL: DOI citation does not use doi.org: $file" >&2
    fail=1
  fi

  while IFS= read -r link; do
    target=${link#*](}
    target=${target%)}
    case "$target" in
      ""|\#*) continue ;;
      https://*|http://*|mailto:*) continue ;;
    esac
    target=${target%%\#*}
    target=${target%%\?*}
    if [[ ! -e "$(dirname "$file")/$target" ]]; then
      echo "FAIL: broken relative link in $file: $target" >&2
      fail=1
    fi
  done < <(rg -o '\]\([^)]*\)' "$file" || true)
done

# Validate relative links in the family/master indexes and glossary as well.
while IFS= read -r file; do
  while IFS= read -r link; do
    target=${link#*](}
    target=${target%)}
    case "$target" in
      ""|\#*|https://*|http://*|mailto:*) continue ;;
    esac
    target=${target%%\#*}
    target=${target%%\?*}
    if [[ ! -e "$(dirname "$file")/$target" ]]; then
      echo "FAIL: broken relative link in $file: $target" >&2
      fail=1
    fi
  done < <(rg -o '\]\([^)]*\)' "$file" || true)
done < <(find "$detail_root" -type f -name '*.md' ! -path '*/neig-tier-*/*.md' ! -path '*/svd-tier-*/*.md' | LC_ALL=C sort)

if [[ "$fail" -ne 0 ]]; then
  echo "FAIL: tiered mathematical/reference documentation checks" >&2
  exit 1
fi

echo "PASS: tiered mathematical/reference documentation checks"
