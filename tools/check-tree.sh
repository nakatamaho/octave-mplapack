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
NEWS.md
CONTRIBUTING.md
.gitignore
DESCRIPTION
INDEX
inst/@mp/mp.m
inst/@mp/disp.m
inst/@mp/char.m
inst/@mp/double.m
inst/@mp/plus.m
inst/@mp/minus.m
inst/@mp/times.m
inst/@mp/rdivide.m
inst/@mp/mtimes.m
inst/@mp/mldivide.m
inst/@mp/transpose.m
inst/@mp/ctranspose.m
inst/mpbits.m
inst/mpdigits.m
inst/mplapack_version.m
src/Makefile
src/mp_value.h
src/mp_value.cc
src/mp_convert.cc
src/mp_arithmetic.cc
src/mp_blas.cc
src/mp_lapack.cc
src/octave_bridge.cc
test/run_tests.m
test/constructor.tst
test/precision.tst
test/conversion.tst
test/arithmetic.tst
test/gemm.tst
test/gesv.tst
tools/check-format.sh
tools/check-tree.sh
tools/local-ci.sh
docs/architecture.md
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

for path in tools/check-tree.sh tools/check-format.sh tools/local-ci.sh; do
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

echo "PASS: M00 tree checks"
