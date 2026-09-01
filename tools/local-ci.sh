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
    echo "FAIL: mandatory M05 command is unavailable: $command_name" >&2
    exit 1
  fi
done

if ! gh auth status >/dev/null 2>&1; then
  echo "FAIL: mandatory M05 GitHub authentication is unavailable" >&2
  exit 1
fi

if ! pkg-config --exists 'mplapack_mpfr >= 3.0.0'; then
  echo "FAIL: mandatory MPLAPACK MPFR development interface is unavailable" >&2
  exit 1
fi

echo "PASS: mandatory M05 prerequisites"
tools/check-tree.sh
tools/check-format.sh

make -C src clean
make -C src check-storage-sanitized
echo "PASS: M02/M03/M04/M05 ASan/UBSan/LSan storage and conversion QA"
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
echo "PASS: clean rebuild #2 and M01/M02/M03/M04/M05 re-test"

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
  inst/@mp/char.m inst/@mp/double.m inst/@mp/disp.m; do
  if ! grep -Eq "^$package_dir/$required_path" "$archive_listing"; then
    echo "FAIL: package archive lacks $required_path" >&2
    exit 1
  fi
done

if grep -Eq '(^|/)(\.git|dist|\.build-m02)(/|$)|\.(oct|o|lo)$|/\.(libs|deps)/' \
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
      public_path = which ("mplapack_version");
      native_path = which ("__mplapack_core__");
      constructor_path = which ("mp");
      mpbits_path = which ("mpbits");
      mpdigits_path = which ("mpdigits");
      char_method_path = file_in_loadpath ("@mp/char.m");
      double_method_path = file_in_loadpath ("@mp/double.m");
      disp_method_path = file_in_loadpath ("@mp/disp.m");
      fprintf ("installed mplapack_version: %s\n", public_path);
      fprintf ("installed __mplapack_core__: %s\n", native_path);
      fprintf ("installed mp: %s\n", constructor_path);
      fprintf ("installed mpbits: %s\n", mpbits_path);
      fprintf ("installed mpdigits: %s\n", mpdigits_path);
      fprintf ("installed @mp/char: %s\n", char_method_path);
      fprintf ("installed @mp/double: %s\n", double_method_path);
      fprintf ("installed @mp/disp: %s\n", disp_method_path);
      assert (! strncmp (public_path, root, length (root)));
      assert (! strncmp (native_path, root, length (root)));
      assert (! strncmp (constructor_path, root, length (root)));
      assert (! strncmp (mpbits_path, root, length (root)));
      assert (! strncmp (mpdigits_path, root, length (root)));
      assert (! strncmp (char_method_path, root, length (root)));
      assert (! strncmp (double_method_path, root, length (root)));
      assert (! strncmp (disp_method_path, root, length (root)));
      info = mplapack_version ();
      disp (info);
      assert (strcmp (info.mplapack, getenv ("MPLAPACK_EXPECTED_VERSION")));
      assert (strcmp (info.backend, "mpfr"));
      assert (! isempty (info.mpfr));
      assert (info.probe_ok);
      assert (__mplapack_core__ ("module_test_locked"));
      run (fullfile (root, "test", "native_lifetime.m"));
      run (fullfile (root, "test", "public_lifetime.m"));
      assert (__mplapack_core__ ("module_test_locked"));
      assert (test (fullfile (root, "test", "native_value.tst")));
      assert (test (fullfile (root, "test", "constructor.tst")));
      assert (test (fullfile (root, "test", "precision.tst")));
      assert (test (fullfile (root, "test", "conversion.tst")));
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
      unload_text = char (unload_value);
      unload_double = double (unload_value);
      assert (evalc ("disp (unload_value)"), [unload_text, "\n"]);
      pkg ("unload", "mplapack");
      assert (strcmp (class (unload_value), "mp"));
      pkg ("load", "mplapack");
      assert (char (unload_value), unload_text);
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
      clear unload_value unload_info state_value state_info;
      clear reloaded_state_value reloaded_state_info;
      destroy_while_unloaded = mp ("1.5");
      pkg ("unload", "mplapack");
      assert (strcmp (class (destroy_while_unloaded), "mp"));
      clear destroy_while_unloaded;
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
      public_path = which ("mplapack_version");
      native_path = which ("__mplapack_core__");
      constructor_path = which ("mp");
      mpbits_path = which ("mpbits");
      mpdigits_path = which ("mpdigits");
      char_method_path = file_in_loadpath ("@mp/char.m");
      double_method_path = file_in_loadpath ("@mp/double.m");
      disp_method_path = file_in_loadpath ("@mp/disp.m");
      root = getenv ("M01_REPO_ROOT");
      assert (! strncmp (public_path, root, length (root)));
      assert (! strncmp (native_path, root, length (root)));
      assert (! strncmp (constructor_path, root, length (root)));
      assert (! strncmp (mpbits_path, root, length (root)));
      assert (! strncmp (mpdigits_path, root, length (root)));
      assert (! strncmp (char_method_path, root, length (root)));
      assert (! strncmp (double_method_path, root, length (root)));
      assert (! strncmp (disp_method_path, root, length (root)));
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
      fprintf ("reinstalled mplapack_version: %s\n", public_path);
      fprintf ("reinstalled __mplapack_core__: %s\n", native_path);
      fprintf ("reinstalled mp: %s\n", constructor_path);
      fprintf ("reinstalled mpbits: %s\n", mpbits_path);
      fprintf ("reinstalled mpdigits: %s\n", mpdigits_path);
      fprintf ("reinstalled @mp/char: %s\n", char_method_path);
      fprintf ("reinstalled @mp/double: %s\n", double_method_path);
      fprintf ("reinstalled @mp/disp: %s\n", disp_method_path);
      fprintf ("PASS: installed native/public values left for shutdown destruction\n");
    '
)

echo "PASS: isolated package M01-M05 install, conversion, unload, uninstall, and reinstall"
make -C src clean
echo "PASS: M05 local CI"
