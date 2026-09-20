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
`dh-octave`, `lintian`, `autopkgtest`, `debuild`, `sbuild`, `piuparts`,
`reprotest`, `gbp`, `uscan`, `dput`, and `reportbug` are now available in the
local lab. `debsign` is installed, but no upload key or Debian identity is
configured. A registered Ubuntu 26.04/resolute amd64 schroot is available as
`resolute-amd64-sbuild`; sbuild is run with `--chroot-mode=schroot` because the
host has no root subuid mapping. This enables clean build evidence, but does
not provide Debian ownership, signing, autopkgtest policy acceptance, or PPA
submission evidence.

The repository's `tools/local-ci.sh` was also started with the previously
validated MPLAPACK prefix supplied only through `PKG_CONFIG_PATH`. That run
passed the dependency probe, the M00–M21 native probes, M20 complex probes, and
many public/NEIG checks, but it was intentionally interrupted before the full
suite completed at the user's request. It is therefore evidence of useful
progress, not a full local-CI PASS.

## Clean resolute chroot build evidence

On 2026-09-20, source packages were rebuilt in the clean `resolute-amd64-sbuild`
chroot. Each sbuild reported `Status: successful`; the separate Lintian stage
returned policy failures for the draft `UNRELEASED` changelogs and, for P02,
the intentionally unresolved provider SONAME/ldconfig findings. These are
recorded as clean-build evidence, not package-quality PASS.

```text
P02 gmpfrxx-mkii 1.4.1-1:       build successful; lintian policy fail
P03 mplapack 3.0.1-1:           build successful; lintian policy fail
P04 interop 0.5.0-1:            build successful; lintian policy fail
MPC libmpc3/libmpc-dev 1.4.1:  build successful; 75/75 upstream MPC tests pass
```

The P04 chroot build injected the freshly built P02/P03 and MPC 1.4.1 binary
packages. Its `dh_auto_test` ran the installed MPLAPACK interface probe and
the released Octave native build; the output included:

```text
PASS: mplapack_mpfr 3.0.1
PASS: MPLAPACK MPFR uniform-precision interface probe
```

Clean-build artifact hashes from this run were:

```text
29af87b6f00dd0a0b8d3a7577c43d238a34569c59c3263c001fd3ef0ac096202  libgmpfrxx-mkii-dev_1.4.1-1_amd64.deb
557cb1bcf50aed5a579ae483dfa0bd4286156b354d0b5cef089297d12b6a45fc  libmplapack-mpfr3_3.0.1-1_amd64.deb
f4c0a8b4993b4764b4a999752a63d6795a2ae0690a1e6ad63521225e820ec2f7  libmplapack-mpfr-dev_3.0.1-1_amd64.deb
adf20ec07bb91cec50f9751cf1ea3ba53c307e28cc00d27fdea9bc8a42ce7fde  libmpc3_1.4.1-1~ppa1_amd64.deb
ba66ea8a313979c5e229419031199cfb9add07ad008afa79692aac2f998c3815  libmpc-dev_1.4.1-1~ppa1_amd64.deb
a104224be49f32167062bfb2f2b1e5ec991240894fb9fa5261f73b049202a965  octave-mplapack-interop_0.5.0-1_amd64.deb
```

The clean chroot uses Ubuntu MPC 1.3.1 by default; P04 succeeds only because
the MPC 1.4.1 prerequisite was injected. No Launchpad/PPA upload or Debian
autopkgtest result is claimed.

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

## MPC prerequisite ABI finding

The installed Ubuntu 26.04 archive provides `libmpc3`/`libmpc-dev` 1.3.1-3.
That ABI has `mpc_log` and `mpc_log10`, but no `mpc_log2`. The released
`mplapack-interop` 0.5.0 bridge calls `mpc_log2` from
`src/mp_script_compat.cc`; the function was added by GNU MPC 1.4.0. This is
an external MPC version mismatch, not an MPLAPACK or gmpfrxx_mkII symbol.

The official GNU MPC 1.4.1 archive was downloaded and built against the system
GMP/MPFR libraries. A local Debian draft `mpclib3` package containing
`libmpc3`/`libmpc-dev` 1.4.1-1~ppa1 passed binary build and pedantic lintian
with no reported tag. The installed library exports `mpc_log2`.

With that draft MPC package installed, the released P04 source built into a
Debian binary package and the installed-package smoke passed. The package now
declares the required `libmpc-dev (>= 1.4.0)` build dependency and
`libmpc3 (>= 1.4.0)` runtime dependency. The PPA order must therefore start
with `mpclib3`, before the three project packages. This is local evidence;
MPC Debian ownership, source-package policy, and PPA publication remain
pending.

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

The first P04 attempt also exposed that Ubuntu's `libmpc-dev` 1.3.1 does not
ship `mpc.pc`, while the upstream MPLAPACK `.pc` files declare `Requires:
mpc`. The P03 Debian rules now rewrite the staged consumer metadata to remove
that non-portable `Requires` and emit direct `-lmpc -lmpfr -lgmp` flags. The
hook targets `debian/tmp`, where `dh_auto_install` stages the `.pc` files.
The separate `mpc_log2` ABI issue is handled by the explicit MPC 1.4.1 PPA
prerequisite described above.

The resulting draft packages were:

```text
libmplapack-mpfr3_3.0.1-1_amd64.deb
libmplapack-mpfr-dev_3.0.1-1_amd64.deb
```

Both packages passed `lintian --pedantic` with only the expected
`initial-upload-closes-no-bugs` warnings. `readelf -d` showed SONAMEs
`libmplapack_mpfr.so.3` and `libmplapack_mpfr_opt.so.3`, the expected
GMP/MPFR/MPC and C++ runtime NEEDED entries, and no RPATH/RUNPATH. The latest
corrected local package hashes were:

```text
6f13670c4f3310b60b9ff639c333fc8543a0a80147170b438f15406ff960ee3c  libmplapack-mpfr3_3.0.1-1_amd64.deb
5c7f4575031aefaf2c49d3377dfb037f81d048e6b97fd9f7b541328fe18ecfea  libmplapack-mpfr-dev_3.0.1-1_amd64.deb
```

This is strong local binary/layout evidence, not a final Debian package PASS:
the maintainer remains a placeholder, package names/splits remain proposals,
clean-testbed and reproducibility checks remain undone, and no upload was
attempted.

With the corrected P03 packages and the local `mpclib3` 1.4.1 prerequisite,
a fresh P04 build of the released archive completed the real `dh-octave`
binary stage. The resulting package hash was:

```text
280079d3b1b4370570b1b807ae1521e6cd6082ecc81807c3db9a9041ac6f46c2  octave-mplapack-interop_0.5.0-1_amd64.deb
```

`lintian --pedantic` reported only the expected initial-upload warning, the
installed `.oct` had no RPATH/RUNPATH, and the installed smoke passed. A
system-only run with Ubuntu MPC 1.3.1 still fails at load time with the
expected `undefined symbol: mpc_log2`; that failure is now a documented
dependency gate rather than an unexplained P04 build failure. Clean Debian
testbed, reproducibility, and PPA evidence remain pending, so P03/P04 and the
overall controller stay PARTIAL.

### Clean chroot follow-up

The preceding local binary-draft hashes are retained as historical host-build
evidence. The later clean `resolute-amd64-sbuild` run produced the hashes in
the clean-build section above and supersedes the host-only build boundary for
P02/P03/P04 compilation. Lintian still fails on draft-release metadata and
the P02 provider packaging findings, so these stages remain PARTIAL. A clean
package-install/autopkgtest lifecycle and reproducible-build comparison have
not yet been completed.

ITP and team-contact messages are prepared but unsent under
`release/debian/itp/` and `release/debian/team-contact/`. No BTS number,
Salsa URL, mentors upload, sponsor, Launchpad account, or PPA build is claimed.

## Isolated package lifecycle follow-up (2026-09-20)

The P04 installed-package smoke test was run with `autopkgtest` against a
fresh copied rootfs of the registered Ubuntu 26.04/resolute testbed. The
testbed is isolated and reproducible locally, but it is not an official Debian
or Launchpad worker. The test control was corrected to use Ubuntu's `octave`
binary provider (there is no separate `octave-cli` package in this suite), and
the obsolete `Features: test-name=...` field was removed because autopkgtest
rejects it together with `Tests:`. The smoke script disables only Octave's
shadowed-function warnings so that the test's stdout/stderr contract is
stable.

The final run reported:

```text
autopkgtest: smoke PASS (superficial)
```

The run log and summary were saved under the temporary path
`/tmp/reldeb00-autopkgtest-p04.eTUTRK/` during QA. The P04 test source is now
part of the committed Debian skeleton; no upstream numerical source changed.

The corrected P04 package was rebuilt in the clean `resolute-amd64-sbuild`
chroot after those test-control changes. sbuild reported `Status: successful`,
and the resulting package hash was:

```text
38e5db17c3371e373833ad3222d488a560297fe6ea35dac9a1815a587cf49f50  octave-mplapack-interop_0.5.0-1_amd64.deb
```

The local `piuparts` install/purge check was also rerun with
`--distribution=resolute` against a copied resolute rootfs, avoiding the host
suite autodetection. It reported:

```text
PASS: Installation and purging test.
PASS: All tests.
```

The earlier piuparts run that autodetected the host's `stonking` suite is not
used as evidence. These isolated lifecycle results strengthen local P04 QA;
they do not establish Debian policy approval, reproducible builds, package
ownership, signing, or PPA/publication readiness.

## Local APT dependency-stack follow-up (2026-09-20)

A local file-repository test was run in a fresh copy of the resolute rootfs.
The repository contained only the locally built P02, P03, MPC 1.4.1, and P04
artifacts; its `Packages` index used relative filenames. With `/proc` mounted
for package maintainer scripts, APT installed the complete stack without
`LD_LIBRARY_PATH`, a private prefix, or source-tree paths:

```text
libgmpfrxx-mkii-dev 1.4.1-1
libmpc-dev 1.4.1-1~ppa1
libmpc3 1.4.1-1~ppa1
libmplapack-mpfr-dev 3.0.1-1
libmplapack-mpfr3 3.0.1-1
octave-mplapack-interop 0.5.0-1
```

The installed package smoke passed real matrix multiplication, QR, LU, and
the default 512-bit precision check:

```text
local apt stack smoke PASS
```

The interop package was then removed and reinstalled from the same local APT
repository; the second installed smoke also passed:

```text
local apt reinstall smoke PASS
```

This closes the local APT/lifecycle evidence item for the draft stack. It does
not replace PPA apt-install validation, Debian policy review, reproducibility,
signing, or external publication.

## P02/P03 package autopkgtest follow-up (2026-09-20)

The P02 and P03 test controls were also made compatible with autopkgtest 5.55
by removing the obsolete `Features: test-name=...` field when `Tests:` is
present. Fresh copied resolute rootfs runs produced:

```text
P02 gmpfrxx-mkii:  smoke PASS (superficial)
P03 mplapack:      mpfr-backend PASS (superficial)
```

The command exit status was `8` because autopkgtest defines an all-superficial
test run as neutral rather than positive; it is not a test failure. The P03
probe compiled against the installed package headers and libraries and
exercised both MPFR `Rgemm` and MPC `Cgemm`. As with P04, these are isolated
local testbed results, not Debian/Launchpad worker acceptance.

## P04 reproducibility remediation follow-up (2026-09-20)

The initial two-build comparison found that the released multi-source
`mkoctfile` invocation retained random `/tmp/oct-*.o` names in split debug
records. The P04 Debian draft now applies the packaging-only quilt patch
`reproducible-mkoctfile-debug-paths.patch`, which adds source/debug prefix maps
to the released `src/Makefile`; no numerical source or upstream archive was
changed.

Two independent clean resolute sbuilds of the patched source package produced
byte-identical binary and split-debug artifacts:

```text
octave-mplapack-interop_0.5.0-1_amd64.deb
  f633b94666ef11cae16a7331d6a216fec98b1412fdb52725a9dcc6216aa6d711
octave-mplapack-interop-dbgsym_0.5.0-1_amd64.ddeb
  6fc50a6f59bc5e3dffbcb21fe100d513a1073d5b33db95f8d7eb52388f7fc6e6
```

This closes the local P04 reproducibility comparison, subject to Debian
packaging review. It does not establish official Debian/Launchpad acceptance.

## P02 provider SONAME candidate follow-up (2026-09-20)

The prior P02 draft placed the standalone provider in the development package
with an unversioned ELF SONAME. That produced the expected Lintian
`lacks-ldconfig-trigger`, `package-name-doesnt-match-sonames`, and
`shared-library-lacks-version` findings. A packaging-only quilt patch now sets
the CMake target `VERSION` to `1.4.1` and `SOVERSION` to `1`, adds
`libgmpxx-mkii-default-context-provider1`, and leaves only the linker symlink
in `libgmpfrxx-mkii-dev`.

Evidence:

```text
clean resolute sbuild: successful
direct binary lintian: only initial-upload-closes-no-bugs warnings
provider SONAME: libgmpxx_mkII_default_context_provider.so.1
runtime package install/ldconfig: PASS in the local resolute stack rootfs
local `libgmpfrxx-mkii-dev` SHA256:
  510df2c145745e35525cd06cf53c0a97675774247db24d75a13dd774a4264b87
local `libgmpxx-mkii-default-context-provider1` SHA256:
  ca91c2002018d4e3135a55ead76e73e859c2561e553482449161fc34ca76263b
```

The split candidate was then exercised in a fresh copied resolute testbed
with a local file repository containing the candidate provider/development
packages and MPC 1.4.1:

```text
autopkgtest smoke: PASS (superficial; exit 8 is autopkgtest's all-superficial status)
provider compile/run smoke: PASS
remove/reinstall of libgmpfrxx-mkii-dev: PASS
post-reinstall provider SONAME/ldconfig: PASS
```

This is stronger local lifecycle evidence for the split candidate, but it is
not an official Ubuntu/Debian worker result and does not close maintainer,
signing, or publication review.

The source-package Lintian run still reports the bundled-GMP license findings
and the draft unreleased changelog. Placeholder maintainer metadata,
symbols/Multi-Arch policy, and Debian review remain open, so P02 and the
overall controller remain `PARTIAL`.

## P02 `+dfsg` source repack experiment (2026-09-20)

The source Lintian license findings were isolated to the unused upstream
reference snapshot under `reference/upstream`, including bundled GMP GFDL
documents with invariant sections. A temporary `1.4.1+dfsg-1` source build
used the Debian `Files-Excluded: reference/upstream` policy and the
`repacksuffix=+dfsg` watch option. The resulting source and binary Lintian
run reported no errors; remaining output was limited to watch-file/package
informational tags and the expected initial-upload warnings.

The locally generated repacked orig archive was:

```text
SHA256: 94792367fa08f50967319f3294cf7376688eaf172869df1227f61d1c9476ba87
size:   14792668 bytes
```

The temporary build also completed cleanly with the provider `.so.1` split.
This is the preferred next P02 packaging direction, but it still requires
rebuilding the submitted source from a reproducible uscan/repack workflow and
Debian review of copyright, watch, symbols, and maintainer metadata.
