#!/usr/bin/env bash
set -euo pipefail

# Verify that the explicit small matrices in the detailed documentation are
# exactly the matrices produced by the existing NEIGT/SVT example generators.
# This is documentation QA; it does not run eig or svd.

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

octave_bin="${OCTAVE_BIN:-}"
package_load='pkg load mplapack-interop;'
if [[ -z "$octave_bin" && -x /home/docker/opt/octave-mplapack-stack/bin/octave-mplapack ]]; then
  octave_bin=/home/docker/opt/octave-mplapack-stack/bin/octave-mplapack
  stack_root=$(CDPATH= cd "$(dirname "$octave_bin")/.." && pwd)
  package_load="pkg ('local_list', '$stack_root/octave_packages'); pkg load mplapack-interop;"
fi
if [[ -z "$octave_bin" && -x "$repo_root/tools/dev-octave.sh" ]]; then
  octave_bin="$repo_root/tools/dev-octave.sh"
  package_load=''
  if [[ -f /home/docker/opt/octave-mplapack-stack/lib/pkgconfig/mplapack_mpfr.pc ]]; then
    export PKG_CONFIG_PATH="/home/docker/opt/octave-mplapack-stack/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
    export LD_LIBRARY_PATH="/home/docker/opt/octave-mplapack-stack/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export CPATH="/home/docker/opt/octave-mplapack-stack/include${CPATH:+:$CPATH}"
  fi
fi
octave_bin="${octave_bin:-octave}"

command -v "${octave_bin##*/}" >/dev/null 2>&1 || [[ -x "$octave_bin" ]] || {
  echo "ERROR: Octave executable not found: $octave_bin" >&2
  exit 1
}
command -v python3 >/dev/null 2>&1 || {
  echo "ERROR: python3 is required for exact Markdown comparison" >&2
  exit 1
}

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/mplapack-smoke-matrices.XXXXXX")
records="$tmp_dir/smoke-matrices.tsv"

run_octave() {
  HOME="$tmp_dir/home" "$octave_bin" --no-gui --quiet --no-init-file "$@"
}
mkdir -p "$tmp_dir/home"

run_octave --eval "$package_load addpath ('$repo_root/tools'); dump_smoke_matrices ('$records');"
python3 "$repo_root/tools/check-smoke-matrices.py" "$records"

echo "PASS: explicit smoke matrices match the existing NEIGT/SVT generators"
