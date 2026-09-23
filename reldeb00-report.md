# RELDEB00 RESULT

## Result

`PARTIAL` — local release provenance and package-name/architecture audits are
complete, and clean Ubuntu 26.04/resolute chroot builds now succeed for the
P02, P03, P04, and MPC 1.4.1 prerequisite drafts. Debian policy/lifecycle QA,
signing, and all public submission stages remain incomplete.

## Upstream release provenance

| Component | Version | Tag/commit | Archive | SHA256 |
|---|---|---|---|---|
| gmpfrxx_mkII | 1.4.1 | `v1.4.1`, `32a7fb797202cdf92312ed9d133f96fdbcda590a` | `gmpfrxx_mkII.1.4.1.tar.xz` | `395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4` |
| MPLAPACK | 3.0.1 | `v3.0.1`, tag `7646ad96f15d46c4d15333114e98d499e007e09f`, archive source `953d7a4916554546937a753a30b0619691072841` | `mplapack-3.0.1.tar.xz` | `47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa` |
| mplapack-interop | 0.5.0 | `v0.5.0`, `7187a0f6c5a40a4d5774f4f913b166ccb6a5dffa` | `mplapack-interop-0.5.0.tar.gz` | `3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04` |
| GNU MPC prerequisite | 1.4.1 | upstream release | `mpc-1.4.1.tar.xz` | `91204cd32f164bd3b7c992d4a6a8ce6519511aadab30f78b6982d0bf8d73e931` |

All three archives were downloaded from published GitHub release assets and
hashed locally. The interop archive reports `Name: mplapack-interop`,
`Version: 0.5.0`, and `Depends: octave (>= 11.1.0)`.

## Package-name audit

No result was returned by `packages.debian.org` name search for `gmpfrxx`,
`gmpfrxx-mkii`, `mplapack`, `octave-mplapack`, or
`octave-mplapack-interop`. Debian tracker/BTS source reports found no
maintainer/package for the three proposed names. No active local collision was
found. This is an availability audit, not an ITP filing.

```text
gmpfrxx-mkii            AVAILABLE, proposal
mplapack                AVAILABLE, proposal
octave-mplapack-interop AVAILABLE, proposal
WNPP                    no local active ITP/RFP evidence found
mentors/Salsa           no local collision found; repeat before filing
```

## Team routing

`gmpfrxx-mkii` and `mplapack` are proposed for Debian Science routing.
`octave-mplapack-interop` is proposed for the Debian Octave Group, with
Science co-maintenance as a possible dependency-stack arrangement. No team
consent, sponsor, Salsa repository, or maintainer identity has been obtained;
all statuses are explicitly PROPOSED in `TEAM-ROUTING.md`.

## Debian binary package architecture

```text
gmpfrxx_mkII:            headers/CMake/provider audited; provider SONAME unversioned
MPLAPACK:                libmplapack_mpfr.so.3 plus development headers/pkg-config expected
octave interop:          architecture-dependent Octave .oct binary
MPC prerequisite:        libmpc3/libmpc-dev 1.4.1 required for mpc_log2
SONAMEs:                 gmpfrxx provider unversioned; MPLAPACK runtime .so.3
Multi-Arch/symbols:      pending Debian package build and policy review
```

The unversioned gmpfrxx provider is a concrete P02 ABI blocker. A draft
`libgmpfrxx-mkii-dev` source/binary package was built locally, but it has
placeholder maintainer metadata and is not Debian-ready. The full audit and
license inventory are in `release/debian/PACKAGING-AUDIT.md` and
`release/debian/ABI-AND-MULTIARCH.md`; build evidence is in
`release/debian/QA-EVIDENCE.md`.

The released interop bridge also requires GNU MPC 1.4.0 or newer because it
calls `mpc_log2`. Ubuntu 26.04 currently ships MPC 1.3.1. This is an external
dependency gap, not an MPLAPACK or gmpfrxx_mkII bug. A local `mpclib3` 1.4.1
draft package was built and installed; P04 then loaded and passed its smoke
test. The staging PPA therefore needs `mpclib3` before the three project
packages.

## Licensing

BSD-2-Clause was verified for gmpfrxx_mkII and octave-mplapack-interop.
MPLAPACK's `COPYING` includes its MPLAPACK 2-clause BSD-style terms and the
bundled LAPACK/BLAS notices. System GMP/MPFR/MPC licenses were inventoried.
DEP-5 and Debian NEW review remain P02/P03 work.

## Local Debian QA

```text
debhelper/dh-octave/lintian/autopkgtest/debuild/sbuild/piuparts/reprotest: available
gbp/uscan/dput/reportbug/debsign: available; no identity/upload key configured
clean testbed: Ubuntu 26.04/resolute amd64 schroot registered
runtime:       installed pkg-config reports mplapack_mpfr 3.0.1
```

The gmpfrxx 1.4.1 release was independently CMake-built and its upstream
CTest suite passed 156/156 tests in an isolated install. This is upstream
smoke evidence, not a Debian package PASS.

The committed test-only provider ABI/TLS probe also passed against the
released gmpfrxx provider: ABI version/size, exported mode/token functions,
independent 256/2048-bit worker contexts, 1024-bit main context, and reset
behavior all matched the provider contract. This does not resolve the
provider's unversioned SONAME packaging policy.

## Ubuntu staging PPA

```text
Target: Ubuntu 26.04, amd64 first
PPA/uploads/apt install: NOT CREATED / NOT PERFORMED
```

Launchpad account/PPA/upload-key credentials are not configured. U01 is the
exact resumable external gate after P02–P05.

## Debian submission

```text
ITPs: NOT FILED       Salsa: NOT CREATED       mentors: NOT PUBLISHED
RFS: NOT FILED        sponsor: NONE            NEW: NOT SUBMITTED
sid: NOT ACCEPTED
```

No public action was attempted. See `release/debian/PUBLIC-SUBMISSION-STATUS.md`.

## External blockers

1. Provision a clean Debian/Ubuntu testbed with `sbuild`/`autopkgtest`,
   reproducibility tooling, and signing support. `debhelper`/`dh-octave` and
   `lintian` are available in the local lab, but this is not a clean testbed.
2. Provide/package GNU MPC 1.4.1 (or a compatible Ubuntu update) for the
   `mpc_log2` ABI required by interop 0.5.0. The local draft succeeds, but no
   PPA upload or Debian sponsorship exists.
3. Resolve the standalone gmpfrxx provider's unversioned SONAME/ABI packaging
   decision. The validated MPFR-only MPLAPACK library does not link that
   provider, so this blocker is isolated to independent gmpfrxx consumers and
   does not change the interop runtime dependency closure.
4. Complete P02–P04 source packages using system dependencies and Debian
   copyright/repackaging policy.
5. Obtain Debian team/sponsor/Salsa/mentors and Launchpad identities before
   any public submission.

## Final state

```text
PPA-STAGING-VALIDATED:    NO
DEBIAN-PACKAGING-READY:   NO
DEBIAN-ITP-FILED:         NO
DEBIAN-MENTORS-PUBLISHED: NO
DEBIAN-RFS-FILED:         NO
DEBIAN-OFFICIAL-ACCEPTED: NO
UBUNTU-OFFICIAL-SYNCED:   NO
```

Resume at P02/P03 policy closure after the clean-testbed, provider ABI, and
MPC prerequisite blockers are resolved. The current draft is evidence to
refine, not a submission artifact. Do not repeat the
release downloads or create duplicate ITP/RFS/PPA submissions. Do not begin
unrelated numerical work.

## Final milestone record

Branch: `topic/reldeb00-debian-ppa`

Starting commit: `18454dda239f76061cafc37b47856db58267c0ea`

Handoff commit: `4eb13233c232c29cded65dd86d6917fcea73c6e5`

Report commit: the subsequent report-only commit containing this correction

Files changed: `release/debian/*`, this report, and the controller goal file

Commands run: release-asset download/hash inspection; `git ls-remote`; CMake /
CTest gmpfrxx release smoke; GNU MPC 1.4.1 build/package smoke; package/SONAME
inspection; Debian package-name search; toolchain availability audit

Tests: gmpfrxx upstream CTest 156/156 PASS; archive SHA256 PASS;
`tools/check-format.sh`, `tools/check-tree.sh`, and
`tools/check-github-math.sh` PASS. With the validated prefix supplied through
`PKG_CONFIG_PATH`, `tools/local-ci.sh` passed the dependency probe, native
M00–M21 probes, M20 complex probes, and many public/NEIG checks, but the user
requested that the long-running run be interrupted before completion. It is
not a full local-CI PASS. Debian package QA/PPA/public submission remain NOT
RUN or BLOCKED as recorded above.

Gate: `R00 PASS`, `P00 PASS`, `P01 PARTIAL`, `P02 PARTIAL`, `P03 PARTIAL`, `P04 PARTIAL`, overall `RELDEB00 PARTIAL`

Known limitations: the P02 draft is not a Debian submission; provider
ABI/SONAME policy, final package splits, clean-testbed P03/P04 builds,
reproducibility, PPA publication, ITP/Salsa/mentors/RFS, and official
acceptance remain undone. The local P04 smoke requires the draft MPC 1.4.1
prerequisite because Ubuntu MPC 1.3.1 does not export `mpc_log2`.

## Subsequent local-only packaging progress

After the handoff/report commits above, the branch added the following
review-only evidence without changing upstream numerical code:

- `c45dbac` expanded the P04 installed-package smoke draft to cover real
  arithmetic/solve, Cholesky, QR, pivoted QR, LU, complex construction,
  eig/SVD, deterministic RNG, and binary serialization.
- `bbf950e` recorded the fresh `dpkg-source -b` source-boundary result and
  clarified that the unavailable `dh` executable prevents a binary build.
- `01ae2a2` recorded the upstream BSD-2-Clause text in the P04 copyright
  draft.

The subsequent P03 draft also adds a Debian packaging-only `dh_auto_configure`
override which selects the MPFR/system-dependency build and removes the
upstream MPFR template's installed-library `DT_RUNPATH`, plus a
`debian/not-installed` manifest for static/libtool/misc files intentionally
outside the proposed binary split. A fresh build from the released
`mplapack-3.0.1.tar.xz` archive reached binary packages:

```text
libmplapack-mpfr3_3.0.1-1_amd64.deb
libmplapack-mpfr-dev_3.0.1-1_amd64.deb
```

Local `lintian --pedantic` reported only the expected initial-upload warning;
`readelf -d` showed the expected `.so.3` SONAMEs and no RPATH/RUNPATH. The
corrected runtime package hash is
`6f13670c4f3310b60b9ff639c333fc8543a0a80147170b438f15406ff960ee3c`; the
development package hash is
`5c7f4575031aefaf2c49d3377dfb037f81d048e6b97fd9f7b541328fe18ecfea`.
This is stronger local binary evidence, but P03 remains PARTIAL because the
maintainer is still a placeholder, package names/splits are proposals, no
clean Debian testbed or reproducibility run exists, and no upload was made.

With the locally installed draft P03 packages, a fresh P04 build of the
released `mplapack-interop-0.5.0` archive reached and completed the real
`dh-octave` binary stage, producing `octave-mplapack-interop_0.5.0-1_amd64.deb`.
`lintian --pedantic` reported only the expected initial-upload warning. The
first attempt was not clean-system evidence because the upstream MPLAPACK
`.pc` file pulled `mpc` metadata from `/usr/local`; Ubuntu's `libmpc-dev` has
no `mpc.pc`. The P03 packaging rules now normalize the staged `.pc` files to
direct system link flags. The first post-fix build exposed that the hook must
target `debian/tmp` before package splitting; that path is now corrected.
Clean post-fix P03/P04 and testbed evidence remains pending, so the overall
gate stays PARTIAL.

With the corrected P03 packages and the local `mpclib3` 1.4.1 prerequisite,
the P04 package hash is
`280079d3b1b4370570b1b807ae1521e6cd6082ecc81807c3db9a9041ac6f46c2` and the
installed-package smoke passes. Repeating the installed-package load against
Ubuntu MPC 1.3.1 fails predictably with `undefined symbol: mpc_log2`, so the
MPC 1.4.1 prerequisite is a real PPA dependency gate. This is not Debian
binary-package or autopkgtest evidence: P04, P05, PPA, and public Debian
submission remain partial or blocked as described above.

### Clean chroot follow-up (2026-09-20)

The Debian toolchain was installed locally and an Ubuntu 26.04/resolute amd64
schroot was registered as `resolute-amd64-sbuild`. Because the host has no
root subuid mapping, sbuild was invoked with `--chroot-mode=schroot`. Clean
source builds then completed with `Status: successful` for:

```text
gmpfrxx-mkii 1.4.1-1
mplapack 3.0.1-1 (with the P02 development package)
mpclib3 1.4.1-1~ppa1 (75/75 upstream MPC tests passed)
octave-mplapack-interop 0.5.0-1 (with P02/P03/MPC 1.4.1 injected)
```

The P04 clean build output included the installed interface checks:

```text
PASS: mplapack_mpfr 3.0.1
PASS: MPLAPACK MPFR uniform-precision interface probe
```

Clean-build hashes are recorded in `release/debian/QA-EVIDENCE.md`. The
separate sbuild Lintian stage still fails on draft `UNRELEASED` changelog
metadata and the known P02 provider SONAME/ldconfig findings. Thus this is
stronger build evidence, not `P02/P03/P04/P05 PASS`; package lifecycle,
autopkgtest, reproducibility, Debian ownership/signing, and PPA publication
remain open.

### Isolated P04 lifecycle follow-up (2026-09-20)

After the clean-build run, the committed P04 autopkgtest control was made
Ubuntu 26.04-compatible: it depends on `octave` rather than the unavailable
separate `octave-cli` package, and it no longer combines `Tests:` with the
unsupported `Features: test-name=...` field. The smoke test suppresses only
Octave's shadowed-function warnings. Running `autopkgtest` in a fresh copied
`resolute-amd64-sbuild` rootfs reported:

```text
smoke PASS (superficial)
```

The corrected source was rebuilt with clean resolute sbuild and again reported
`Status: successful`; its P04 package hash is
`38e5db17c3371e373833ad3222d488a560297fe6ea35dac9a1815a587cf49f50`.

`piuparts --distribution=resolute` also passed installation and purging in a
copied resolute rootfs. An earlier piuparts run that autodetected the host's
`stonking` suite is excluded from evidence. These are isolated local package
QA results, not Debian/Launchpad worker acceptance. P04 remains PARTIAL while
package policy/ownership, reproducibility, signing, and publication remain
open.

### Local APT stack follow-up (2026-09-20)

A fresh copied resolute rootfs was given a local file APT repository containing
the P02, P03, MPC 1.4.1, and P04 draft packages. After mounting `/proc` for
Ubuntu maintainer scripts, APT installed the complete dependency stack without
private prefixes, `LD_LIBRARY_PATH`, or source-tree paths. The installed smoke
covered matrix multiplication, QR, LU, and the 512-bit default and reported:

```text
local apt stack smoke PASS
```

Removing and reinstalling `octave-mplapack-interop` from that same repository
then reported:

```text
local apt reinstall smoke PASS
```

This is local file-repository evidence only; PPA apt-install QA, Debian policy
review, reproducibility, signing, and public submission remain external or
pending.

### P02/P03 package autopkgtest follow-up (2026-09-20)

The P02 and P03 autopkgtest controls were corrected to remove the obsolete
`Features: test-name=...` field when `Tests:` is present. Fresh copied
resolute-rootfs runs reported:

```text
P02 gmpfrxx-mkii:  smoke PASS (superficial)
P03 mplapack:      mpfr-backend PASS (superficial)
```

Their process exit status was `8`, which autopkgtest intentionally uses when
all tests are marked `superficial`; the summaries contain no failed test. The
P03 test compiled against the installed package and exercised both MPFR
`Rgemm` and MPC `Cgemm`. These results are local isolated evidence only and do
not imply Debian or Launchpad acceptance.

### P04 reproducibility comparison (2026-09-20)

Two independent clean resolute sbuilds from the same corrected P04 source
package produced different package hashes:

```text
build A  38e5db17c3371e373833ad3222d488a560297fe6ea35dac9a1815a587cf49f50
build B  659c00d4f42495d47a801fcd6069367f563dbddac80d3f5355e41424b0f42e92
```

`diffoscope` limited the package difference to the extension's ELF build-id
and debuglink; removing those sections made the extension binaries identical.
The build logs show random `/tmp/oct-*.o` names from `mkoctfile` in split debug
data. This is recorded as a genuine draft P04 reproducibility defect. No
override or numerical-source workaround was added, so reproducibility remains
open and P05 cannot be marked PASS.

### P04 reproducibility remediation follow-up (2026-09-20)

The Debian P04 draft now carries the packaging-only quilt patch
`reproducible-mkoctfile-debug-paths.patch`. It adds source/debug prefix maps to
the released `mkoctfile` build so random temporary object names do not affect
the generated extension's debug records. The upstream numerical source and
released archive remain unchanged.

Two independent clean resolute sbuilds of the patched source package produced
identical artifacts:

```text
octave-mplapack-interop_0.5.0-1_amd64.deb
  f633b94666ef11cae16a7331d6a216fec98b1412fdb52725a9dcc6216aa6d711
octave-mplapack-interop-dbgsym_0.5.0-1_amd64.ddeb
  6fc50a6f59bc5e3dffbcb21fe100d513a1073d5b33db95f8d7eb52388f7fc6e6
```

The local reproducibility item is now PASS for the patched draft. P02 provider
ABI policy, Debian ownership/signing, and external PPA/submission gates remain
open.
