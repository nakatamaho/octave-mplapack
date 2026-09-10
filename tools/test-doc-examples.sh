#!/usr/bin/env bash
set -euo pipefail

# Execute the public runnable examples and a representative help-text wall.
# The package itself must already be installed, or OCTAVE_BIN must point to a
# wrapper/environment that can load mplapack-interop.

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"
octave_bin="${OCTAVE_BIN:-}"
package_load='pkg load mplapack-interop;'
if [[ -z "$octave_bin" && -x "$repo_root/tools/dev-octave.sh" ]]; then
  octave_bin="$repo_root/tools/dev-octave.sh"
  # The source-tree wrapper exposes inst/ and src/ directly.  A temporary
  # HOME deliberately has no Octave package database, so pkg load would
  # reject the source-tree test even though the package files are present.
  package_load=''
  if [[ -f /home/docker/opt/octave-mplapack-stack/lib/pkgconfig/mplapack_mpfr.pc ]]; then
    export PKG_CONFIG_PATH="/home/docker/opt/octave-mplapack-stack/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
    export LD_LIBRARY_PATH="/home/docker/opt/octave-mplapack-stack/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export CPATH="/home/docker/opt/octave-mplapack-stack/include${CPATH:+:$CPATH}"
  fi
fi
if [[ -z "$octave_bin" && -x /home/docker/opt/octave-mplapack-stack/bin/octave-mplapack ]]; then
  octave_bin=/home/docker/opt/octave-mplapack-stack/bin/octave-mplapack
fi
octave_bin="${octave_bin:-octave}"
command -v "${octave_bin##*/}" >/dev/null 2>&1 || [[ -x "$octave_bin" ]] || {
  echo "ERROR: Octave executable not found: $octave_bin" >&2
  exit 1
}

test_home=$(mktemp -d "${TMPDIR:-/tmp}/mplapack-doc-home.XXXXXX")
trap 'rm -rf "$test_home"' EXIT

run_octave() {
  HOME="$test_home" "$octave_bin" --no-gui --quiet --no-init-file "$@"
}

for example in examples/01_scalar_precision.m \
              examples/02_matrix_arithmetic.m \
              examples/03_linear_solve.m \
              examples/04_factorizations.m \
              examples/05_hilbert_inverse.m \
              examples/06_grcar_eig.m \
              examples/07_svd_hilbert.m \
              examples/08_advanced_dense.m \
              examples/09_serialization_rng.m \
              examples/10_interpolation.m \
              examples/11_solvers_quadrature_optimization.m \
              examples/12_graphics_boundary.m \
              examples/13_nonsymmetric_eig_suite.m; do
  [[ -f "$example" ]] || { echo "ERROR: missing example: $example" >&2; exit 1; }
  echo "RUN: $example"
  run_octave --eval "$package_load run ('$repo_root/$example');"
done

help_list=(mp mpbits mpdigits mplapack_version \
  fminbnd fminsearch fsolve fzero integral interp1 interp2 mprand mprng \
  @mp/abs @mp/chol @mp/eig @mp/lu @mp/mldivide @mp/mrdivide @mp/norm \
  @mp/qr @mp/svd @mp/schur @mp/qz @mp/saveobj @mp/loadobj)
for name in "${help_list[@]}"; do
  echo "HELP: $name"
  output=$(run_octave --eval "txt = evalc ('help $name'); assert (! isempty (strtrim (txt)));" 2>&1) || {
    echo "$output" >&2
    echo "ERROR: help lookup failed: $name" >&2
    exit 1
  }
done

echo "PASS: runnable documentation examples and selected help lookups"
