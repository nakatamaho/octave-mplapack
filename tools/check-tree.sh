#!/bin/sh

set -eu

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

failed=0

required_dirs='
.github/workflows
inst
inst/@mp
src
test
tools
docs
docs/milestones
packaging
packaging/debian
'

required_files='
.github/workflows/ci.yml
AGENTS.md
README.md
LICENSE
COPYING
NEWS.md
CONTRIBUTING.md
.gitignore
DESCRIPTION
INDEX
inst/@mp/mp.m
inst/@mp/horzcat.m
inst/@mp/vertcat.m
inst/@mp/disp.m
inst/@mp/char.m
inst/@mp/double.m
inst/@mp/plus.m
inst/@mp/minus.m
inst/@mp/times.m
inst/@mp/rdivide.m
inst/@mp/uplus.m
inst/@mp/uminus.m
inst/@mp/size.m
inst/@mp/rows.m
inst/@mp/columns.m
inst/@mp/numel.m
inst/@mp/ndims.m
inst/@mp/isempty.m
inst/@mp/subsref.m
inst/@mp/subsasgn.m
inst/@mp/end.m
inst/@mp/mtimes.m
inst/@mp/mldivide.m
inst/@mp/mrdivide.m
inst/@mp/transpose.m
inst/@mp/ctranspose.m
inst/@mp/reshape.m
inst/@mp/chol.m
inst/@mp/qr.m
inst/mpbits.m
inst/mpdigits.m
inst/mplapack_version.m
src/Makefile
src/mp_scalar_storage.h
src/mp_scalar_storage.cc
src/mp_precision.h
src/mp_precision.cc
src/mp_value.h
src/mp_value.cc
src/mp_convert.cc
src/mp_arithmetic.cc
src/mp_matrix_storage.h
src/mp_matrix_storage.cc
src/mp_matrix_value.h
src/mp_matrix_value.cc
src/mp_blas.cc
src/mp_lapack.cc
src/mp_lapack.h
src/mp_matrix_inspection.cc
src/mp_matrix_inspection.h
src/mp_matrix_arithmetic.cc
src/mp_matrix_arithmetic.h
src/mp_matrix_structure.cc
src/mp_matrix_structure.h
src/mp_matrix_concat.cc
src/mp_matrix_concat.h
src/mp_matrix_assignment.cc
src/mp_matrix_assignment.h
src/octave_bridge.cc
test/run_tests.m
test/build_probe.tst
test/native_value.tst
test/native_lifetime.m
test/public_lifetime.m
test/mp_scalar_storage_test.cc
test/mp_scalar_arithmetic_test.cc
test/mp_matrix_storage_test.cc
test/constructor.tst
test/precision.tst
test/conversion.tst
test/arithmetic.tst
test/matrix_storage.tst
test/matrix_lifetime.m
test/gemm.tst
test/gesv.tst
test/rgels.tst
test/rank.tst
test/mp_lapack_probe.cc
test/mp_lapack_test.cc
test/mp_lapack_rgels_test.cc
test/mp_lapack_rank_test.cc
test/m16_driver_probe.cc
test/mp_lapack_cholesky_test.cc
test/m17_rpotrf_probe.cc
test/chol.tst
test/mp_lapack_qr_test.cc
test/m18_qr_probe.cc
test/qr.tst
test/mp_lapack_pivoted_qr_test.cc
test/m19_qr_probe.cc
test/pivoted_qr.tst
test/matrix_inspection.tst
test/mp_matrix_inspection_test.cc
test/elementwise.tst
test/mp_matrix_arithmetic_test.cc
test/structure.tst
test/mp_matrix_structure_test.cc
test/concat.tst
test/mp_matrix_concat_test.cc
test/assignment.tst
test/mp_matrix_assignment_test.cc
tools/check-format.sh
tools/check-tree.sh
tools/local-ci.sh
tools/build-package.sh
docs/architecture.md
docs/native-value-design.md
docs/public-mp-design.md
docs/conversion-display.md
docs/scalar-arithmetic.md
docs/dense-matrix-design.md
docs/linear-solve.md
docs/rectangular-solve.md
docs/matrix-inspection.md
docs/elementwise-arithmetic.md
docs/matrix-structure.md
docs/matrix-concatenation.md
docs/precision-semantics.md
docs/packaging.md
docs/milestones/README.md
docs/milestones/M00-bootstrap.md
docs/milestones/M01-build-probe.md
docs/milestones/M02-native-value.md
docs/milestones/M03-constructors.md
docs/milestones/M04-precision.md
docs/milestones/M05-conversion.md
docs/milestones/M06-elementwise.md
docs/milestones/M07-matrix-storage.md
docs/milestones/M08-mtimes.md
docs/milestones/M09-mldivide.md
docs/milestones/M10-first-functional-baseline.md
docs/milestones/M11-elementwise-arithmetic.md
docs/milestones/M12-transpose-reshape.md
docs/milestones/M13-concatenation.md
docs/qr.md
docs/milestones/M18-qr.md
docs/pivoted-qr.md
docs/milestones/M19-pivoted-qr.md
docs/matrix-assignment.md
docs/milestones/M14-indexed-assignment.md
docs/milestones/M15-rgels.md
docs/milestones/M16-rank-deficient-lstsq.md
docs/rank-deficient-solve.md
docs/cholesky.md
docs/milestones/M17-cholesky.md
docs/milestones/P00-packaging-design.md
docs/milestones/P01-debian-source-package.md
docs/milestones/P02-local-deb-build.md
docs/milestones/P03-ppa-staging.md
docs/milestones/P04-ppa-autopkgtest.md
docs/milestones/P05-ppa-stable.md
docs/milestones/P06-ubuntu-series-matrix.md
packaging/debian/README.md
'

for path in $required_dirs; do
  if [ ! -d "$path" ]; then
    echo "FAIL: missing required directory: $path" >&2
    failed=1
  fi
done

for path in $required_files; do
  if [ ! -f "$path" ]; then
    echo "FAIL: missing required file: $path" >&2
    failed=1
  fi
done

for path in tools/check-tree.sh tools/check-format.sh tools/local-ci.sh \
  tools/build-package.sh; do
  if [ -f "$path" ] && [ ! -x "$path" ]; then
    echo "FAIL: required script is not executable: $path" >&2
    failed=1
  fi
done

for path in docs/milestones/M??-*.md docs/milestones/P??-*.md; do
  [ -f "$path" ] || continue
  for heading in Goal Scope Non-goals "Design constraints" \
    "Implementation tasks" "Required tests" Gate "Expected commit"; do
    if ! grep -Fqx "# $heading" "$path"; then
      echo "FAIL: $path lacks required heading: # $heading" >&2
      failed=1
    fi
  done
done

if [ "$failed" -ne 0 ]; then
  echo "FAIL: M00 tree checks failed" >&2
  exit 1
fi

if ! cmp LICENSE COPYING; then
  echo "FAIL: LICENSE and COPYING differ" >&2
  exit 1
fi

if grep -Eq '__mplapack_core__|scalar_' INDEX; then
  echo "FAIL: private native APIs must not appear in INDEX" >&2
  exit 1
fi

echo "PASS: M00-M19 tree checks"
