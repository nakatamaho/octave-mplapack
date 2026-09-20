# RELDEB00 local QA evidence

All commands in this note were run on 2026-09-20 from the project worktree.
They are provenance and environment evidence; they do not replace Debian
package QA.

## Release archives

```text
395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4  gmpfrxx_mkII.1.4.1.tar.xz  15176064 bytes
47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa  mplapack-3.0.1.tar.xz       85720132 bytes
3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04  mplapack-interop-0.5.0.tar.gz   817463 bytes
```

These values match `SHA256SUMS` and the published GitHub release assets.

## Installed MPLAPACK interface

The controlled installed environment reports:

```text
pkg-config module: mplapack_mpfr
pkg-config version: 3.0.1
cflags/libs: -I/usr/local/include/mplapack -I/usr/local/include -L/usr/local/lib -lmplapack_mpfr -lmpc -lmpfr -lgmp
```

The `/usr/local` output is observed environment evidence only; it is not a
committed build path and must not be used by Debian packaging.

## gmpfrxx release smoke

The 1.4.1 release was configured with CMake using GMP/MPFR/MPC components,
tests enabled, examples and benchmarks disabled, built with the system C++
compiler, and installed into an isolated `DESTDIR`. CTest reported:

```text
156/156 tests passed
```

The install audit found the headers, CMake metadata, and the default-context
provider described in `PACKAGING-AUDIT.md`.

## Debian toolchain

`dpkg-buildpackage`, CMake, make, C++, Octave 11.1.0, and octave-dev are
available. `debuild`, `dh`, `dh-octave`, `lintian`, `sbuild`, `autopkgtest`,
`piuparts`, `reprotest`, `gbp`, `uscan`, `dput`, `reportbug`, and `debsign` are
missing. Apt installation is unavailable to the unprivileged user. Therefore
P05 is BLOCKED and no Debian package QA result is claimed.

The repository's `tools/local-ci.sh` was also started with the previously
validated MPLAPACK prefix supplied only through `PKG_CONFIG_PATH`. That run
passed the dependency probe, the M00–M21 native probes, M20 complex probes, and
many public/NEIG checks, but it was intentionally interrupted before the full
suite completed at the user's request. It is therefore evidence of useful
progress, not a full local-CI PASS.

## P02 packaging draft

Using the released `gmpfrxx_mkII.1.4.1.tar.xz` archive, a local unprivileged
lab with `dpkg-buildpackage` produced both a Debian source package and the
draft binary package `libgmpfrxx-mkii-dev_1.4.1-1_amd64.deb`. The draft was
configured with system GMP/MPFR/MPC and with examples, benchmarks, and tests
disabled for the package build. The CMake build and install completed.

Two clean draft binary builds produced:

```text
548e6d4e4b04b7832672f8ee806b12d017b8e690524f60afb4fbee702a0188c  libgmpfrxx-mkii-dev_1.4.1-1_amd64.deb
```

The package contains headers, CMake metadata, and
`libgmpxx_mkII_default_context_provider.so`. The provider has an unversioned
SONAME and the draft uses placeholder maintainer metadata, so this is not a
release or Debian submission artifact. `lintian` could not yet run because
the base environment lacks its Perl dependency set; P02 remains PARTIAL and
P05 remains BLOCKED.

The dependency boundary was checked separately against the released MPLAPACK
source and the validated MPFR shared library. `mpblas/reference/mplapackinit.cpp`
is listed in the MPFR reference/optimized build sources, but its provider
definitions are conditional on `MPLAPACK_BUILD_WITH_GMP`. `readelf -d` and
`nm -D --defined-only` on `libmplapack_mpfr.so.3` showed no
`libgmpxx_mkII_default_context_provider.so` NEEDED entry and no
`gmpxx_mkII_*` dynamic exports. Thus the standalone provider is not needed by
the MPFR-only MPLAPACK/Octave runtime; only independent gmpfrxx external-
 provider consumers require that unresolved P02 package decision.

The committed non-installed probe
`release/debian/probes/gmpfrxx-provider-abi.cpp` was compiled against the
released gmpfrxx source/build and provider library with external-provider mode
explicitly selected. It reported:

```text
gmpfrxx provider ABI/TLS PASS
```

The probe verifies ABI version 1, the context structure size, exported
mode/token functions, independent 256/2048-bit worker-thread contexts, the
1024-bit main-thread context, and reset behavior. This is ABI evidence only;
it does not resolve the provider's unversioned SONAME packaging policy.

The P02 review skeleton now also carries `debian/watch`,
`debian/upstream/metadata`, an install manifest, and a provider-header
autopkgtest. The test source was compiled against the released gmpfrxx build
and provider library in external-provider mode and reported:

```text
gmpfrxx draft provider smoke PASS
```

Applied to a fresh copy of the release archive, the draft produced
`gmpfrxx-mkii_1.4.1-1.dsc` with `dpkg-buildpackage -S -us -uc -d`. This is
source-format and test-source evidence only. `uscan` could not be validated in
the extracted temporary tool set because its `File::HomeDir` Perl dependency
is absent; no watch-file PASS is claimed. The unversioned provider SONAME,
placeholder maintainer, incomplete DEP-5 inventory, and missing Debian QA
tools keep P02 PARTIAL.

## P03/P04 source audits

The MPLAPACK 3.0.1 source archive was inspected without modifying it. Its
Autotools metadata exposes system GMP/MPFR/MPC switches, installs the MPFR
headers and `mplapack_mpfr` pkg-config metadata, and declares libtool
version-info `3:0:0` for the reference MPFR library. A full Debian source
package build was not claimed because the configured source tree's generated
dependency-file phase is lengthy in this unprivileged environment and the
Debian QA toolchain is incomplete; P03 remains PARTIAL.

With `--disable-dependency-tracking`, `--enable-mpfr`, all unrelated numeric
backends/tests/examples disabled, system GMP/MPFR/MPC, and the released
gmpfrxx headers, configuration completed successfully in an isolated tree.
The MPFR-only build then compiled for five minutes and was stopped by an
explicit timeout while compiling the large optimized/reference source set;
there was no compiler diagnostic before the timeout. This is useful build
boundary evidence, not a package build PASS.

The `mplapack-interop` 0.5.0 archive was inspected and contains the expected
Octave package metadata, `src/Makefile`, tests, examples, and docs. Its Makefile
uses the installed `mplapack_mpfr` pkg-config module. The archive is the later
0.5.0 complex/advanced release, not the historical real-only v0.1 candidate;
P04 must preserve that fact.

Review-only Debian skeletons were then applied to fresh copies of the two
release archives. `dpkg-buildpackage -S -us -uc -d` produced source metadata
for both drafts (with `UNRELEASED` changelogs and placeholder maintainers):

```text
mplapack_3.0.1-1.dsc
octave-mplapack-interop_0.5.0-1.dsc
```

The draft MPLAPACK source package used the proposed
`libmplapack-mpfr3`/`libmplapack-mpfr-dev` split. The draft Octave package
used `dh-octave` and a placeholder smoke test. These are syntax/source-boundary
checks only; no binary build, lintian, sbuild, autopkgtest, install lifecycle,
or Debian submission PASS is claimed. The extracted `dh-octave` clean step
also reports that the upstream tree has no top-level `clean` target; this
requires P04 maintainer review rather than being hidden by the draft rules.

The extracted `dh_octave_make` helper generated team/Salsa metadata in an
earlier temporary copy. Those fields remain deliberately absent from the
committed skeleton until Debian team ownership and package names are agreed.
The extracted `dh-octave_make` helper (dh-octave 1.14.1) did generate a
candidate Debian skeleton from `DESCRIPTION` in a temporary copy. Its team,
Salsa, and Homepage fields are Debian-policy proposals only and were not
copied into the repository or treated as an official identity.
