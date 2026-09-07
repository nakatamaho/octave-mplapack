# N08 / D02R1 final report

## Result

```text
N08 PASS — DENSE REAL+COMPLEX MRDIVIDE COMPLETE
D02R1 PASS — MPLAPACK-INTEROP 0.3.1 SOURCE REFREEZE
RELEASE STACK: FROZEN
D01: NOT STARTED
```

D02R1 performed release engineering only after N08. The final public tag is
`v0.3.1`; it is an annotated tag whose peeled target is the freeze commit
`41123b30a03b594aefaa9dec8ac82c8690a128df`. No Debian package, binary
distribution, PPA, Launchpad upload, Octave Packages registration, or
GitHub Release was created.

## Historical checkpoint and C12 baseline

```text
REAL_V0_1_RC_COMMIT=0bef79cddd3fdd70abafdf38bc1a4ab492652d33
REAL_V0_1: historical and unchanged
COMPLEX_START_COMMIT=4aed479ef9cb8dff24f0326e1c2ec2a7c1ed83a3
COMPLEX_FINAL_COMMIT=36cd341a8c14ce2d0a6790b287e5f7a7b0846cd3
C12_RESULT=COMPLEX GOAL PASS / REAL-COMPLEX-API-CLOSED / DEPENDENCY-FREEZE-READY
```

The immutable v0.3.0 predecessor remains commit
`392b72786f34d0bc1efcf35e2fd0cf0de58ec64f`, tag `v0.3.0`, archive SHA256
`1282f77f98bb7b137d1a8800d1d6d426ed06000595aebc03e5fa5ac48b3bdf98`.

## N08 implementation

N08 added dense real and complex `mrdivide`/`/` for scalar, square,
rectangular, rank-deficient, mixed, empty, special-value, and Grcar cases.
Square systems use `Rgesv`/`Cgesv`; rectangular and forced rank-revealing
systems use the accepted MPFR/MPC paths. The implementation preserves public
`mp` value semantics, operation-owned destructive-call copies, and the
one-operation/one-precision MPFR/MPC contract. No builtin binary64 complex
fallback was introduced, and real-only operations remain on real kernels.

```text
N08 implementation: 5a4f2fd
N08 test hardening: 05a2636
N08 reference hardening: 2ec10d506e609aca4c3e5ef4c5039a3683c5442c
N08 completion record: 05da88ec0cc65febfed063a551e8cfc2fb0863e8
```

## gmpfrxx_mkII

```text
Repository: github.com/nakatamaho/gmpfrxx_mkII
C12 tested commit: 32a7fb797202cdf92312ed9d133f96fdbcda590a
Freeze commit: 32a7fb797202cdf92312ed9d133f96fdbcda590a
Version: 1.4.1
Tag: v1.4.1
Tag target: 32a7fb797202cdf92312ed9d133f96fdbcda590a
Archive: /home/docker/src/gmpfrxx_mkII.1.4.1.tar.xz
Archive size: 15176064 bytes
SHA256: 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4
License: BSD 2-Clause
```

The canonical archive is the already-published GitHub Release asset. The
installed manifest contains the public `gmpfrxx_mkII.h`, `gmpxx_mkII.h`,
`mpfrxx_mkII.h`, `mpcxx_mkII.h`, the `gmpfrxx_mkII/{adapters,detail}` headers,
CMake package files, and
`libgmpxx_mkII_default_context_provider.so`. No gmpfrxx pkg-config file is
installed. The wrapper is header-oriented; GMP, MPFR, and MPC are its
external build/header prerequisites.

The exact archive was extracted and installed into a clean CMake prefix. All
192 gmpfrxx CTest tests passed. An installed-only standalone C++ consumer
also passed explicit/default precision, copy/move, real/imag access, 1024-bit,
2048-bit, signed-zero, Inf, NaN, and per-thread MPFR/MPC precision checks.

## MPLAPACK 3.0.1

```text
Repository: github.com/nakatamaho/mplapack
C12 tested commit: a59e5a0a429b05e8f07cf7a8feab1f48aef7431d
C12 integration: e6e1bcbf9513e9de47cb6c70afbd791e30868aae
Freeze/tested archive commit: c21a9f56224308afda9e7424ca9928d4cf840f7a
Version: 3.0.1
Release tag: maintained by the upstream release owner; not created here
Archive: /home/docker/src/mplapack-3.0.1.tar.xz
Archive size: 85807808 bytes
SHA256: f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1
License: 2-clause BSD-style terms plus original LAPACK/BLAS notices
```

The archive-only clean configure/build/install used the frozen gmpfrxx
archive-installed prefix and system GMP 6.3.0, MPFR 4.2.2, and MPC 1.4.1.
`pkg-config --modversion mplapack_mpfr` reported `3.0.1`. The public installed
headers include `mplapack_mpfr_precision.h`, `mpblas_mpfr.h`, and
`mplapack_mpfr.h`. The internal aggregate `mpblas.h` and `mplapack.h` were
not installed because they depend on internal `INTEGER`/`REAL` definitions.

The scope consumer compiled and ran using only installed headers and
libraries. It verified nested scope restoration and the documented contract:
the scope establishes/restores current-thread MPFR precision, supports
same-thread temporary construction, and can be called at worker entry; it
does not copy parent TLS state automatically into new workers. The final
MPFR library SONAME is `libmplapack_mpfr.so.3`. The reference optimized
complex backend was not claimed as release QA.

External installed-only consumers passed Rgesv, Rgels/Rgelss/Rgelsd,
Rpotrf, Rgeqrf/Rorgqr, Rgeqp3, Rgetrf, and the complex MPFR/MPC backend
probe. `readelf -d`, `ldd`, and `ldd -r` found the expected
`libmpc.so.3`, `libmpfr.so.6`, and `libgmp.so.10` runtime dependencies with no
missing relocation.

## octave-mplapack / mplapack-interop 0.3.1

```text
Repository: github.com/nakatamaho/octave-mplapack
C12 tested implementation: 36cd341a8c14ce2d0a6790b287e5f7a7b0846cd3
Freeze commit: 41123b30a03b594aefaa9dec8ac82c8690a128df
Version before: 0.3.1-dev
Version after: 0.3.1
Tag: v0.3.1
Tag target: 41123b30a03b594aefaa9dec8ac82c8690a128df
Archive: /home/docker/src/mplapack-interop-0.3.1.tar.gz
Archive size: 306951 bytes
SHA256 A: 21a7c6751a17e783196c0e28e45d521a9251a1e3f2c210f38ab733fc89e0624b
SHA256 B: 21a7c6751a17e783196c0e28e45d521a9251a1e3f2c210f38ab733fc89e0624b
Hashes identical: YES
License: BSD 2-Clause
```

The final source archive was generated from two independent clean worktrees
with `SOURCE_DATE_EPOCH=0`. The top-level directory, sorted file list, size,
and SHA256 were identical. `reports/`, `.git`, build products, private
developer prefixes, and the repository-only dependency handoff manifests are
excluded from the public archive. The exact tag-tree regeneration matched the
pre-tag archive byte-for-byte.

## Full frozen-stack rebuild

```text
gmpfrxx archive only: PASS — clean CMake install; 192/192 CTest
MPLAPACK archive only: PASS — clean configure/build/install; version 3.0.1
interop archive only: PASS — clean native build and full test wall
Git worktree dependency: NONE
Unfrozen header dependency: NONE
Stale MPLAPACK/gmpfrxx development prefix: NONE
Build/install: PASS
```

The archive-only Octave build used only the installed MPLAPACK prefix derived
from the frozen MPLAPACK archive and the gmpfrxx prefix derived from the
frozen gmpfrxx archive. The host's normal GMP/MPFR/MPC prerequisites were
GMP 6.3.0, MPFR 4.2.2, and MPC 1.4.1 from `/usr/local`; no stale MPLAPACK or
gmpfrxx installation was selected there.

## Regression and lifecycle evidence

```text
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex Cgetrf: PASS
N00-N08 regression: PASS
real rank/Cholesky/QR-pivot/LU-pivot canaries: PASS
complex scalar/Cgemm/Cgesv/Cgelsy/Cpotrf/QR/Cgeqp3/Cgetrf: PASS
1024-bit / 2^-700: PASS
2048-bit / 2^-1500: PASS
low/high ambient precision and scope restoration: PASS
native value/lifetime/shutdown tests: PASS
compatibility firewall and negative dependency checks: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
package install/load: PASS
real and complex smoke: PASS
help and examples: PASS
unload/uninstall: PASS
reinstall and second smoke: PASS
```

The full `tools/local-ci.sh` wall was rerun on the release branch using the
frozen installed MPLAPACK prefix and ended with `PASS: D00 local CI`. The
exact final archive was separately extracted and rebuilt; its full
M00-M23/C00-C12/C11L/N00-N08 wall and package smoke also passed.

During an exploratory lifecycle check, a hand-written expected complex
vector was numerically incorrect and an associated host Octave complex
reduction could enter the known OpenBLAS `ctrmm`/complex path. That check was
discarded; the final lifecycle gate uses backend residuals and the independent
scalar references already used by `mrdivide.tst`, and passed. No release
source or backend failure was observed.

## Provenance

```text
frozen MPLAPACK include: /tmp/d02r1-frozen-stack.duUlCw/mplapack-prefix/include/mplapack
frozen gmpfrxx include: /tmp/d02r1-frozen-stack.duUlCw/gmpfrxx-prefix/include
frozen MPLAPACK pkg-config: /tmp/d02r1-frozen-stack.duUlCw/mplapack-prefix/lib/pkgconfig
frozen MPLAPACK runtime: libmplapack_mpfr.so.3
normal GMP/MPFR/MPC runtime: libgmp.so.10/libmpfr.so.6/libmpc.so.3
development path leakage into interop archive: NONE
```

The temporary paths above identify the clean archive-derived QA prefixes;
they are not release paths and are not present in the interop source archive.
The installed `mplapack_mpfr.pc` selected the frozen gmpfrxx include prefix,
and the native module linked directly to `libmplapack_mpfr.so.3`.

## Release-stack manifest

```text
File: docs/dependency-release-stack-r1.md
Status: complete
Location: repository-only handoff; excluded from source archive by policy
D01 usable: YES
```

The historical D00 manifest remains at `docs/dependency-release-stack.md`.
The D02R1 manifest records all three versions, exact commits/tags, archive
names, SHA256 values, sizes, licenses, dependency order, runtime SONAME, and
the tested environment.

## Upstream changes required by the complex implementation and release QA

gmpfrxx_mkII required no source change during C00-C12, N08, D00, or D02R1.
The final source remains commit `32a7fb7`.

The MPLAPACK candidate contains the required precision-scope, release archive,
external-header, and macOS fixes:

```text
a59e5a0a429b05e8f07cf7a8feab1f48aef7431d  MPFR precision-scope implementation
e6e1bcbf9513e9de47cb6c70afbd791e30868aae  integrate scope support on master
3b340e7bc4eb08052580b9669e2fe1f3b16b4b3a  scope contract regression tests
98fa308ac5dcbb31fe5876b21b3eb7d8c52c8ae0  portable macOS /bin/sh pkg-config generation
20f2f414df106ba09200560ebb4a18ac62c29fb5  macOS QD/DD shared-library load checks
76cbb400aed5e8be7e9f2cfa02f27a95a5e564e4  Automake macOS QD load probe
c21a9f56224308afda9e7424ca9928d4cf840f7a  frozen 3.0.1 candidate archive identity
85b581ea0c9183cdbaf44d34eb48d7cc8eb3dcb2  align bundled gmpfrxx with 1.4.1
3786c35a825ae3927b8621bed380e14877d17912  include generated gmpfrxx Makefile.in in archive
fa3ccb4376d2a52c2672322e5b7199a9224bed7f  export external gmpfrxx headers in MPFR pkg-config
f4e5818135dada8c6ef0a7f11954c53f11f4202a  reproducible source archive tooling
```

D02R1 made no numerical implementation change. Its interop release-engineering
commits are:

```text
ab937387c6aa93982dcde0fb2dd66eb0b14ec95c  freeze 0.3.1 metadata
073b1c4b5be8c195e5a4e25281b043525c622021  prepare reproducible archive freeze
41123b30a03b594aefaa9dec8ac82c8690a128df  align archive QA and final freeze
```

## Gates

```text
G-D02R1-GMPFRXX:      PASS
G-D02R1-MPLAPACK:     PASS
G-D02R1-OCTAVE:       PASS
G-D02R1-STACK:        PASS
G-D02R1-PROVENANCE:   PASS
G-D02R1-REPRODUCIBLE: PASS
G-D02R1-TAGS:         PASS
G-D02R1-HANDOFF:      PASS
```

## Final frozen stack

```text
gmpfrxx_mkII:
  version: 1.4.1
  commit: 32a7fb797202cdf92312ed9d133f96fdbcda590a
  tag: v1.4.1
  archive: gmpfrxx_mkII.1.4.1.tar.xz
  sha256: 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4

MPLAPACK:
  version: 3.0.1
  commit: c21a9f56224308afda9e7424ca9928d4cf840f7a
  tag: upstream release owner / not created here
  archive: mplapack-3.0.1.tar.xz
  sha256: f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1

octave-mplapack / mplapack-interop:
  version: 0.3.1
  commit: 41123b30a03b594aefaa9dec8ac82c8690a128df
  tag: v0.3.1
  archive: mplapack-interop-0.3.1.tar.gz
  sha256: 21a7c6751a17e783196c0e28e45d521a9251a1e3f2c210f38ab733fc89e0624b
```

## Conclusion

```text
D02R1 PASS — MPLAPACK-INTEROP 0.3.1 SOURCE REFREEZE
D01-READY
STOP — D01 is a separate goal and was not started automatically.
```
