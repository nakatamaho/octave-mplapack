#!/bin/sh

set -eu

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

octave_bin=${OCTAVE:-octave}
pkg_config_bin=${PKG_CONFIG:-pkg-config}
mkoctfile_bin=${MKOCTFILE:-mkoctfile}
mplapack_pc=${MPLAPACK_PC:-mplapack_mpfr}

command -v "$octave_bin" >/dev/null 2>&1 || {
  echo "FAIL: Octave command not found: $octave_bin" >&2
  exit 1
}
command -v "$pkg_config_bin" >/dev/null 2>&1 || {
  echo "FAIL: pkg-config command not found: $pkg_config_bin" >&2
  exit 1
}
command -v "$mkoctfile_bin" >/dev/null 2>&1 || {
  echo "FAIL: mkoctfile command not found: $mkoctfile_bin" >&2
  exit 1
}
"$pkg_config_bin" --exists "$mplapack_pc" || {
  echo "FAIL: $mplapack_pc is not available through pkg-config" >&2
  exit 1
}

make -C src check-dependency
make -C src

mplapack_libdir=$($pkg_config_bin --variable=libdir "$mplapack_pc")
if [ -n "${LD_LIBRARY_PATH:-}" ]; then
  LD_LIBRARY_PATH=$mplapack_libdir:$LD_LIBRARY_PATH
else
  LD_LIBRARY_PATH=$mplapack_libdir
fi
export LD_LIBRARY_PATH

exec "$octave_bin" --no-gui --quiet --no-init-file \
  --path "$repo_root/inst" --path "$repo_root/src" "$@"
