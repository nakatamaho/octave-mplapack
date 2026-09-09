#!/usr/bin/env bash
set -euo pipefail

# Build the source documentation surfaces without root or a package install.
# Generated files live under docs/.build and are excluded from release source.

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

manual="doc/mplapack-interop.texi"
build_dir="${DOC_BUILD_DIR:-$repo_root/docs/.build}"
doxygen_bin="${DOXYGEN_BIN:-doxygen}"

[[ -f "$manual" ]] || { echo "ERROR: missing $manual" >&2; exit 1; }
command -v makeinfo >/dev/null 2>&1 || {
  echo "ERROR: makeinfo is required to build the user manual" >&2
  exit 1
}
if ! command -v "${doxygen_bin##*/}" >/dev/null 2>&1 && [[ ! -x "$doxygen_bin" ]]; then
  echo "ERROR: doxygen is required to build the developer manual" >&2
  echo "Install Doxygen, then rerun tools/build-docs.sh." >&2
  exit 1
fi

rm -rf "$build_dir"
mkdir -p "$build_dir/html"

makeinfo --html --no-split "$manual" -o "$build_dir/html/index.html"
makeinfo --plaintext "$manual" -o "$build_dir/mplapack-interop.txt"
tools/build-manual-markdown.sh "$build_dir/mplapack-interop.md"

[[ -f "$repo_root/docs/mplapack-interop.md" ]] || {
  echo "ERROR: tracked Markdown manual is missing" >&2; exit 1;
}
cmp -s "$build_dir/mplapack-interop.md" "$repo_root/docs/mplapack-interop.md" || {
  echo "ERROR: tracked Markdown manual is stale; regenerate it" >&2; exit 1;
}

if command -v texi2pdf >/dev/null 2>&1 && command -v tex >/dev/null 2>&1; then
  texi2pdf --batch --quiet --output="$build_dir/mplapack-interop.pdf" "$manual"
else
  echo "INFO: no working TeX toolchain; Info/plaintext output is the manual artifact." >&2
fi

"$doxygen_bin" docs/doxygen/Doxyfile

[[ -s "$build_dir/html/index.html" ]] || {
  echo "ERROR: user HTML was not generated" >&2; exit 1;
}
[[ -s "$build_dir/mplapack-interop.txt" ]] || {
  echo "ERROR: user Info/plaintext output was not generated" >&2; exit 1;
}
[[ -s "$build_dir/mplapack-interop.md" ]] || {
  echo "ERROR: user Markdown output was not generated" >&2; exit 1;
}
[[ -f "$build_dir/doxygen/html/index.html" ]] || {
  echo "ERROR: Doxygen HTML was not generated" >&2; exit 1;
}

echo "PASS: user HTML, Info/plaintext, Markdown, and Doxygen HTML built"
