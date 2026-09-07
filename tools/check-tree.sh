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
test/script-compat
tools
docs
docs/milestones
examples
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
m20-report.md
m21-report.md
m22-report.md
m23-report.md
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
inst/@mp/norm.m
inst/@mp/svd.m
inst/@mp/eig.m
inst/@mp/rank.m
inst/@mp/cond.m
inst/@mp/rcond.m
inst/@mp/mrdivide.m
inst/@mp/abs.m
inst/@mp/angle.m
inst/@mp/arg.m
inst/@mp/sign.m
inst/@mp/isnan.m
inst/@mp/isinf.m
inst/@mp/isfinite.m
inst/@mp/isequal.m
inst/@mp/isequaln.m
inst/@mp/isnumeric.m
inst/@mp/power.m
inst/@mp/mpower.m
inst/@mp/sqrt.m
inst/@mp/exp.m
inst/@mp/expm1.m
inst/@mp/log.m
inst/@mp/log1p.m
inst/@mp/log10.m
inst/@mp/log2.m
inst/@mp/sin.m
inst/@mp/cos.m
inst/@mp/tan.m
inst/@mp/asin.m
inst/@mp/acos.m
inst/@mp/atan.m
inst/@mp/sinh.m
inst/@mp/cosh.m
inst/@mp/tanh.m
inst/@mp/asinh.m
inst/@mp/acosh.m
inst/@mp/atanh.m
inst/@mp/cbrt.m
inst/@mp/sum.m
inst/@mp/prod.m
inst/@mp/cumsum.m
inst/@mp/cumprod.m
inst/@mp/sumsq.m
inst/@mp/min.m
inst/@mp/max.m
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
src/mp_script_compat.h
src/mp_script_compat.cc
src/mp_script_reductions.h
src/mp_script_reductions.cc
src/mp_norm.h
src/mp_norm.cc
src/mp_det_inv.h
src/mp_det_inv.cc
src/mp_svd.h
src/mp_svd.cc
src/mp_rank_condition.h
src/mp_rank_condition.cc
src/mp_structured_eig.h
src/mp_structured_eig.cc
src/mp_general_eig.h
src/mp_general_eig.cc
src/mp_generalized_eig.h
src/mp_generalized_eig.cc
test/run_tests.m
test/script-compat/s00.tst
test/script-compat/s01.tst
test/script-compat/s02.tst
test/mrdivide.tst
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
test/m20_complex_probe.cc
test/mp_lapack_lu_test.cc
test/m21_rgetrf_probe.cc
test/m22_dependency_probe.cc
test/pivoted_qr.tst
test/release_closure.tst
test/norm.tst
test/mp_norm_test.cc
test/det_inv.tst
test/mp_det_inv_test.cc
test/svd.tst
test/mp_svd_test.cc
test/rank_condition.tst
test/mp_rank_condition_test.cc
test/mp_structured_eig_test.cc
test/eig_structured.tst
test/mp_general_eig_test.cc
test/eig_general.tst
test/mp_generalized_eig_test.cc
test/eig_generalized.tst
test/n07_closure.tst
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
tools/verify-release-candidate.sh
tools/dev-octave.sh
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
docs/complex-architecture.md
docs/milestones/M20-complex-architecture.md
docs/lu.md
docs/v0.1-api.md
docs/octave-compatibility.md
docs/ppa-plan.md
docs/release-checklist.md
docs/milestones/M21-lu.md
docs/milestones/M22-real-release-closure.md
docs/milestones/M23-v0.1-freeze.md
docs/norm.md
docs/milestones/N00-norm.md
docs/determinant-inverse.md
docs/milestones/N01-det-inv.md
docs/svd.md
docs/milestones/N02-svd.md
docs/rank-condition.md
docs/milestones/N03-rank-condition.md
docs/eig.md
docs/generalized-eig.md
docs/v0.3-api.md
docs/octave-script-compatibility.md
docs/goals/S00-S08-D03-status.md
reports/S00-report.md
docs/milestones/N04-eig-structured.md
docs/milestones/N05-eig-general.md
docs/milestones/N06-eig-generalized.md
reports/N05-report.md
reports/N06-report.md
reports/N07-report.md
docs/v0.1-release-manifest.md
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
  tools/build-package.sh tools/verify-release-candidate.sh; do
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
  echo "FAIL: M00-M23 tree checks failed" >&2
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

echo "PASS: M00-M23 tree checks"
