#!/bin/sh

set -eu

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
manual=$repo_root/doc/mplapack-interop.texi
output=${1:-$repo_root/docs/mplapack-interop.md}

case $output in
  /*) ;;
  *) output=$repo_root/$output ;;
esac

[ -f "$manual" ] || {
  echo "ERROR: missing Texinfo manual: $manual" >&2
  exit 1
}
command -v texi2any >/dev/null 2>&1 || {
  echo "ERROR: texi2any is required to read the Texinfo manual" >&2
  exit 1
}
command -v pandoc >/dev/null 2>&1 || {
  echo "ERROR: pandoc is required to generate Markdown" >&2
  exit 1
}

build_dir=$(mktemp -d)
cleanup ()
{
  find "$build_dir" -depth -delete
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

texi2any --docbook "$manual" -o "$build_dir/manual.xml"
pandoc --from=docbook --to=gfm --shift-heading-level-by=1 --wrap=none \
  "$build_dir/manual.xml" -o "$build_dir/body.md"
sed 's/[[:space:]]*$//' "$build_dir/body.md" > "$build_dir/body-clean.md"

mkdir -p "$(dirname "$output")"
{
  printf '%s\n\n' '# mplapack-interop'
  printf '%s\n\n' 'This Markdown manual is generated from [doc/mplapack-interop.texi](../doc/mplapack-interop.texi) via GNU Texinfo DocBook output and Pandoc. Edit the Texinfo source, then regenerate this file with `tools/build-manual-markdown.sh`.'
  cat "$build_dir/body-clean.md"
} > "$build_dir/output.md"
mv "$build_dir/output.md" "$output"

echo "PASS: generated $output"
