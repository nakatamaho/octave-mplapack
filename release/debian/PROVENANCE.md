# RELDEB00 upstream release provenance

This record freezes the upstream inputs for the Debian/Ubuntu packaging
controller `RELDEB00`. The values below were retrieved on 2026-09-20. A
Debian source package must use the released archives, not a developer
checkout or a private build prefix.

## gmpfrxx_mkII

| Field | Value |
|---|---|
| Repository | `https://github.com/nakatamaho/gmpfrxx_mkII.git` |
| Release tag | `v1.4.1` |
| Tag target | `32a7fb797202cdf92312ed9d133f96fdbcda590a` |
| Archive | `gmpfrxx_mkII.1.4.1.tar.xz` |
| SHA256 | `395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4` |
| Asset | `https://github.com/nakatamaho/gmpfrxx_mkII/releases/download/v1.4.1/gmpfrxx_mkII.1.4.1.tar.xz` |
| License | BSD-2-Clause |

The release installs the `gmpfrxx_mkII.h`, `gmpxx_mkII.h`, `mpcxx_mkII.h`,
and `mpfrxx_mkII.h` headers, CMake package metadata, and the
`libgmpxx_mkII_default_context_provider.so` provider. It does not install a
pkg-config module. The provider currently has the unversioned SONAME
`libgmpxx_mkII_default_context_provider.so`; a Debian runtime/development
split therefore requires an explicit ABI decision before P02 is complete.

## MPLAPACK

| Field | Value |
|---|---|
| Repository | `https://github.com/nakatamaho/mplapack.git` |
| Release tag | `v3.0.1` |
| Tag target | `7646ad96f15d46c4d15333114e98d499e007e09f` |
| Archive source commit | `953d7a4916554546937a753a30b0619691072841` |
| Archive | `mplapack-3.0.1.tar.xz` |
| SHA256 | `47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa` |
| Asset | `https://github.com/nakatamaho/mplapack/releases/download/v3.0.1/mplapack-3.0.1.tar.xz` |
| License | MPLAPACK 2-clause BSD-style license plus bundled LAPACK/BLAS notices |
| Release date | 2026-09-15 |

The release archive is the clean source archive identified by the release
notes, rather than the later tag-only result metadata. The installed runtime
validated by the upstream project is `libmplapack_mpfr.so.3`; the development
interface includes the `mplapack_mpfr` pkg-config identity and
`mplapack_mpfr_precision.h`. The archive contains bundled GMP, MPFR, MPC,
OpenBLAS, QD, LAPACK, and gmpfrxx sources. Debian packaging must use system
dependencies where policy and build tooling permit and must document any
repackaging needed to remove embedded copies.

## octave-mplapack-interop

| Field | Value |
|---|---|
| Repository | `https://github.com/nakatamaho/octave-mplapack.git` |
| Release tag | `v0.5.0` |
| Tag target | `7187a0f6c5a40a4d5774f4f913b166ccb6a5dffa` |
| Archive | `mplapack-interop-0.5.0.tar.gz` |
| SHA256 | `3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04` |
| Asset | `https://github.com/nakatamaho/octave-mplapack/releases/download/v0.5.0/mplapack-interop-0.5.0.tar.gz` |
| Octave package Name | `mplapack-interop` |
| Version | `0.5.0` |
| Minimum Octave | `11.1.0` |
| License | BSD-2-Clause |
| Release date | 2026-09-15 |

The archive `DESCRIPTION` was inspected directly. It is the package input for
P04; the repository name and the Octave package name are intentionally
different.

## GNU MPC prerequisite

| Field | Value |
|---|---|
| Source package | `mpclib3` |
| Upstream release | GNU MPC 1.4.1 |
| Archive | `mpc-1.4.1.tar.xz` |
| SHA256 | `91204cd32f164bd3b7c992d4a6a8ce6519511aadab30f78b6982d0bf8d73e931` |
| Asset | `https://ftp.gnu.org/gnu/mpc/mpc-1.4.1.tar.xz` |
| Required API | `mpc_log2` (introduced in MPC 1.4.0) |
| License | LGPL-3+ |

Ubuntu 26.04's archive currently provides MPC 1.3.1, which does not export
`mpc_log2`.  The released `mplapack-interop` 0.5.0 native bridge calls this
function directly.  A PPA build therefore needs a compatible `mpclib3`
1.4.1 package before the three project packages.  This is an external
dependency package, not an MPLAPACK or gmpfrxx source change.

## R00 conclusion

`R00 PASS — UPSTREAM RELEASE STACK FROZEN` for provenance purposes. The MPC
prerequisite is now recorded explicitly because the target Ubuntu archive does
not provide the API required by the released interop bridge. P02–P04 remain
pending Debian source-package construction and QA; this document does not
claim that any Debian package has been uploaded.
