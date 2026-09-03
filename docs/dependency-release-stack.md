# D00 dependency release stack

This is the canonical D01/Bxx/PPA handoff manifest. Values marked pending are
filled only after the corresponding D00 gate has passed; no downstream layer
may silently substitute another source commit.

## Frozen stack

| Layer | Repository | Version | Freeze commit | Tag | Archive | SHA256 | Size | License | Depends on |
|---|---|---:|---|---|---|---|---:|---|---|
| gmpfrxx_mkII | `github.com/nakatamaho/gmpfrxx_mkII` | 1.4.1 | `32a7fb797202cdf92312ed9d133f96fdbcda590a` | `v1.4.1` | `gmpfrxx_mkII.1.4.1.tar.xz` | `93fbf257ab3c3e00342109fea9096f43cf32e29fd1b7dbafd91f8e23f81b3890` | 15176072 | BSD 2-Clause | GMP, MPFR, MPC headers/libraries |
| MPLAPACK | `github.com/nakatamaho/mplapack` | 3.0.1 | `fa3ccb4376d2a52c2672322e5b7199a9224bed7f` | pending D00-T (`v3.0.1`) | `mplapack-3.0.1.tar.xz` | pending D00-R | pending | 2-clause BSD-style, with original LAPACK/BLAS notices | frozen gmpfrxx; GMP, MPFR, MPC |
| octave-mplapack | `github.com/nakatamaho/octave-mplapack` | 0.2.0 | pending D00-O | pending D00-T (`v0.2.0`) | `mplapack-0.2.0.tar.gz` | pending D00-R | pending | BSD 2-Clause | MPLAPACK 3.0.1; gmpfrxx; GMP, MPFR, MPC; Octave |

The gmpfrxx and MPLAPACK archive artifacts are stored during D00 under
`/home/docker/work/d00-release-artifacts/` and are not committed as build
outputs. The final report records their two independent build hashes and the
tagged-tree verification.

## Dependency graph and build/runtime roles

```text
octave-mplapack 0.2.0
    -> MPLAPACK 3.0.1 / mplapack_mpfr
        -> gmpfrxx_mkII 1.4.1 headers and scope support
            -> GMP, MPFR, MPC
```

For the validated MPFR reference backend, GMP, MPFR, and MPC are build and
runtime shared-library dependencies of `libmplapack_mpfr`; their public C/C++
headers are used while compiling the wrapper and downstream consumers.
gmpfrxx_mkII supplies public C++ headers and a default-context provider
library; its required GMP/MPFR/MPC interfaces are resolved by the build and
runtime environment. `octave-mplapack` uses MPLAPACK through
`pkg-config mplapack_mpfr` and loads `libmplapack_mpfr.so.3` at runtime.

## Public interface and provenance

MPLAPACK 3.0.1 must install `mplapack_mpfr_precision.h`. Its
`MplapackMpfrPrecisionScope` establishes and restores the current-thread MPFR
default precision for same-thread temporary construction and can be used at a
worker entry point. It does not propagate parent-thread TLS state into a new
worker. Complex calls additionally compose this MPFR scope with the tested
MPC scope in `octave-mplapack`; no builtin binary64 complex fallback is
allowed.

The final installed MPLAPACK interface is expected to provide:

```text
pkg-config module: mplapack_mpfr
pkg-config version: 3.0.1
public scope header: mplapack_mpfr_precision.h
runtime SONAME: libmplapack_mpfr.so.3
runtime support: libmpc.so.3, libmpfr.so.6, libgmp.so.10
```

The final report records exact installed include/pkg-config/runtime paths,
compiler dependency evidence, source-worktree exclusion, archive contents,
and all tested OS/architecture/Octave/compiler versions.

## Licenses and provenance facts

- gmpfrxx_mkII: BSD 2-Clause, as stated by its `LICENSE` file.
- MPLAPACK: 2-clause BSD-style license in `COPYING`, supplemental to the
  original LAPACK/BLAS notices included by the source tree.
- octave-mplapack: BSD 2-Clause in `COPYING` and `LICENSE`.
- GMP: dual GPL-2+ or LGPL-3+ library licensing, as recorded by the installed
  GMP copyright metadata.
- MPFR: LGPL-3+; the source distribution also includes the LGPL text.
- MPC: LGPL-3+; its source distribution and installed metadata govern the
  exact dependency release used by a later distribution milestone.

D00 records source/license facts only. Binary redistribution architecture and
detailed package-local obligations belong to D01/Bxx/PPA work.

## Historical and C12 provenance

```text
REAL_V0_1_RC_COMMIT=0bef79cddd3fdd70abafdf38bc1a4ab492652d33
COMPLEX_START_COMMIT=4aed479ef9cb8dff24f0326e1c2ec2a7c1ed83a3
COMPLEX_FINAL_COMMIT=36cd341a8c14ce2d0a6790b287e5f7a7b0846cd3
```

C12 tested MPLAPACK commit `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`
introduced the public precision-scope header installation. D00 additionally
aligns the release tree with gmpfrxx 1.4.1 and repairs standalone,
reproducible release generation; those release fixes are listed in the D00
report.
