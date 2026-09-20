## ITP: mplapack -- multiple-precision BLAS and LAPACK

Package: mplapack
Type: new Debian source package (ITP)
Proposed binaries: libmplapack-mpfr3, libmplapack-mpfr-dev
Section: science
Priority: optional

Upstream: https://github.com/nakatamaho/mplapack
Release: v3.0.1, tag commit `7646ad96f15d46c4d15333114e98d499e007e09f`
Source archive: `mplapack-3.0.1.tar.xz`
SHA256: `47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa`
License: MPLAPACK 2-clause BSD-style terms with bundled LAPACK/BLAS notices

Description:
 MPLAPACK provides BLAS and LAPACK routines for arbitrary-precision numeric
 types. This request is initially for the MPFR backend used by
 octave-mplapack-interop, with system GMP/MPFR/MPC and the packaged gmpfrxx
 headers.

Dependency relation:
 This source package follows `gmpfrxx-mkii` and must publish its development
 pkg-config module and `mplapack_mpfr_precision.h` before the Octave package
 can be built. The proposed runtime SONAME is `libmplapack_mpfr.so.3`.

Local evidence:
 The released archive has been audited and a review-only Autotools Debian
 skeleton produces source metadata. A clean resolute amd64 sbuild reaches the
 binary-package stage, and the installed MPFR backend probe passes in the
 copied local testbed. Source copyright/DEP-5 inventory, symbols/shlibs and
 Multi-Arch policy, maintainer identity, official autopkgtest, and archive
 acceptance remain pending.

Maintenance request:
 Please advise whether Debian Science wants to maintain this package and
 review the MPFR-only/system-dependency configuration and binary split.
