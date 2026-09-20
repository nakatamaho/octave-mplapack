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

`dpkg-buildpackage`, CMake, make, C++, Octave 11.1.0, octave-dev, debhelper,
`dh-octave`, `lintian`, and `autopkgtest` are now available in the local lab.
`debuild`, `sbuild`, `piuparts`, `reprotest`, `gbp`, `uscan`, `dput`,
`reportbug`, and `debsign`/upload-key support remain unavailable. No clean
`sbuild`/autopkgtest testbed has been provisioned, so P05 is still PARTIAL and
no Debian policy or submission PASS is claimed.

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

After the `debian/tmp` staging fix and the `${shlibs:Depends}` control fix,
a fresh binary build produced:

```text
79bbc32bf8af980e38693e53053e81ce0f7fa0ce729519755e5e80128b1daa7a  libgmpfrxx-mkii-dev_1.4.1-1_amd64.deb
```

The package contains headers, CMake metadata, and
`libgmpxx_mkII_default_context_provider.so`. The provider has an unversioned
SONAME and the draft uses placeholder maintainer metadata, so this is not a
release or Debian submission artifact. `lintian --pedantic` now runs in the
local lab; its remaining provider SONAME/ldconfig findings are recorded below.
P02 remains PARTIAL and P05 remains PARTIAL.

The initial binary build exposed a draft staging defect: CMake installed
directly into the package directory while the `.install` manifest expected
`debian/tmp`. The committed `override_dh_auto_install` now stages into
`debian/tmp`; a fresh binary build then completed and produced the package
above. Extracting that exact `.deb` and running the committed provider smoke
with its headers/library reported `P02 packaged provider smoke PASS`.
This is stronger artifact evidence, but it is still not an installed Debian
testbed, lintian, sbuild, or policy PASS.

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

The same provider smoke was also compiled and run against the extracted draft
`.deb`, with `CPATH`, `LIBRARY_PATH`, and `LD_LIBRARY_PATH` pointing only at
the extracted package. It reported:

```text
P02 packaged autopkgtest smoke PASS
```

The test remains non-authoritative for Debian autopkgtest until the package
is installed in a clean testbed.

With `lintian --pedantic` now available, the latest draft reports one error
for the provider's missing ldconfig trigger and warnings for the initial
upload changelog, package-name/SONAME mismatch, and unversioned shared
library. The `${shlibs:Depends}` error was removed by the control fix. The
remaining provider findings are the known ABI/SONAME packaging blocker, not
silently ignored QA.

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
version-info `3:0:0` for the reference MPFR library. The earlier bounded audit
did not claim a package build because the generated dependency-file phase was
lengthy and the Debian QA toolchain was incomplete; the later binary-draft
evidence below supersedes that historical limitation. P03 remains PARTIAL
for policy, maintainer, and clean-testbed reasons.

With `--disable-dependency-tracking`, `--enable-mpfr`, all unrelated numeric
backends/tests/examples disabled, system GMP/MPFR/MPC, and the released
gmpfrxx headers, configuration completed successfully in an isolated tree.
The MPFR-only build then compiled for five minutes and was stopped by an
explicit timeout while compiling the large optimized/reference source set;
there was no compiler diagnostic before the timeout. This is retained as
historical build-boundary evidence, not the final P03 result.

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
used `dh-octave` and now carries a broader installed-package smoke test. These
are syntax/source-boundary and test-source checks only; no binary build,
lintian, sbuild, autopkgtest, install lifecycle, or Debian submission PASS is
claimed. The extracted `dh-octave` clean step
also reports that the upstream tree has no top-level `clean` target; this
requires P04 maintainer review rather than being hidden by the draft rules.

After that smoke expansion, a fresh copy of the released archive with the
committed `debian/` directory was checked with `dpkg-source -b` and produced
`octave-mplapack-interop_0.5.0-1.dsc` plus its Debian source tarball. A full
`dpkg-buildpackage` could not start because the base environment has no
`dh` executable; this remains source-boundary evidence only, not a P04 build
or autopkgtest result.

As an additional rootless check, Debian `debhelper`/`dh-octave` packages were
downloaded and unpacked into a temporary prefix. With that prefix on `PATH`,
`dpkg-buildpackage -b -d` reached the `dh_auto_install` stage, then stopped
because the extracted helper refers to its system path
`/usr/share/dh-octave/install-pkg.m`, which is intentionally not installed in
the host filesystem. This confirms that the draft rules reach the real
`dh-octave` install boundary; it is not a binary-package PASS and no host
files were modified.

The extracted `dh_octave_make` helper generated team/Salsa metadata in an
earlier temporary copy. Those fields remain deliberately absent from the
committed skeleton until Debian team ownership and package names are agreed.
The extracted `dh-octave_make` helper (dh-octave 1.14.1) did generate a
candidate Debian skeleton from `DESCRIPTION` in a temporary copy. Its team,
Salsa, and Homepage fields are Debian-policy proposals only and were not
copied into the repository or treated as an official identity.

The P03 draft now also carries an installed-package backend probe and
autopkgtest control. Against the controlled validated `mplapack_mpfr` prefix,
the probe compiled and ran a one-by-one real `Rgemm` and complex `Cgemm` call:

```text
MPLAPACK draft backend probe PASS
```

This is direct header/library evidence, not Debian binary-package QA. The
probe has not yet been run from a clean Debian package installation and does
not establish P03 PASS.

The P04 draft autopkgtest now has an installed-package smoke script covering
real arithmetic/solve, Cholesky, non-pivoted and pivoted QR, LU, complex
construction, eig, SVD, deterministic RNG, and binary serialization. It is
still only test-source evidence: no clean package testbed is available and the
final P02/P03 binary identities are not frozen, so no P04 or P05 PASS is
claimed.

### Latest P03 binary-draft evidence

Using the released `mplapack-3.0.1.tar.xz` archive and the committed Debian
skeleton, a fresh unprivileged build reached the binary package stage after
compiling the MPFR reference and optimized libraries. The local host has
newer libraries under `/usr/local`; the verification run constrained
`LD_LIBRARY_PATH` to the system multiarch directory for `dpkg-shlibdeps`. A
clean PPA build is expected to use only declared Debian Build-Depends and does
not rely on this local override.

The first P04 attempt also exposed that Ubuntu's `libmpc-dev` does not ship an
`mpc.pc`, while the upstream MPLAPACK `.pc` files declare `Requires: mpc`. The
P03 Debian rules now rewrite the installed consumer metadata to remove that
non-portable `Requires` and emit direct `-lmpc -lmpfr -lgmp` flags. This keeps
P04's `pkg-config` path independent of a developer `/usr/local` tree; the
post-fix full P03 rebuild was interrupted after the packaging rule syntax was
checked, so a clean testbed rebuild remains pending.

The resulting draft packages were:

```text
libmplapack-mpfr3_3.0.1-1_amd64.deb
libmplapack-mpfr-dev_3.0.1-1_amd64.deb
```

Both packages passed `lintian --pedantic` with only the expected
`initial-upload-closes-no-bugs` warnings. `readelf -d` showed SONAMEs
`libmplapack_mpfr.so.3` and `libmplapack_mpfr_opt.so.3`, the expected
GMP/MPFR/MPC and C++ runtime NEEDED entries, and no RPATH/RUNPATH. The latest
local runtime package hash was:

```text
f42d1ba997e8e96a9d67a0180c1e8c344240f0201d4f953d6caf582e2de0ee67  libmplapack-mpfr3_3.0.1-1_amd64.deb
```

This is strong local binary/layout evidence, not a final Debian package PASS:
the maintainer remains a placeholder, package names/splits remain proposals,
clean-testbed and reproducibility checks remain undone, and no upload was
attempted.

ITP and team-contact messages are prepared but unsent under
`release/debian/itp/` and `release/debian/team-contact/`. No BTS number,
Salsa URL, mentors upload, sponsor, Launchpad account, or PPA build is claimed.
