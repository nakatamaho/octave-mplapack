# D00 dependency release stack

This is the canonical D01/Bxx/PPA handoff manifest. The source freeze commits
below are the exact trees from which the recorded archives were generated, and
the release tags have been verified against those exact commits.

## Frozen stack

| Layer | Repository | Version | Freeze commit | Tag | Archive | SHA256 | Size | License | Depends on |
|---|---|---:|---|---|---|---|---:|---|---|
| gmpfrxx_mkII | `github.com/nakatamaho/gmpfrxx_mkII` | 1.4.1 | `32a7fb797202cdf92312ed9d133f96fdbcda590a` | `v1.4.1` | `gmpfrxx_mkII.1.4.1.tar.xz` | `395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4` | 15176064 | BSD 2-Clause | GMP, MPFR, MPC headers/libraries |
| MPLAPACK | `github.com/nakatamaho/mplapack` | 3.0.1 | `fa3ccb4376d2a52c2672322e5b7199a9224bed7f` | `v3.0.1` | `mplapack-3.0.1.tar.xz` | `7c8d1d7759a487bc01e8c1625599ec77b6c7e297c19b20ca45e8c342f5165e64` | 86024224 | 2-clause BSD-style, with original LAPACK/BLAS notices | frozen gmpfrxx 1.4.1; GMP, MPFR, MPC |
| octave-mplapack | `github.com/nakatamaho/octave-mplapack` | 0.2.0 | `4a3eb50843a6bf365bdab1e82146ef1900a219f6` | `v0.2.0` | `mplapack-0.2.0.tar.gz` | `0e83e26182b0fbd95a064437a97307eb74d9291b49d91c6e53dac181b24a94db` | 231432 | BSD 2-Clause | MPLAPACK 3.0.1; gmpfrxx 1.4.1; GMP, MPFR, MPC; Octave |

Artifact paths used for D00 verification:

```text
/home/docker/work/d00-release-artifacts/gmpfrxx_mkII.1.4.1.tar.xz
/home/docker/work/d00-release-artifacts/gmpfrxx_mkII.1.4.1-B.tar.xz
/home/docker/work/d00-release-artifacts/mplapack-3.0.1.tar.xz
/home/docker/work/d00-release-artifacts/mplapack-0.2.0.tar.gz
```

The canonical gmpfrxx distribution artifact is the already-published GitHub
Release asset:

```text
https://github.com/nakatamaho/gmpfrxx_mkII/releases/download/v1.4.1/gmpfrxx_mkII.1.4.1.tar.xz
size: 15176064 bytes
sha256: 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4
```

The two local D00 gmpfrxx reproduction archives both had size `15176072`
bytes and SHA256
`93fbf257ab3c3e00342109fea9096f43cf32e29fd1b7dbafd91f8e23f81b3890`.
Their extracted file contents and tar entry metadata match the published
asset; only the XZ compressed byte stream differs. The manifest therefore
uses the published asset identity, while the local A/B hash remains retained
as reproducibility evidence for the D00-generated archive.

The A/B artifacts are not committed as build outputs. The Octave package
source archive excludes `reports/`, build products, private files, and `.git`.

## Exact dependency graph

```text
octave-mplapack 0.2.0
    requires
MPLAPACK 3.0.1 / mplapack_mpfr
    requires
gmpfrxx_mkII 1.4.1 headers and default-context support
    requires
GMP 6.3.0 / MPFR 4.2.2 / MPC 1.4.1
```

GMP, MPFR, and MPC are build dependencies and public C/C++ header
dependencies. They are runtime shared-library dependencies of
`libmplapack_mpfr.so.3`: `libgmp.so.10`, `libmpfr.so.6`, and `libmpc.so.3`.
The gmpfrxx wrapper is header-only for numerical types and installs the
`libgmpxx_mkII_default_context_provider.so` support library; that provider's
recorded SONAME is itself, and it has no direct GMP/MPFR/MPC DT_NEEDED entry.
Octave loads `libmplapack_mpfr.so.3` through the native module's direct
dependency.

## Public interface and scope contract

MPLAPACK 3.0.1 installs `mplapack_mpfr_precision.h` and the public headers
`mpblas_mpfr.h` and `mplapack_mpfr.h` under `include/mplapack/`. The internal
aggregate headers `mpblas.h` and `mplapack.h` are not installed because they
depend on internal `INTEGER`/`REAL` definitions.

`MplapackMpfrPrecisionScope` establishes and restores current-thread MPFR
default precision for same-thread MPLAPACK temporary construction and can be
used at worker entry. It does not automatically copy a parent thread's TLS
state into a new worker. Complex calls compose the tested MPFR scope with the
MPC scope in `octave-mplapack`; no builtin binary64 complex fallback is part of
this stack.

```text
pkg-config module: mplapack_mpfr
pkg-config version: 3.0.1
public scope header: mplapack_mpfr_precision.h
MPLAPACK runtime SONAME: libmplapack_mpfr.so.3
MPLAPACK support runtime: libmpc.so.3, libmpfr.so.6, libgmp.so.10
gmpfrxx support SONAME: libgmpxx_mkII_default_context_provider.so
```

## Installed manifests

gmpfrxx public/detail headers:

```text
gmpfrxx_mkII.h
gmpxx_mkII.h
mpcxx_mkII.h
mpfrxx_mkII.h
gmpfrxx_mkII/{adapters,detail}/*.hpp
```

gmpfrxx CMake metadata:

```text
lib/cmake/gmpfrxx_mkII/FindGMP.cmake
lib/cmake/gmpfrxx_mkII/FindMPC.cmake
lib/cmake/gmpfrxx_mkII/FindMPFR.cmake
lib/cmake/gmpfrxx_mkII/gmpfrxx_mkIIConfig.cmake
lib/cmake/gmpfrxx_mkII/gmpfrxx_mkIIConfigVersion.cmake
lib/cmake/gmpfrxx_mkII/gmpfrxx_mkIITargets.cmake
lib/cmake/gmpfrxx_mkII/gmpxx_mkIITargets.cmake
lib/cmake/gmpfrxx_mkII/gmpxx_mkIITargets-release.cmake
lib/cmake/gmpfrxx_mkII/mpcxx_mkIITargets.cmake
lib/cmake/gmpfrxx_mkII/mpfrxx_mkIITargets.cmake
```

gmpfrxx has no installed pkg-config module. MPLAPACK installs
`lib/pkgconfig/mplapack_mpfr.pc` and `mplapack_mpfr_opt.pc`; the validated
reference module exports the frozen gmpfrxx include path and reports version
3.0.1. MPLAPACK installs the public MPFR headers, libraries, pkg-config
metadata, and release helper scripts. It does not install `mpblas.h` or
`mplapack.h`.

## License and provenance facts

- gmpfrxx_mkII: BSD 2-Clause, from its `LICENSE`.
- MPLAPACK: 2-clause BSD-style terms in `COPYING`, plus the original
  LAPACK/BLAS notices in the source tree.
- octave-mplapack: BSD 2-Clause, from `COPYING` and `LICENSE`.
- GMP: dual GPL-2+ or LGPL-3+ terms stated in `gmp.h`.
- MPFR: LGPL-3+ terms stated in `mpfr.h`.
- MPC: LGPL-3+ terms stated in `mpc.h`.

D00 records source/license facts only. Binary redistribution architecture and
package-local legal analysis belong to D01/Bxx/PPA work.

## Historical and C12 provenance

```text
REAL_V0_1_RC_COMMIT=0bef79cddd3fdd70abafdf38bc1a4ab492652d33
COMPLEX_START_COMMIT=4aed479ef9cb8dff24f0326e1c2ec2a7c1ed83a3
COMPLEX_FINAL_COMMIT=36cd341a8c14ce2d0a6790b287e5f7a7b0846cd3
MPLAPACK_C12_TESTED_COMMIT=a59e5a0a429b05e8f07cf7a8feab1f48aef7431d
MPLAPACK_C12_INTEGRATION_COMMIT=e6e1bcbf9513e9de47cb6c70afbd791e30868aae
```

C12's precision-scope interface is retained in the 3.0.1 release tree. D00
adds only release-line provenance, standalone archive, reproducibility, and
release-QA corrections listed in `reports/D00-report.md`.
