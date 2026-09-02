#!/bin/sh

set -eu

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

qa_root=$(mktemp -d)

cleanup ()
{
  make -C "$repo_root/src" clean >/dev/null 2>&1 || true
  find "$qa_root" -depth -delete
}

trap cleanup EXIT
trap 'exit 1' HUP INT TERM

for command_name in git gh octave mkoctfile pkg-config c++ make python3 \
  ldd readelf nm tar gzip sha256sum; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "FAIL: mandatory M15 command is unavailable: $command_name" >&2
    exit 1
  fi
done

if ! gh auth status >/dev/null 2>&1; then
  echo "FAIL: mandatory M15 GitHub authentication is unavailable" >&2
  exit 1
fi

if ! pkg-config --exists 'mplapack_mpfr >= 3.0.0'; then
  echo "FAIL: mandatory MPLAPACK MPFR development interface is unavailable" >&2
  exit 1
fi

echo "PASS: mandatory M15 prerequisites"
tools/check-tree.sh
tools/check-format.sh

mplapack_include_dir=$(pkg-config --variable=includedir mplapack_mpfr)
if [ ! -f "$mplapack_include_dir/mplapack_mpfr_precision.h" ]; then
  echo "FAIL: installed MPLAPACK precision scope header is unavailable" >&2
  exit 1
fi
echo "PASS: installed MPLAPACK uniform-precision scope header"

make -C src clean
make -C src check-storage-sanitized
make -C src check-arithmetic-sanitized
make -C src check-matrix-sanitized
make -C src check-blas
make -C src check-lapack
make -C src check-inspection
make -C src check-elementwise
make -C src check-structure
make -C src check-concat
make -C src check-assignment
make -C src check-rgels
echo "PASS: M02-M15 ASan/UBSan/LSan scalar, matrix, Rgemm, Rgesv, Rgels, inspection, element-wise, structural, concatenation, and assignment QA"
make -C src clean

M01_REPO_ROOT=$repo_root octave --no-gui --quiet --no-init-file --eval '
  root = getenv ("M01_REPO_ROOT");
  pkg_private = fullfile (fileparts (which ("pkg")), "private");
  addpath (pkg_private);
  metadata = get_description (fullfile (root, "DESCRIPTION"));
  required = {"name", "version", "date", "title", "author", ...
              "maintainer", "description", "license"};
  assert (all (isfield (metadata, required)));
  assert (strcmp (metadata.name, "mplapack"));
  rmpath (pkg_private);
'
echo "PASS: Octave DESCRIPTION parser"

mplapack_version=$(pkg-config --modversion mplapack_mpfr)
mplapack_libdir=$(pkg-config --variable=libdir mplapack_mpfr)
mplapack_library=$mplapack_libdir/libmplapack_mpfr.so
export LD_LIBRARY_PATH=$mplapack_libdir:/usr/local/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

probe=$qa_root/mp_lapack_probe
c++ -std=c++17 -Wall -Wextra -Wpedantic \
  $(pkg-config --cflags mplapack_mpfr) test/mp_lapack_probe.cc \
  $(pkg-config --libs mplapack_mpfr) -o "$probe"
"$probe"
echo "PASS: installed MPLAPACK Rgesv precision probe"

rgels_probe=$qa_root/mp_lapack_rgels_probe
c++ -std=c++17 -Wall -Wextra -Wpedantic \
  $(pkg-config --cflags mplapack_mpfr) test/mp_lapack_rgels_probe.cc \
  $(pkg-config --libs mplapack_mpfr) -o "$rgels_probe"
"$rgels_probe"
echo "PASS: installed MPLAPACK Rgels precision probe"

if [ ! -f "$mplapack_library" ]; then
  echo "FAIL: MPLAPACK MPFR shared library is unavailable: $mplapack_library" >&2
  exit 1
fi

mplapack_ldd=$(ldd "$mplapack_library" 2>&1)
if printf '%s\n' "$mplapack_ldd" | grep -q 'not found'; then
  printf '%s\n' "$mplapack_ldd" >&2
  echo "FAIL: MPLAPACK has a missing shared dependency" >&2
  exit 1
fi

mplapack_relocations=$(ldd -r "$mplapack_library" 2>&1)
if printf '%s\n' "$mplapack_relocations" \
    | grep -Eq 'not found|undefined symbol'; then
  printf '%s\n' "$mplapack_relocations" >&2
  echo "FAIL: MPLAPACK has an unresolved relocation" >&2
  exit 1
fi

for dependency in libmpc libmpfr libgmp; do
  if ! readelf -d "$mplapack_library" \
      | grep NEEDED | grep -q "\[$dependency\.so"; then
    echo "FAIL: MPLAPACK DT_NEEDED lacks $dependency" >&2
    exit 1
  fi
done

mplapack_soname=$(readelf -d "$mplapack_library" \
  | sed -n 's/.*(SONAME).*\[\([^]]*\)\].*/\1/p')
if [ -z "$mplapack_soname" ]; then
  echo "FAIL: MPLAPACK shared library has no SONAME" >&2
  exit 1
fi

M01_MPLAPACK_SONAME=$mplapack_soname python3 - <<'PY'
import ctypes
import os

ctypes.CDLL(os.environ["M01_MPLAPACK_SONAME"])
print("PASS: clean MPLAPACK MPFR load")
PY

echo "PASS: MPLAPACK dependency relocations and DT_NEEDED"

make -C src clean
make -C src check-deps
make -C src

module=$repo_root/src/__mplapack_core__.oct
module_ldd=$(ldd "$module" 2>&1)
if printf '%s\n' "$module_ldd" | grep -q 'not found'; then
  printf '%s\n' "$module_ldd" >&2
  echo "FAIL: native module has a missing shared dependency" >&2
  exit 1
fi

if ! readelf -d "$module" | grep NEEDED \
    | grep -q '\[libmplapack_mpfr\.so'; then
  echo "FAIL: native module lacks a direct MPLAPACK MPFR dependency" >&2
  exit 1
fi

if ! nm -D -C "$module" | grep -Eq ' U Rlamch_mpfr\(char const\*\)$'; then
  echo "FAIL: native module lacks an unresolved Rlamch_mpfr reference" >&2
  exit 1
fi

if ! nm -D -C "$module" | grep -Eq ' U Rgemm\('; then
  echo "FAIL: native module lacks an unresolved Rgemm reference" >&2
  exit 1
fi

if ! nm -D -C "$module" | grep -Eq ' U Rgesv\('; then
  echo "FAIL: M09 native module lacks an unresolved Rgesv reference" >&2
  exit 1
fi

if ! nm -D -C "$module" | grep -Eq ' U Rgels\('; then
  echo "FAIL: M15 native module lacks an unresolved Rgels reference" >&2
  exit 1
fi

if readelf -d "$module" | grep NEEDED | grep -q 'libmplapack_mpfr_opt'; then
  echo "FAIL: M09 native module links the optimized MPFR backend" >&2
  exit 1
fi

module_relocations=$(ldd -r "$module" 2>&1)
if printf '%s\n' "$module_relocations" | grep -q 'not found'; then
  printf '%s\n' "$module_relocations" >&2
  echo "FAIL: native module relocation check found a missing library" >&2
  exit 1
fi

undefined_symbols=$qa_root/module-undefined-symbols
octave_symbols=$qa_root/octave-defined-symbols
printf '%s\n' "$module_relocations" \
  | sed -n 's/^undefined symbol: \([^[:space:]]*\).*/\1/p' \
  | LC_ALL=C sort -u > "$undefined_symbols"

octave_libdir=$(mkoctfile -p OCTLIBDIR)
for octave_library in "$octave_libdir/liboctinterp.so" \
  "$octave_libdir/liboctave.so"; do
  if [ ! -f "$octave_library" ]; then
    echo "FAIL: Octave development library is unavailable: $octave_library" >&2
    exit 1
  fi
done

nm -D --defined-only "$octave_libdir/liboctinterp.so" \
  "$octave_libdir/liboctave.so" \
  | awk 'NF >= 3 { sub (/@.*/, "", $3); print $3 }' \
  | LC_ALL=C sort -u > "$octave_symbols"

while IFS= read -r symbol; do
  [ -n "$symbol" ] || continue
  if ! grep -Fxq "$symbol" "$octave_symbols"; then
    echo "FAIL: native module has a non-Octave unresolved symbol: $symbol" >&2
    exit 1
  fi
done < "$undefined_symbols"

echo "PASS: native linkage and Octave-hosted relocations"

M01_REPO_ROOT=$repo_root MPLAPACK_EXPECTED_VERSION=$mplapack_version \
  octave --no-gui --quiet --no-init-file --eval '
    root = getenv ("M01_REPO_ROOT");
    addpath (fullfile (root, "src"));
    info = __mplapack_core__ ("version");
    disp (info);
    assert (strcmp (info.mplapack, getenv ("MPLAPACK_EXPECTED_VERSION")));
    assert (strcmp (info.backend, "mpfr"));
    assert (! isempty (info.mpfr));
    assert (info.probe_ok);
    assert (isfinite (info.probe_value) && info.probe_value > 0);
  '

M01_REPO_ROOT=$repo_root MPLAPACK_EXPECTED_VERSION=$mplapack_version \
  octave --no-gui --quiet --no-init-file --eval '
    root = getenv ("M01_REPO_ROOT");
    addpath (fullfile (root, "inst"));
    addpath (fullfile (root, "src"));
    public_path = which ("mplapack_version");
    native_path = which ("__mplapack_core__");
    disp (public_path);
    disp (native_path);
    assert (strncmp (public_path, root, length (root)));
    assert (strncmp (native_path, root, length (root)));
    info = mplapack_version ();
    assert (strcmp (info.mplapack, getenv ("MPLAPACK_EXPECTED_VERSION")));
    assert (info.probe_ok);
    run (fullfile (root, "test", "run_tests.m"));
  '

echo "PASS: direct native/public runtime probes"

M03_REPO_ROOT=$repo_root octave --no-gui --quiet --no-init-file --eval '
  root = getenv ("M03_REPO_ROOT");
  addpath (fullfile (root, "inst"));
  addpath (fullfile (root, "src"));
  run (fullfile (root, "test", "native_lifetime.m"));
  run (fullfile (root, "test", "public_lifetime.m"));
  run (fullfile (root, "test", "matrix_lifetime.m"));
'

M03_REPO_ROOT=$repo_root octave --no-gui --quiet --no-init-file --eval '
  root = getenv ("M03_REPO_ROOT");
  addpath (fullfile (root, "inst"));
  addpath (fullfile (root, "src"));
  values = cell (1, 250);
  for i = 1:numel (values)
    values{i} = __mplapack_core__ (
      "scalar_test_create", "0.125", [128, 256, 512](mod (i - 1, 3) + 1));
  endfor
  public_values = cell (1, 10000);
  for i = 1:numel (public_values)
    if (mod (i, 2) == 0)
      public_values{i} = mp ("0.1");
    else
      public_values{i} = mp (0.1);
    endif
  endfor
  assert (! __mplapack_core__ (
    "scalar_test_equal", public_values{1}, public_values{2}));
  assert (__mplapack_core__ ("module_test_locked"));
  fprintf ("PASS: native/public values left for shutdown destruction\n");
'
echo "PASS: M02/M03 source lifecycle, stress, and shutdown QA"

M04_REPO_ROOT=$repo_root octave --no-gui --quiet --no-init-file --eval '
  root = getenv ("M04_REPO_ROOT");
  addpath (fullfile (root, "inst"));
  addpath (fullfile (root, "src"));
  assert (mpbits () == uint64 (512));
  assert (mpdigits () == uint64 (154));
  mpbits (256);
  assert (mpbits () == uint64 (256));
  clear;
  assert (mpbits () == uint64 (256));
  clear functions;
  assert (mpbits () == uint64 (256));
  value = mp ("1");
  value_info = __mplapack_core__ ("scalar_test_info", value);
  assert (value_info.precision_bits == 256);
  for i = 1:10000
    bits = [64, 128, 256, 512, 1024](mod (i - 1, 5) + 1);
    assert (mpbits (bits) == uint64 (bits));
    assert (mpbits () == uint64 (bits));
    if (mod (i, 25) == 0)
      stress_value = mp ("0.125");
      stress_info = __mplapack_core__ (
        "scalar_test_info", stress_value);
      assert (stress_info.precision_bits == bits);
    endif
  endfor
  fprintf ("PASS: M04 clear and 10000-operation precision stress QA\n");
'

M04_REPO_ROOT=$repo_root octave --no-gui --quiet --no-init-file --eval '
  root = getenv ("M04_REPO_ROOT");
  addpath (fullfile (root, "inst"));
  addpath (fullfile (root, "src"));
  assert (mpbits () == uint64 (512));
  mpbits (1024);
  assert (mpbits () == uint64 (1024));
'

M04_REPO_ROOT=$repo_root octave --no-gui --quiet --no-init-file --eval '
  root = getenv ("M04_REPO_ROOT");
  addpath (fullfile (root, "inst"));
  addpath (fullfile (root, "src"));
  assert (mpbits () == uint64 (512));
  assert (mpdigits () == uint64 (154));
  mpdigits (100);
  assert (mpbits () == uint64 (333));
  value = mp ("1");
  value_info = __mplapack_core__ ("scalar_test_info", value);
  assert (value_info.precision_bits == 333);
'
echo "PASS: M04 set-before-object, fresh-process reset, and digit construction QA"

M05_REPO_ROOT=$repo_root LC_ALL=ja_JP.utf8 \
  octave --no-gui --quiet --no-init-file --eval '
    root = getenv ("M05_REPO_ROOT");
    addpath (fullfile (root, "inst"));
    addpath (fullfile (root, "src"));
    mpbits (512);
    value = mp ("0.1");
    text = char (value);
    assert (! isempty (strfind (text, ".")));
    assert (isempty (strfind (text, ",")));
    reconstructed = mp (text);
    assert (__mplapack_core__ (
      "scalar_test_equal", value, reconstructed));
    fprintf ("PASS: M05 locale-independent canonical text\n");
  '

M05_REPO_ROOT=$repo_root octave --no-gui --quiet --no-init-file --eval '
  root = getenv ("M05_REPO_ROOT");
  addpath (fullfile (root, "inst"));
  addpath (fullfile (root, "src"));
  precisions = [128, 256, 333, 512, 1024];
  for i = 1:10000
    bits = precisions(mod (i - 1, numel (precisions)) + 1);
    mpbits (bits);
    value = mp ("0.1");
    text = char (value);
    assert (ischar (text) && rows (text) == 1);
    assert (double (value) == 0.1);
    if (mod (i, 1000) == 0)
      reconstructed = mp (text);
      assert (__mplapack_core__ (
        "scalar_test_equal", value, reconstructed));
    endif
  endfor
  shutdown_text = mp ("1.234567890123456789");
  shutdown_double = mp (-0.0);
  assert (! isempty (char (shutdown_text)));
  assert (typecast (double (shutdown_double), "uint64")
          == typecast (-0.0, "uint64"));
  fprintf ("PASS: M05 10000-operation formatting/conversion stress and shutdown QA\n");
'

M06_REPO_ROOT=$repo_root octave --no-gui --quiet --no-init-file --eval '
  root = getenv ("M06_REPO_ROOT");
  addpath (fullfile (root, "inst"));
  addpath (fullfile (root, "src"));
  precisions = [32, 128, 256, 333, 512, 1024];
  value = mp ("1");
  for i = 1:10000
    bits = precisions(mod (i - 1, numel (precisions)) + 1);
    mpbits (bits);
    rhs = mp ("0.125");
    switch (mod (i - 1, 4))
      case 0
        value = value + rhs;
      case 1
        value = value - 0.125;
      case 2
        value = value .* rhs;
      otherwise
        value = value ./ 0.125;
    endswitch
    assert (strcmp (class (value), "mp"));
  endfor
  assert (! isempty (char (value)));
  assert (__mplapack_core__ ("module_test_locked"));
  fprintf ("PASS: M06 10000-operation public arithmetic stress QA\n");
'

M07_REPO_ROOT=$repo_root octave --no-gui --quiet --no-init-file --eval '
  root = getenv ("M07_REPO_ROOT");
  addpath (fullfile (root, "inst"));
  addpath (fullfile (root, "src"));
  assert (mpbits () == uint64 (512));
  for i = 1:1000
    rows_count = mod (i, 7);
    columns_count = mod (i * 3, 9);
    mpbits ([32, 128, 256, 333, 512, 1024](mod (i - 1, 6) + 1));
    if (rows_count * columns_count == 0)
      value = zeros (rows_count, columns_count);
    else
      value = reshape (1:(rows_count * columns_count),
                       rows_count, columns_count);
    endif
    matrix = mp (value);
    assert (size (matrix), [rows_count, columns_count]);
    info = __mplapack_core__ ("matrix_test_info", matrix);
    assert (info.all_elements_same_precision);
  endfor
  large = mp (ones (64, 64));
  large_copy = mp (large);
  assert (size (large_copy), [64, 64]);
  assert (__mplapack_core__ ("module_test_locked"));
  fprintf ("PASS: M07 1000-matrix lifecycle and 64x64 public smoke QA\n");
'

make -C src clean
negative_log=$qa_root/negative-dependency.log
if make -C src check-deps \
    MPLAPACK_PC=mplapack_mpfr_does_not_exist >"$negative_log" 2>&1; then
  echo "FAIL: missing MPLAPACK pkg-config module did not fail" >&2
  exit 1
fi
if ! grep -q 'mplapack_mpfr_does_not_exist >= 3.0.0 is required' \
    "$negative_log"; then
  sed -n '1,120p' "$negative_log" >&2
  echo "FAIL: missing dependency diagnostic was unclear" >&2
  exit 1
fi
echo "PASS: negative dependency check"

make -C src check-deps
make -C src
M01_REPO_ROOT=$repo_root MPLAPACK_EXPECTED_VERSION=$mplapack_version \
  octave --no-gui --quiet --no-init-file --eval '
    root = getenv ("M01_REPO_ROOT");
    addpath (fullfile (root, "inst"));
    addpath (fullfile (root, "src"));
    info = __mplapack_core__ ("version");
    assert (strcmp (info.mplapack, getenv ("MPLAPACK_EXPECTED_VERSION")));
    assert (info.probe_ok);
    run (fullfile (root, "test", "run_tests.m"));
    value = __mplapack_core__ ("scalar_test_create", "0.1", 512);
    value_info = __mplapack_core__ ("scalar_test_info", value);
    assert (value_info.precision_bits == 512);
    assert (__mplapack_core__ (
      "scalar_test_equal_string", value, "0.1"));
    decimal = mp ("0.1");
    binary64 = mp (0.1);
    assert (! __mplapack_core__ (
      "scalar_test_equal", decimal, binary64));
    assert (__mplapack_core__ (
      "scalar_test_equal_string", decimal, "0.1"));
    assert (__mplapack_core__ (
      "scalar_test_equal_double", binary64, 0.1));
  '
echo "PASS: clean rebuild #2 and M01-M15 re-test"

make -C src clean
tools/build-package.sh
package_name=$(sed -n 's/^Name: *//p' DESCRIPTION)
package_version=$(sed -n 's/^Version: *//p' DESCRIPTION)
package_dir=$package_name-$package_version
archive=$repo_root/dist/$package_dir.tar.gz
first_hash=$(sha256sum "$archive" | awk '{ print $1 }')
tools/build-package.sh
second_hash=$(sha256sum "$archive" | awk '{ print $1 }')
if [ "$first_hash" != "$second_hash" ]; then
  echo "FAIL: package archive generation is not deterministic" >&2
  exit 1
fi

archive_listing=$qa_root/archive-listing
tar tzf "$archive" > "$archive_listing"
if [ "$(cut -d/ -f1 "$archive_listing" | LC_ALL=C sort -u)" != "$package_dir" ]; then
  echo "FAIL: package archive lacks one expected top-level directory" >&2
  exit 1
fi

for required_path in DESCRIPTION COPYING INDEX inst/ src/ \
  src/mp_scalar_storage.h src/mp_scalar_storage.cc \
  src/mp_precision.h src/mp_precision.cc src/mp_value.h src/mp_value.cc \
  inst/@mp/horzcat.m inst/@mp/vertcat.m test/native_value.tst \
  inst/mpbits.m inst/mpdigits.m test/constructor.tst test/precision.tst \
  test/native_lifetime.m test/public_lifetime.m \
  test/mp_scalar_storage_test.cc docs/public-mp-design.md \
  test/conversion.tst docs/conversion-display.md \
  inst/@mp/char.m inst/@mp/double.m inst/@mp/disp.m \
  src/mp_arithmetic.cc test/mp_scalar_arithmetic_test.cc \
  test/arithmetic.tst docs/scalar-arithmetic.md \
  inst/@mp/uplus.m inst/@mp/uminus.m \
  src/mp_matrix_storage.h src/mp_matrix_storage.cc \
  src/mp_matrix_value.h src/mp_matrix_value.cc \
  test/mp_matrix_storage_test.cc test/matrix_storage.tst \
  test/matrix_lifetime.m \
  src/mp_blas.h src/mp_blas.cc test/mp_blas_test.cc test/gemm.tst \
  docs/matrix-multiplication.md \
  src/mp_lapack.h src/mp_lapack.cc test/mp_lapack_test.cc \
  test/mp_lapack_probe.cc test/mp_lapack_rgels_probe.cc \
  test/mp_lapack_rgels_test.cc test/gesv.tst test/rgels.tst \
  docs/linear-solve.md docs/rectangular-solve.md \
  src/mp_matrix_inspection.h src/mp_matrix_inspection.cc \
  test/mp_matrix_inspection_test.cc test/matrix_inspection.tst \
  docs/matrix-inspection.md inst/@mp/end.m \
  src/mp_matrix_arithmetic.h src/mp_matrix_arithmetic.cc \
  test/mp_matrix_arithmetic_test.cc test/elementwise.tst \
  docs/elementwise-arithmetic.md docs/milestones/M11-elementwise-arithmetic.md \
  src/mp_matrix_structure.h src/mp_matrix_structure.cc \
  test/mp_matrix_structure_test.cc test/structure.tst \
  docs/matrix-structure.md docs/milestones/M12-transpose-reshape.md \
  inst/@mp/transpose.m inst/@mp/ctranspose.m inst/@mp/reshape.m \
  src/mp_matrix_concat.h src/mp_matrix_concat.cc \
  test/mp_matrix_concat_test.cc test/concat.tst \
  docs/matrix-concatenation.md docs/milestones/M13-concatenation.md \
  src/mp_matrix_assignment.h src/mp_matrix_assignment.cc \
  test/mp_matrix_assignment_test.cc test/assignment.tst \
  docs/matrix-assignment.md docs/milestones/M14-indexed-assignment.md \
  docs/milestones/M15-rgels.md \
  docs/dense-matrix-design.md inst/@mp/size.m inst/@mp/rows.m \
  inst/@mp/columns.m inst/@mp/numel.m inst/@mp/ndims.m \
  inst/@mp/isempty.m inst/@mp/subsref.m inst/@mp/subsasgn.m \
  inst/@mp/mrdivide.m; do
  if ! grep -Eq "^$package_dir/$required_path" "$archive_listing"; then
    echo "FAIL: package archive lacks $required_path" >&2
    exit 1
  fi
done

if grep -Eq '(^|/)(\.git|dist|\.build-m02|\.build-m06|\.build-m07|\.build-m08|\.build-m09|\.build-m10|\.build-m11|\.build-m12|\.build-m13|\.build-m14|\.build-m15)(/|$)|\.(oct|o|lo)$|/\.(libs|deps)/' \
    "$archive_listing"; then
  echo "FAIL: package archive contains a generated or private path" >&2
  exit 1
fi

if grep -q '^/' "$archive_listing"; then
  echo "FAIL: package archive contains an absolute path" >&2
  exit 1
fi

echo "PASS: deterministic source package contents"

test_home=$qa_root/home
neutral_dir=$qa_root/work
mkdir -p "$test_home" "$neutral_dir"

(
  cd "$neutral_dir"
  HOME=$test_home M01_ARCHIVE=$archive \
    octave --no-gui --quiet --no-init-file --eval '
      archive = getenv ("M01_ARCHIVE");
      pkg ("install", "-verbose", archive);
      [description, status] = pkg ("describe", "mplapack");
      assert (numel (description) == 1);
      assert (any (strcmp (status, {"Loaded", "Not loaded"})));
      metadata = description{1};
      required = {"name", "version", "date", "description"};
      assert (all (isfield (metadata, required)));
    '
)

(
  cd "$neutral_dir"
  HOME=$test_home M01_REPO_ROOT=$repo_root \
    MPLAPACK_EXPECTED_VERSION=$mplapack_version \
    octave --no-gui --quiet --no-init-file --eval '
      root = getenv ("M01_REPO_ROOT");
      pkg ("load", "mplapack");
      assert (test (fullfile (root, "test", "concat.tst")));
      assert (test (fullfile (root, "test", "assignment.tst")));
      public_path = which ("mplapack_version");
      native_path = which ("__mplapack_core__");
      constructor_path = which ("mp");
      mpbits_path = which ("mpbits");
      mpdigits_path = which ("mpdigits");
      char_method_path = file_in_loadpath ("@mp/char.m");
      double_method_path = file_in_loadpath ("@mp/double.m");
      disp_method_path = file_in_loadpath ("@mp/disp.m");
      plus_method_path = file_in_loadpath ("@mp/plus.m");
      minus_method_path = file_in_loadpath ("@mp/minus.m");
      times_method_path = file_in_loadpath ("@mp/times.m");
      rdivide_method_path = file_in_loadpath ("@mp/rdivide.m");
      uplus_method_path = file_in_loadpath ("@mp/uplus.m");
      uminus_method_path = file_in_loadpath ("@mp/uminus.m");
      horzcat_method_path = file_in_loadpath ("@mp/horzcat.m");
      vertcat_method_path = file_in_loadpath ("@mp/vertcat.m");
      size_method_path = file_in_loadpath ("@mp/size.m");
      mldivide_method_path = file_in_loadpath ("@mp/mldivide.m");
      subsref_method_path = file_in_loadpath ("@mp/subsref.m");
      subsasgn_method_path = file_in_loadpath ("@mp/subsasgn.m");
      end_method_path = file_in_loadpath ("@mp/end.m");
      fprintf ("installed mplapack_version: %s\n", public_path);
      fprintf ("installed __mplapack_core__: %s\n", native_path);
      fprintf ("installed mp: %s\n", constructor_path);
      fprintf ("installed mpbits: %s\n", mpbits_path);
      fprintf ("installed mpdigits: %s\n", mpdigits_path);
      fprintf ("installed @mp/char: %s\n", char_method_path);
      fprintf ("installed @mp/double: %s\n", double_method_path);
      fprintf ("installed @mp/disp: %s\n", disp_method_path);
      fprintf ("installed @mp/plus: %s\n", plus_method_path);
      fprintf ("installed @mp/uplus: %s\n", uplus_method_path);
      fprintf ("installed @mp/uminus: %s\n", uminus_method_path);
      fprintf ("installed @mp/size: %s\n", size_method_path);
      fprintf ("installed @mp/subsref: %s\n", subsref_method_path);
      fprintf ("installed @mp/end: %s\n", end_method_path);
      assert (! strncmp (public_path, root, length (root)));
      assert (! strncmp (native_path, root, length (root)));
      assert (! strncmp (constructor_path, root, length (root)));
      assert (! strncmp (mpbits_path, root, length (root)));
      assert (! strncmp (mpdigits_path, root, length (root)));
      assert (! strncmp (char_method_path, root, length (root)));
      assert (! strncmp (double_method_path, root, length (root)));
      assert (! strncmp (disp_method_path, root, length (root)));
      assert (! strncmp (plus_method_path, root, length (root)));
      assert (! strncmp (minus_method_path, root, length (root)));
      assert (! strncmp (times_method_path, root, length (root)));
      assert (! strncmp (rdivide_method_path, root, length (root)));
      assert (! strncmp (uplus_method_path, root, length (root)));
      assert (! strncmp (uminus_method_path, root, length (root)));
      assert (! strncmp (horzcat_method_path, root, length (root)));
      assert (! strncmp (vertcat_method_path, root, length (root)));
      assert (! strncmp (size_method_path, root, length (root)));
      assert (! strncmp (mldivide_method_path, root, length (root)));
      assert (! strncmp (subsref_method_path, root, length (root)));
      assert (! strncmp (subsasgn_method_path, root, length (root)));
      assert (! strncmp (end_method_path, root, length (root)));
      info = mplapack_version ();
      disp (info);
      assert (strcmp (info.mplapack, getenv ("MPLAPACK_EXPECTED_VERSION")));
      assert (strcmp (info.backend, "mpfr"));
      assert (! isempty (info.mpfr));
      assert (info.probe_ok);
      assert (__mplapack_core__ ("module_test_locked"));
      run (fullfile (root, "test", "native_lifetime.m"));
      run (fullfile (root, "test", "public_lifetime.m"));
      run (fullfile (root, "test", "matrix_lifetime.m"));
      assert (__mplapack_core__ ("module_test_locked"));
      assert (test (fullfile (root, "test", "native_value.tst")));
      assert (test (fullfile (root, "test", "constructor.tst")));
      assert (test (fullfile (root, "test", "precision.tst")));
      assert (test (fullfile (root, "test", "conversion.tst")));
      assert (test (fullfile (root, "test", "arithmetic.tst")));
      assert (test (fullfile (root, "test", "matrix_storage.tst")));
      assert (test (fullfile (root, "test", "gemm.tst")));
      assert (test (fullfile (root, "test", "gesv.tst")));
      assert (test (fullfile (root, "test", "matrix_inspection.tst")));
      assert (test (fullfile (root, "test", "elementwise.tst")));
      assert (test (fullfile (root, "test", "structure.tst")));
      assert (test (fullfile (root, "test", "concat.tst")));
      assert (test (fullfile (root, "test", "assignment.tst")));
      assert (isempty (which ("scalar_test_create")));
      assert (isempty (which ("scalar_create_text")));
      assert (mpbits () == uint64 (512));
      assert (mpdigits () == uint64 (154));
      mpbits (256);
      state_value = mp ("1");
      state_info = __mplapack_core__ (
        "scalar_test_info", state_value);
      assert (state_info.precision_bits == 256);
      unload_value = mp ("-2.25");
      unload_matrix = mp ({"1", "2"; "3", "4"});
      unload_result = unload_value + mp ("0.25");
      unload_result_text = char (unload_result);
      unload_text = char (unload_value);
      unload_double = double (unload_value);
      assert (evalc ("disp (unload_value)"), [unload_text, "\n"]);
      pkg ("unload", "mplapack");
      assert (strcmp (class (unload_value), "mp"));
      assert (strcmp (class (unload_matrix), "mp"));
      pkg ("load", "mplapack");
      assert (size (unload_matrix), [2, 2]);
      unload_matrix_info = __mplapack_core__ (
        "matrix_test_info", unload_matrix);
      assert (unload_matrix_info.precision_bits == 256);
      assert (__mplapack_core__ (
        "matrix_test_element_equal_text", unload_matrix, 2, 2, "4"));
      assert (char (unload_value), unload_text);
      assert (char (unload_result), unload_result_text);
      assert (double (unload_value), unload_double);
      assert (evalc ("disp (unload_value)"), [unload_text, "\n"]);
      assert (mpbits () == uint64 (256));
      assert (mpdigits () == uint64 (77));
      reloaded_state_value = mp ("1");
      reloaded_state_info = __mplapack_core__ (
        "scalar_test_info", reloaded_state_value);
      assert (reloaded_state_info.precision_bits == 256);
      unload_info = __mplapack_core__ (
        "scalar_test_info", unload_value);
      assert (unload_info.precision_bits == 256);
      assert (__mplapack_core__ (
        "scalar_test_equal_string", unload_value, "-2.25"));
      clear unload_value unload_result unload_info state_value state_info;
      clear unload_matrix unload_matrix_info;
      clear reloaded_state_value reloaded_state_info;
      destroy_while_unloaded = mp ("1.5");
      destroy_matrix_while_unloaded = mp ([1, 2; 3, 4]);
      pkg ("unload", "mplapack");
      assert (strcmp (class (destroy_while_unloaded), "mp"));
      clear destroy_while_unloaded;
      clear destroy_matrix_while_unloaded;
      pkg ("load", "mplapack");
      reloaded_value = __mplapack_core__ (
        "scalar_test_create", "1.5", 256);
      reloaded_info = __mplapack_core__ (
        "scalar_test_info", reloaded_value);
      assert (reloaded_info.precision_bits == 256);
      assert (__mplapack_core__ ("module_test_locked"));
      clear reloaded_value;
      pkg ("unload", "mplapack");
      pkg ("uninstall", "mplapack");
    '
)

(
  cd "$neutral_dir"
  HOME=$test_home octave --no-gui --quiet --no-init-file --eval '
      assert (isempty (which ("mp")));
      assert (isempty (which ("mpbits")));
      assert (isempty (which ("mpdigits")));
      assert (isempty (which ("mplapack_version")));
      assert (isempty (which ("__mplapack_core__")));
  '
)

(
  cd "$neutral_dir"
  HOME=$test_home M01_ARCHIVE=$archive \
    octave --no-gui --quiet --no-init-file --eval '
      pkg ("install", getenv ("M01_ARCHIVE"));
    '
)

(
  cd "$neutral_dir"
HOME=$test_home M01_REPO_ROOT=$repo_root \
    MPLAPACK_EXPECTED_VERSION=$mplapack_version \
    octave --no-gui --quiet --no-init-file --eval '
      pkg ("load", "mplapack");
      root = getenv ("M01_REPO_ROOT");
      public_path = which ("mplapack_version");
      native_path = which ("__mplapack_core__");
      constructor_path = which ("mp");
      mpbits_path = which ("mpbits");
      mpdigits_path = which ("mpdigits");
      char_method_path = file_in_loadpath ("@mp/char.m");
      double_method_path = file_in_loadpath ("@mp/double.m");
      disp_method_path = file_in_loadpath ("@mp/disp.m");
      plus_method_path = file_in_loadpath ("@mp/plus.m");
      minus_method_path = file_in_loadpath ("@mp/minus.m");
      times_method_path = file_in_loadpath ("@mp/times.m");
      rdivide_method_path = file_in_loadpath ("@mp/rdivide.m");
      uplus_method_path = file_in_loadpath ("@mp/uplus.m");
      uminus_method_path = file_in_loadpath ("@mp/uminus.m");
      size_method_path = file_in_loadpath ("@mp/size.m");
      mldivide_method_path = file_in_loadpath ("@mp/mldivide.m");
      subsref_method_path = file_in_loadpath ("@mp/subsref.m");
      subsasgn_method_path = file_in_loadpath ("@mp/subsasgn.m");
      end_method_path = file_in_loadpath ("@mp/end.m");
      horzcat_method_path = file_in_loadpath ("@mp/horzcat.m");
      vertcat_method_path = file_in_loadpath ("@mp/vertcat.m");
      assert (! strncmp (public_path, root, length (root)));
      assert (! strncmp (native_path, root, length (root)));
      assert (! strncmp (constructor_path, root, length (root)));
      assert (! strncmp (mpbits_path, root, length (root)));
      assert (! strncmp (mpdigits_path, root, length (root)));
      assert (! strncmp (char_method_path, root, length (root)));
      assert (! strncmp (double_method_path, root, length (root)));
      assert (! strncmp (disp_method_path, root, length (root)));
      assert (! strncmp (plus_method_path, root, length (root)));
      assert (! strncmp (minus_method_path, root, length (root)));
      assert (! strncmp (times_method_path, root, length (root)));
      assert (! strncmp (rdivide_method_path, root, length (root)));
      assert (! strncmp (uplus_method_path, root, length (root)));
      assert (! strncmp (uminus_method_path, root, length (root)));
      assert (! strncmp (size_method_path, root, length (root)));
      assert (! strncmp (mldivide_method_path, root, length (root)));
      assert (! strncmp (subsref_method_path, root, length (root)));
      assert (! strncmp (end_method_path, root, length (root)));
      assert (! strncmp (horzcat_method_path, root, length (root)));
      assert (! strncmp (vertcat_method_path, root, length (root)));
      assert (mpbits () == uint64 (512));
      assert (mpdigits () == uint64 (154));
      info = mplapack_version ();
      assert (strcmp (info.mplapack, getenv ("MPLAPACK_EXPECTED_VERSION")));
      assert (info.probe_ok);
      shutdown_value = __mplapack_core__ (
        "scalar_test_create", "0.1", 512);
      shutdown_info = __mplapack_core__ (
        "scalar_test_info", shutdown_value);
      assert (shutdown_info.precision_bits == 512);
      assert (__mplapack_core__ (
        "scalar_test_equal_string", shutdown_value, "0.1"));
      assert (__mplapack_core__ ("module_test_locked"));
      decimal = mp ("0.1");
      binary64 = mp (0.1);
      assert (strcmp (class (decimal), "mp"));
      assert (size (decimal), [1, 1]);
      assert (! __mplapack_core__ (
        "scalar_test_equal", decimal, binary64));
      assert (__mplapack_core__ (
        "scalar_test_equal_string", decimal, "0.1"));
      assert (__mplapack_core__ (
        "scalar_test_equal_double", binary64, 0.1));
      assert (mpdigits (100) == uint64 (100));
      assert (mpbits () == uint64 (333));
      precision_value = mp ("1");
      precision_info = __mplapack_core__ (
        "scalar_test_info", precision_value);
      assert (precision_info.precision_bits == 333);
      conversion_value = mp ("0.1");
      conversion_text = char (conversion_value);
      conversion_round_trip = mp (conversion_text);
      assert (__mplapack_core__ (
        "scalar_test_equal", conversion_value, conversion_round_trip));
      assert (double (conversion_value), 0.1);
      assert (evalc ("disp (conversion_value)"),
              [conversion_text, "\n"]);
      arithmetic_lhs = mp ("1.25");
      arithmetic_rhs = mp ("0.5");
      arithmetic_result = arithmetic_lhs + arithmetic_rhs;
      assert (__mplapack_core__ (
        "scalar_test_equal_string", arithmetic_result, "1.75"));
      assert (__mplapack_core__ (
        "scalar_test_info", arithmetic_result).precision_bits == 333);
      assert (__mplapack_core__ (
        "scalar_test_equal_string", arithmetic_lhs .* arithmetic_rhs,
        "0.625"));
      installed_text_matrix = mp ({"1", "2"; "3", "4"});
      installed_double_matrix = mp ([1, 2; 3, 4]);
      assert (size (installed_text_matrix), [2, 2]);
      assert (rows (installed_double_matrix), 2);
      assert (columns (installed_double_matrix), 2);
      assert (numel (installed_double_matrix), 4);
      assert (__mplapack_core__ (
        "matrix_test_element_equal", installed_text_matrix, 2, 2,
        installed_double_matrix, 2, 2));
      installed_product = installed_text_matrix * installed_double_matrix;
      assert (__mplapack_core__ (
        "matrix_test_element_equal_text", installed_product, 1, 1, "7"));
      assert (__mplapack_core__ (
        "matrix_test_element_equal_text", installed_product, 2, 2, "22"));
      installed_sum = installed_text_matrix + installed_double_matrix;
      assert (__mplapack_core__ (
        "matrix_test_element_equal_text", installed_sum, 1, 1, "2"));
      assert (__mplapack_core__ (
        "matrix_test_element_equal_text", installed_sum, 2, 2, "8"));
      installed_transpose = transpose (installed_text_matrix);
      assert (size (installed_transpose), [2, 2]);
      installed_reshape = reshape (installed_text_matrix, 1, 4);
      assert (size (installed_reshape), [1, 4]);
      installed_horzcat = [installed_text_matrix, installed_double_matrix];
      installed_vertcat = [installed_text_matrix; installed_double_matrix];
      assert (size (installed_horzcat), [2, 4]);
      assert (size (installed_vertcat), [4, 2]);
      assert (__mplapack_core__ (
        "matrix_test_element_equal_text", installed_horzcat, 1, 3, "1"));
      assert (__mplapack_core__ (
        "matrix_test_element_equal_text", installed_vertcat, 3, 1, "1"));
      installed_solution = installed_text_matrix \ mp ({"3"; "7"});
      assert (__mplapack_core__ (
        "matrix_test_element_double", installed_solution, 1, 1), 1);
      assert (__mplapack_core__ (
        "matrix_test_element_double", installed_solution, 2, 1), 1);
      installed_rectangular = mp ({"1", "0"; "0", "1"; "1", "1"});
      installed_rectangular_rhs = mp ({"0"; "1"; "4"});
      installed_rectangular_solution = installed_rectangular \ installed_rectangular_rhs;
      assert (size (installed_rectangular_solution), [2, 1]);
      assert (__mplapack_core__ (
        "matrix_test_element_double", installed_rectangular_solution, 1, 1), 1);
      assert (__mplapack_core__ (
        "matrix_test_element_double", installed_rectangular_solution, 2, 1), 2);
      fprintf ("reinstalled mplapack_version: %s\n", public_path);
      fprintf ("reinstalled __mplapack_core__: %s\n", native_path);
      fprintf ("reinstalled mp: %s\n", constructor_path);
      fprintf ("reinstalled mpbits: %s\n", mpbits_path);
      fprintf ("reinstalled mpdigits: %s\n", mpdigits_path);
      fprintf ("reinstalled @mp/char: %s\n", char_method_path);
      fprintf ("reinstalled @mp/double: %s\n", double_method_path);
      fprintf ("reinstalled @mp/disp: %s\n", disp_method_path);
      fprintf ("reinstalled @mp/plus: %s\n", plus_method_path);
      fprintf ("reinstalled @mp/minus: %s\n", minus_method_path);
      fprintf ("reinstalled @mp/times: %s\n", times_method_path);
      fprintf ("reinstalled @mp/rdivide: %s\n", rdivide_method_path);
      fprintf ("reinstalled @mp/uplus: %s\n", uplus_method_path);
      fprintf ("reinstalled @mp/uminus: %s\n", uminus_method_path);
      fprintf ("reinstalled @mp/size: %s\n", size_method_path);
      fprintf ("reinstalled @mp/subsref: %s\n", subsref_method_path);
      fprintf ("reinstalled @mp/subsasgn: %s\n", subsasgn_method_path);
      fprintf ("reinstalled @mp/end: %s\n", end_method_path);
      fprintf ("reinstalled @mp/horzcat: %s\n", horzcat_method_path);
      fprintf ("reinstalled @mp/vertcat: %s\n", vertcat_method_path);
      fprintf ("PASS: installed scalar/matrix values left for shutdown destruction\n");
    '
)

echo "PASS: isolated package M01-M15 install, matrix/Rgemm/Rgesv/Rgels/inspection/element-wise/structure/concatenation/assignment QA, unload, uninstall, and reinstall"
make -C src clean
echo "PASS: M15 local CI"
