# P03 `mplapack` packaging workspace

Status: **AUDIT PARTIAL**. No Debian source package is submitted from this
workspace.

Input archive: `mplapack-3.0.1.tar.xz` with SHA256
`47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa`.

The package must use system GMP/MPFR/MPC where policy permits, audit bundled
third-party sources, and provide the validated `mplapack_mpfr` headers,
pkg-config module, and `libmplapack_mpfr.so.3` runtime. P03 owns the final
binary split, symbols/shlibs, copyright, and Multi-Arch decisions.

The release archive's Autotools build exposes explicit system-library switches
for GMP, MPFR, and MPC and an installed `gmpfrxx_mkII` prefix. The MPFR build
installs `mplapack_mpfr.h`, `mplapack_mpfr_precision.h`, and the
`mplapack_mpfr.pc`/`mplapack_mpfr_opt.pc` metadata. The reference MPFR library
uses libtool version information `3:0:0`, consistent with the observed
`libmplapack_mpfr.so.3` runtime SONAME. The archive also contains bundled
third-party sources and optional backends, so Debian must explicitly select
the MPFR-only/system-dependency configuration and complete the copyright and
repackaging review before publishing.

A clean unprivileged package build was not claimed: the source configuration
and full compile are expensive and the required Debian QA toolchain is not
available in the base environment. The authoritative source/archive facts are
in `release/debian/PROVENANCE.md` and `release/debian/PACKAGING-AUDIT.md`.
