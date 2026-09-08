#!/usr/bin/env bash
set -euo pipefail

# Local installation helper for the D03 frozen stack.
# Hard-coded for the user's Linux/Docker layout.
#
# This script verifies the frozen candidate archives, builds the local
# gmpfrxx_mkII/MPLAPACK stack, and installs the mplapack-interop Octave
# package into an isolated prefix.  With no arguments, the generated wrapper
# starts the configured Octave environment and loads the package:
#
#   /home/docker/opt/octave-mplapack-stack/bin/octave-mplapack
#
# In an Octave session started through that wrapper, the package can also be
# loaded explicitly with:
#
#   pkg load mplapack-interop
#
# The historical `pkg load mplapack` name is not provided by the renamed
# D01R1 package.
#
# The final release archive is selected by default; use OCTAVE_CHANNEL=dev
# only when testing the separate development archive.
#
# Input archives:
#   /home/docker/src/gmpfrxx_mkII.1.4.1.tar.xz
#   /home/docker/src/mplapack-3.0.1.tar.xz
#   /home/docker/src/mplapack-interop-0.4.0.tar.gz (default release channel)
#   /home/docker/src/mplapack-interop-0.4.0-dev.tar.gz (test channel)
#
# Use OCTAVE_CHANNEL=dev only for development-archive testing.
#
# Install prefix:
#   /home/docker/opt/octave-mplapack-stack
#
# Build directory:
#   /home/docker/build/octave-mplapack-stack

SRC=/home/docker/src
PREFIX=/home/docker/opt/octave-mplapack-stack
BUILD=/home/docker/build/octave-mplapack-stack
JOBS="${JOBS:-$(nproc)}"

GMPFRXX_TAR="$SRC/gmpfrxx_mkII.1.4.1.tar.xz"
MPLAPACK_TAR="$SRC/mplapack-3.0.1.tar.xz"

GMPFRXX_SHA256=395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4
MPLAPACK_SHA256=f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1
MPLAPACK_SOURCE_COMMIT=c21a9f56224308afda9e7424ca9928d4cf840f7a
OCTAVE_PACKAGE=mplapack-interop
OCTAVE_CHANNEL="${OCTAVE_CHANNEL:-release}"

say() { printf '\n==> %s\n' "$*"; }
die() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

case "$OCTAVE_CHANNEL" in
    dev)
        [[ -n "${OCTAVE_TAR:-}" ]] || die "OCTAVE_CHANNEL=dev requires OCTAVE_TAR=/path/to/mplapack-interop-0.4.0-dev.tar.gz"
        [[ -n "${OCTAVE_SHA256:-}" ]] || die "OCTAVE_CHANNEL=dev requires OCTAVE_SHA256=<sha256>"
        OCTAVE_VERSION=0.4.0-dev
        ;;
    release)
        OCTAVE_VERSION=0.4.0
        OCTAVE_TAR="${OCTAVE_TAR:-$SRC/mplapack-interop-0.4.0.tar.gz}"
        OCTAVE_SHA256="${OCTAVE_SHA256:-<D03-archive-sha256>}"
        ;;
    *)
        die "OCTAVE_CHANNEL must be dev or release"
        ;;
esac

OCT_PKG_PREFIX="$PREFIX/octave-packages"
OCT_PKG_ARCH_PREFIX="$PREFIX/octave-arch"
OCT_PKG_DB="$PREFIX/octave_packages"

# ----------------------------------------------------------------------
# 0. Prerequisites
# ----------------------------------------------------------------------

install_deps() {
    if ! command -v apt-get >/dev/null 2>&1; then
        return
    fi

    local sudo_cmd=()
    if [[ "${EUID}" -ne 0 ]]; then
        if command -v sudo >/dev/null 2>&1; then
            sudo_cmd=(sudo)
        else
            echo
            echo "sudo is not available. Install these packages manually:"
            echo "  build-essential gfortran cmake pkg-config autoconf automake libtool"
            echo "  libgmp-dev libmpfr-dev libmpc-dev octave octave-dev xz-utils"
            exit 1
        fi
    fi

    say "Installing Ubuntu/Debian build dependencies"
    "${sudo_cmd[@]}" apt-get update
    "${sudo_cmd[@]}" apt-get install -y \
        build-essential \
        gfortran \
        cmake \
        pkg-config \
        autoconf \
        automake \
        libtool \
        libgmp-dev \
        libmpfr-dev \
        libmpc-dev \
        octave \
        octave-dev \
        xz-utils
}

if [[ "${SKIP_APT:-0}" != "1" ]]; then
    install_deps
fi

for cmd in gcc g++ gfortran cmake make pkg-config octave mkoctfile sha256sum tar; do
    command -v "$cmd" >/dev/null 2>&1 || die "required command not found: $cmd"
done

# ----------------------------------------------------------------------
# 1. Frozen archive verification
# ----------------------------------------------------------------------

for f in "$GMPFRXX_TAR" "$MPLAPACK_TAR" "$OCTAVE_TAR"; do
    [[ -f "$f" ]] || die "archive not found: $f"
done

say "Checking D03 frozen-stack SHA256 values"

printf '%s  %s\n' "$GMPFRXX_SHA256" "$GMPFRXX_TAR" | sha256sum -c -
printf '%s  %s\n' "$MPLAPACK_SHA256" "$MPLAPACK_TAR" | sha256sum -c -
[[ -n "$OCTAVE_SHA256" ]] || die "set OCTAVE_SHA256 for the final $OCTAVE_PACKAGE $OCTAVE_VERSION archive"
printf '%s  %s\n' "$OCTAVE_SHA256" "$OCTAVE_TAR" | sha256sum -c -

OCTAVE_DESCRIPTION_PATH="$(tar -tzf "$OCTAVE_TAR" | awk -F/ '$NF == "DESCRIPTION" { print; exit }')"
[[ -n "$OCTAVE_DESCRIPTION_PATH" ]] || die "DESCRIPTION is missing from $OCTAVE_TAR"
OCTAVE_ARCHIVE_NAME="$(tar -xOzf "$OCTAVE_TAR" "$OCTAVE_DESCRIPTION_PATH" | sed -n 's/^Name: *//p')"
OCTAVE_ARCHIVE_VERSION="$(tar -xOzf "$OCTAVE_TAR" "$OCTAVE_DESCRIPTION_PATH" | sed -n 's/^Version: *//p')"
[[ "$OCTAVE_ARCHIVE_NAME" == "$OCTAVE_PACKAGE" ]] || die "unexpected Octave package name: $OCTAVE_ARCHIVE_NAME"
[[ "$OCTAVE_ARCHIVE_VERSION" == "$OCTAVE_VERSION" ]] || die "expected final Octave version $OCTAVE_VERSION, got $OCTAVE_ARCHIVE_VERSION"
echo "Octave archive identity: $OCTAVE_ARCHIVE_NAME $OCTAVE_ARCHIVE_VERSION"

# ----------------------------------------------------------------------
# 2. Clean local build/install area
# ----------------------------------------------------------------------

say "Preparing local prefix"
rm -rf "$BUILD"
mkdir -p "$BUILD" "$PREFIX" "$PREFIX/bin" \
         "$OCT_PKG_PREFIX" "$OCT_PKG_ARCH_PREFIX"

# Reinstall the C/C++ dependency stack from scratch.  In particular, remove
# old libtool archives before configuring MPLAPACK.  A previous MPLAPACK
# bundled-dependency build can leave libmpc.la/libmpfr.la/libgmp.la in this
# prefix with dependency_libs pointing back into that old build tree.  If
# those files remain, libtool may resolve a current system "-lmpc" to the old
# .la and then try to read a nonexistent external/i/.../libmpfr.la.
rm -rf \
    "$PREFIX/include/gmpfrxx_mkII" \
    "$PREFIX/include/mplapack" \
    "$PREFIX/lib/cmake/gmpfrxx_mkII" \
    "$PREFIX/lib64/cmake/gmpfrxx_mkII"

rm -f \
    "$PREFIX/include/gmpxx_mkII.h" \
    "$PREFIX/include/mpfrxx_mkII.h" \
    "$PREFIX/include/mpcxx_mkII.h" \
    "$PREFIX/include/gmpfrxx_mkII.h" \
    "$PREFIX/lib/libgmpxx_mkII_default_context_provider.so" \
    "$PREFIX/lib64/libgmpxx_mkII_default_context_provider.so"

rm -f \
    "$PREFIX"/lib/libgmp.a \
    "$PREFIX"/lib/libgmp.la \
    "$PREFIX"/lib/libgmp.so* \
    "$PREFIX"/lib/libmpfr.a \
    "$PREFIX"/lib/libmpfr.la \
    "$PREFIX"/lib/libmpfr.so* \
    "$PREFIX"/lib/libmpc.a \
    "$PREFIX"/lib/libmpc.la \
    "$PREFIX"/lib/libmpc.so* \
    "$PREFIX"/lib/libmplapack_*.a \
    "$PREFIX"/lib/libmplapack_*.la \
    "$PREFIX"/lib/libmplapack_*.so* \
    "$PREFIX"/lib64/libgmp.a \
    "$PREFIX"/lib64/libgmp.la \
    "$PREFIX"/lib64/libgmp.so* \
    "$PREFIX"/lib64/libmpfr.a \
    "$PREFIX"/lib64/libmpfr.la \
    "$PREFIX"/lib64/libmpfr.so* \
    "$PREFIX"/lib64/libmpc.a \
    "$PREFIX"/lib64/libmpc.la \
    "$PREFIX"/lib64/libmpc.so* \
    "$PREFIX"/lib64/libmplapack_*.a \
    "$PREFIX"/lib64/libmplapack_*.la \
    "$PREFIX"/lib64/libmplapack_*.so*

# Environment used both while building and at runtime.
export PATH="$PREFIX/bin:$PATH"
export CMAKE_PREFIX_PATH="$PREFIX${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/lib64/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
export LD_LIBRARY_PATH="$PREFIX/lib:$PREFIX/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export LIBRARY_PATH="$PREFIX/lib:$PREFIX/lib64${LIBRARY_PATH:+:$LIBRARY_PATH}"
export CPATH="$PREFIX/include${CPATH:+:$CPATH}"

# ----------------------------------------------------------------------
# 3. gmpfrxx_mkII 1.4.1
# ----------------------------------------------------------------------

say "Building gmpfrxx_mkII 1.4.1"

GXX_SRC="$BUILD/gmpfrxx-src"
GXX_BUILD="$BUILD/gmpfrxx-build"
mkdir -p "$GXX_SRC"
tar -xJf "$GMPFRXX_TAR" -C "$GXX_SRC" --strip-components=1

cmake \
    -S "$GXX_SRC" \
    -B "$GXX_BUILD" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX"

cmake --build "$GXX_BUILD" -j"$JOBS"

# The D00 release validated the full gmpfrxx test suite. Run it here as a useful
# installation sanity check; set SKIP_GMPFRXX_TESTS=1 to skip it.
if [[ "${SKIP_GMPFRXX_TESTS:-0}" != "1" ]]; then
    ctest --test-dir "$GXX_BUILD" --output-on-failure -j"$JOBS"
fi

cmake --install "$GXX_BUILD"

# ----------------------------------------------------------------------
# 4. MPLAPACK 3.0.1, MPFR backend only
# ----------------------------------------------------------------------

say "Building MPLAPACK 3.0.1 (MPFR backend)"

MPL_SRC="$BUILD/mplapack-src"
mkdir -p "$MPL_SRC"
tar -xJf "$MPLAPACK_TAR" -C "$MPL_SRC" --strip-components=1

cd "$MPL_SRC"

# Select the installed frozen gmpfrxx interface explicitly.  Do not silently
# fall back to a bundled or stale developer copy.
export CPPFLAGS="-I$PREFIX/include ${CPPFLAGS:-}"
export LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib64 ${LDFLAGS:-}"

./configure \
    --prefix="$PREFIX" \
    --enable-mpfr=yes \
    --with-gmpfrxx-mkII="$PREFIX" \
    --with-system-gmp=yes \
    --with-system-mpfr=yes \
    --with-system-mpc=yes \
    --enable-test=no \
    --enable-benchmark=no

make -j"$JOBS"
make install

# ----------------------------------------------------------------------
# 5. MPLAPACK installation checks
# ----------------------------------------------------------------------

say "Checking installed MPLAPACK"

echo "MPLAPACK source candidate: $MPLAPACK_SOURCE_COMMIT"

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/lib64/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
export LD_LIBRARY_PATH="$PREFIX/lib:$PREFIX/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

MPL_VER="$(pkg-config --modversion mplapack_mpfr)"
[[ "$MPL_VER" == "3.0.1" ]] || die "unexpected mplapack_mpfr version: $MPL_VER"

PREC_HEADER=""
for h in \
    "$PREFIX/include/mplapack/mplapack_mpfr_precision.h" \
    "$PREFIX/include/mplapack_mpfr_precision.h"
do
    if [[ -f "$h" ]]; then
        PREC_HEADER="$h"
        break
    fi
done
[[ -n "$PREC_HEADER" ]] || die "mplapack_mpfr_precision.h was not installed"

MPL_SO=""
for so in \
    "$PREFIX/lib/libmplapack_mpfr.so.3" \
    "$PREFIX/lib64/libmplapack_mpfr.so.3"
do
    if [[ -e "$so" ]]; then
        MPL_SO="$so"
        break
    fi
done
[[ -n "$MPL_SO" ]] || die "libmplapack_mpfr.so.3 was not installed"

echo "mplapack_mpfr version : $MPL_VER"
echo "precision header      : $PREC_HEADER"
echo "runtime library       : $MPL_SO"

if command -v ldd >/dev/null 2>&1; then
    ldd "$MPL_SO" | grep -E 'mpc|mpfr|gmp|stdc\+\+|not found' || true
    if ldd "$MPL_SO" | grep -q 'not found'; then
        die "unresolved dependency in $MPL_SO"
    fi
fi

# ----------------------------------------------------------------------
# 6. Environment helper and Octave wrapper
# ----------------------------------------------------------------------

say "Writing environment helper"

cat > "$PREFIX/env.sh" <<EOF
# Source this before using the locally installed stack:
#   source $PREFIX/env.sh

export OCTAVE_MPLAPACK_STACK="$PREFIX"
export PATH="$PREFIX/bin:\${PATH}"
export CMAKE_PREFIX_PATH="$PREFIX\${CMAKE_PREFIX_PATH:+:\$CMAKE_PREFIX_PATH}"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/lib64/pkgconfig\${PKG_CONFIG_PATH:+:\$PKG_CONFIG_PATH}"
export LD_LIBRARY_PATH="$PREFIX/lib:$PREFIX/lib64\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
export LIBRARY_PATH="$PREFIX/lib:$PREFIX/lib64\${LIBRARY_PATH:+:\$LIBRARY_PATH}"
export CPATH="$PREFIX/include\${CPATH:+:\$CPATH}"
export OCTAVE_MPLAPACK_PKG_DB="$OCT_PKG_DB"
export OCTAVE_MPLAPACK_PKG_PREFIX="$OCT_PKG_PREFIX"
export OCTAVE_MPLAPACK_ARCH_PREFIX="$OCT_PKG_ARCH_PREFIX"
EOF

cat > "$PREFIX/bin/octave-mplapack" <<EOF
#!/usr/bin/env bash
set -e
source "$PREFIX/env.sh"

if [[ \$# -eq 0 ]]; then
    exec octave --no-gui --persist --eval \
      "pkg ('local_list', '$OCT_PKG_DB'); pkg ('load', '$OCTAVE_PACKAGE'); fprintf ('$OCTAVE_PACKAGE $OCTAVE_VERSION loaded, mpbits = %d\\n', mpbits ());"
fi

# For non-interactive use, pass ordinary Octave options/scripts and put
# 'pkg load mplapack-interop' in the script.  The runtime library environment is
# already configured by this wrapper.
exec octave "\$@"
EOF
chmod +x "$PREFIX/bin/octave-mplapack"

# ----------------------------------------------------------------------
# 7. Install mplapack-interop 0.4.0 into an isolated local package DB
# ----------------------------------------------------------------------

say "Installing $OCTAVE_PACKAGE $OCTAVE_VERSION"

# Remove an earlier copy from our isolated package database, if present.
octave --no-gui --quiet --eval "
  pkg ('local_list', '$OCT_PKG_DB');
  pkg ('prefix', '$OCT_PKG_PREFIX', '$OCT_PKG_ARCH_PREFIX');
  for package_name = {'$OCTAVE_PACKAGE', 'mplapack'}
    try
      pkg ('unload', package_name{1});
    catch
    end_try_catch
    try
      pkg ('uninstall', '-nodeps', package_name{1});
    catch
    end_try_catch
  endfor
"

octave --no-gui --quiet --eval "
  pkg ('local_list', '$OCT_PKG_DB');
  pkg ('prefix', '$OCT_PKG_PREFIX', '$OCT_PKG_ARCH_PREFIX');
  pkg ('install', '-local', '-verbose', '$OCTAVE_TAR');
  pkg ('load', '$OCTAVE_PACKAGE');
  p = pkg ('list');
  fprintf ('installed $OCTAVE_PACKAGE $OCTAVE_VERSION; mpbits = %d\\n', mpbits ());
"

# ----------------------------------------------------------------------
# 8. Real + complex smoke test
# ----------------------------------------------------------------------

say "Running real + complex smoke test"

SMOKE="$BUILD/smoke.m"
cat > "$SMOKE" <<EOF
pkg ('local_list', '$OCT_PKG_DB');
pkg ('load', '$OCTAVE_PACKAGE');

assert (mpbits () == 512);

mpbits (512);

A = mp ([1, 2; 3, 4]);
b = mp ([1; 2]);
x = A \\ b;
assert (norm (double (A*x - b)) < 1e-12);

[Q, R] = qr (A);
assert (norm (double (Q*R - A), "fro") < 1e-12);

[L, U, P] = lu (A);
assert (norm (double (L*U - P*A), "fro") < 1e-12);

Z = mp ([1+2i, 2-1i; 3, 4+3i]);
zb = mp ([1; 2i]);
zx = Z \\ zb;
assert (norm (double (Z*zx - zb)) < 1e-12);

Zr = Z / Z;
assert (max (max (abs (double (Zr) - eye (2)))) < 1e-12);

[Qz, Rz] = qr (Z);
assert (norm (double (Qz*Rz - Z), "fro") < 1e-12);

[Lz, Uz, Pz] = lu (Z);
assert (norm (double (Lz*Uz - Pz*Z), "fro") < 1e-12);

H = mp ([2, 1+1i; 1-1i, 3]);
C = chol (H);
assert (norm (double (C'*C - H), "fro") < 1e-12);

fprintf ("\\nLOCAL STACK SMOKE PASS\\n");
fprintf ("Octave package:   $OCTAVE_PACKAGE $OCTAVE_VERSION\\n");
fprintf ("mpbits default:   %d\\n", mpbits ());
EOF

octave --no-gui --quiet "$SMOKE"

# ----------------------------------------------------------------------
# 9. Done
# ----------------------------------------------------------------------

say "Installation complete"

cat <<EOF

Installed local stack:

  source archives : $SRC
  prefix          : $PREFIX
  Octave pkg DB   : $OCT_PKG_DB

Use it interactively with:

  $PREFIX/bin/octave-mplapack

or:

  source $PREFIX/env.sh
  octave

and then in Octave:

  pkg ('local_list', '$OCT_PKG_DB');
  pkg load $OCTAVE_PACKAGE

Useful checks:

  pkg-config --modversion mplapack_mpfr
  ldd $MPL_SO

To rebuild from scratch, simply run this script again.

Optional environment switches:

  SKIP_APT=1
      Do not run apt-get.

  SKIP_GMPFRXX_TESTS=1
      Skip the gmpfrxx CTest suite.

  JOBS=N
      Override parallel build jobs.

  OCTAVE_CHANNEL=dev
      Use the placed 0.4.0-dev archive (the development test channel).

  OCTAVE_CHANNEL=release OCTAVE_SHA256=<sha256>
      Use the final 0.4.0 archive after D03 source freeze.

EOF
