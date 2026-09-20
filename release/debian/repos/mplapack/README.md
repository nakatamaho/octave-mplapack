# P03 `mplapack` packaging workspace

Status: **AUDIT PARTIAL / DRAFT SKELETON ONLY**. No Debian source package is
submitted from this workspace. The `debian/` directory is a review aid for
P03 and is not upload-ready.

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

A later fresh build of the released archive with this committed skeleton
reached the binary-package stage and produced the proposed MPFR runtime and
development packages. The local host has newer libraries under `/usr/local`,
so the final local `dpkg-shlibdeps` verification constrained
`LD_LIBRARY_PATH` to the system multiarch directory. A clean PPA build must
use only declared Debian Build-Depends; the local override is not part of the
package contract. The authoritative source/archive facts are in
`release/debian/PROVENANCE.md` and `release/debian/PACKAGING-AUDIT.md`.

An isolated configure check with dependency tracking disabled and the released
gmpfrxx headers completed successfully. A bounded five-minute MPFR-only build
reached compilation of the optimized/reference sources before the explicit
timeout; it was not reported as a successful package build.

The draft split is `libmplapack-mpfr3` for the MPFR shared libraries and
`libmplapack-mpfr-dev` for headers, linker files, and pkg-config metadata.
The draft packages pass local `lintian --pedantic` with only the expected
initial-upload warning, and their inspected shared objects have the expected
SONAMEs with no RPATH/RUNPATH. These names, the optimized-library policy,
maintainer/changelog, copyright inventory, and final autopkgtest policy remain
subject to P03 Debian-team review. No clean `sbuild`/testbed,
reproducibility, or upload result is claimed; the package remains a review
draft rather than a Debian submission.
