# P01 packaging architecture and license audit

## Proposed source packages

The package-name audit found no Debian package or active tracker entry for the
three names below. They remain proposals pending P02–P04 review:

```text
gmpfrxx-mkii
mplapack
octave-mplapack-interop
```

The Git repositories and Octave package name are intentionally distinct:

```text
Git repository:         octave-mplapack
Octave package Name:    mplapack-interop
Debian source proposal: octave-mplapack-interop
```

## gmpfrxx_mkII 1.4.1

A clean CMake build with `GMPFRXX_MKII_COMPONENTS=GMP,MPFR,MPC`, tests enabled,
and an isolated `DESTDIR` install was audited from the release archive. The
upstream test suite passed 156/156 tests. Installed artifacts include the
public headers, CMake config/targets, and:

```text
libgmpxx_mkII_default_context_provider.so
```

The upstream provider has no pkg-config module and no versioned SONAME. The
current local Debian candidate carries a packaging-only quilt patch assigning
target `VERSION ${PROJECT_VERSION}` and `SOVERSION 1`. It splits the runtime
into `libgmpxx-mkii-default-context-provider1` and leaves the unversioned
linker symlink with the headers/CMake metadata in `libgmpfrxx-mkii-dev`.
Direct binary Lintian is clean apart from the expected initial-upload warning.
This closes the local ELF packaging defect, but not Debian's ABI, symbols,
Multi-Arch, licensing, or maintainer review.

The CMake audit also found MPFR TLS support, while the installed MPC probe did
not expose an MPC TLS API. The Debian package must preserve the upstream
precision-context contract and document this distinction.

### Provider boundary clarified during P02/P03 audit

MPLAPACK 3.0.1 does not consume the standalone gmpfrxx provider in the
MPFR-only stack. The source list includes `mplapackinit.cpp`, but the provider
definitions in that file are conditional on `MPLAPACK_BUILD_WITH_GMP`; the
MPFR library is built with `MPLAPACK_BUILD_WITH_MPFR`. `readelf`/`nm` on the
validated `libmplapack_mpfr.so.3` found no `gmpxx_mkII_*` dynamic exports and no
NEEDED entry for the gmpfrxx provider. Consequently P03's MPLAPACK runtime
package must depend on GMP/MPFR/MPC, but not on a separate gmpfrxx provider
runtime package. The standalone provider still needs a Debian decision for
independent gmpfrxx consumers, because its public SONAME remains unversioned.

### P02 draft build evidence

A local unprivileged lab build using `dpkg-buildpackage` produced a
`libgmpfrxx-mkii-dev` draft from the 1.4.1 release archive. The draft installs
the headers, CMake metadata, and the unversioned default-context provider in
one development package. Two clean draft binary builds produced the same
SHA256 (`548e6d4e4b04b7832672f8ee806b12d017b8e690524f60afb4fbee702a0188c`).
The source package also built with Debian source format `3.0 (quilt)`.

This does not close P02: the maintainer/team fields are placeholders, the
provider has no versioned SONAME, dependency fields and Multi-Arch policy
still require review, and `lintian`/`sbuild`/autopkgtest QA was not run.

## MPLAPACK 3.0.1

The source archive bundles third-party GMP, MPFR, MPC, OpenBLAS, QD, LAPACK,
and gmpfrxx sources. Its build system exposes system-dependency switches for
GMP/MPFR/MPC. P03 must select system libraries where Debian policy allows,
remove or repackage embedded code as required, and carry complete copyright/
license files for any retained bundled source. The validated installed
interface is:

```text
pkg-config module: mplapack_mpfr
runtime:           libmplapack_mpfr.so.3
header:            mplapack_mpfr_precision.h
```

The exact binary package split and Multi-Arch fields are intentionally pending
P03 Debian policy review; this document does not claim a Debian package.

The release Autotools metadata confirms that the MPFR reference library is
`libmplapack_mpfr.la` with libtool version information `3:0:0`, and that the
public MPFR headers and `mplapack_mpfr.pc` metadata are installed from the
top-level build. Debian must disable unrelated optional backends, select
system GMP/MPFR/MPC, and audit the bundled third-party source tree before
choosing the final source/binary package layout. No P03 package PASS is
claimed from this source audit.

## octave-mplapack-interop 0.5.0

The Octave package is architecture-dependent because it builds a native `.oct`
bridge. The likely binary package is `octave-mplapack-interop`, depending on
Octave and the MPLAPACK MPFR runtime/development packages selected by P03.
The source archive is BSD-2-Clause. P04 must use installed pkg-config and
headers rather than a private MPLAPACK prefix.

The released archive contains a conventional Octave `DESCRIPTION`, `inst/`,
`src/Makefile`, tests, examples, and docs. The native Makefile obtains
`MPLAPACK_CFLAGS`/`MPLAPACK_LIBS` from `pkg-config --cflags/--libs
mplapack_mpfr`; the package therefore has a clear P03 development-package
boundary. The 0.5.0 release also includes later complex and advanced APIs,
so P04 packaging must preserve the release's actual scope rather than reuse
the historical real-only v0.1 description. No P04 package PASS is claimed.

## License inventory

| Component | Evidence | Initial Debian action |
|---|---|---|
| gmpfrxx_mkII | upstream `LICENSE`, BSD-2-Clause | install copyright/license text |
| MPLAPACK | `COPYING`, MPLAPACK BSD-style text plus LAPACK/BLAS notices | retain complete notices and create DEP-5 entries for bundled code |
| octave-mplapack-interop | upstream `COPYING`, BSD-2-Clause | install copyright/license text |
| system GMP | installed package metadata, dual GPL/LGPL terms | use Debian system package |
| system MPFR/MPC | installed package metadata, LGPL-3+ terms | use Debian system packages |

The final copyright files require source-tree inspection during P02/P03. No
license conclusion here replaces Debian NEW review.

## P01 status

`P01 PARTIAL`: release artifacts, package boundary, and license inventory are
documented. P02 is blocked on the unversioned gmpfrxx provider ABI decision;
P03 has a local system-dependency/repackaging draft but still needs Debian
policy closure; P04 depends on both.
