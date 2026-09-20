# RELDEB00 RESULT

## Result

`PARTIAL` — local release provenance and package-name/architecture audits are
complete, non-submission P02/P03/P04 packaging drafts build source metadata in
an unprivileged lab, and provider/header smoke evidence is recorded. Debian
package QA and all public submission stages remain blocked by the current
environment and missing external identities.

## Upstream release provenance

| Component | Version | Tag/commit | Archive | SHA256 |
|---|---|---|---|---|
| gmpfrxx_mkII | 1.4.1 | `v1.4.1`, `32a7fb797202cdf92312ed9d133f96fdbcda590a` | `gmpfrxx_mkII.1.4.1.tar.xz` | `395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4` |
| MPLAPACK | 3.0.1 | `v3.0.1`, tag `7646ad96f15d46c4d15333114e98d499e007e09f`, archive source `953d7a4916554546937a753a30b0619691072841` | `mplapack-3.0.1.tar.xz` | `47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa` |
| mplapack-interop | 0.5.0 | `v0.5.0`, `7187a0f6c5a40a4d5774f4f913b166ccb6a5dffa` | `mplapack-interop-0.5.0.tar.gz` | `3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04` |

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
SONAMEs:                 gmpfrxx provider unversioned; MPLAPACK runtime .so.3
Multi-Arch/symbols:      pending Debian package build and policy review
```

The unversioned gmpfrxx provider is a concrete P02 ABI blocker. A draft
`libgmpfrxx-mkii-dev` source/binary package was built locally, but it has
placeholder maintainer metadata and is not Debian-ready. The full audit and
license inventory are in `release/debian/PACKAGING-AUDIT.md` and
`release/debian/ABI-AND-MULTIARCH.md`; build evidence is in
`release/debian/QA-EVIDENCE.md`.

## Licensing

BSD-2-Clause was verified for gmpfrxx_mkII and octave-mplapack-interop.
MPLAPACK's `COPYING` includes its MPLAPACK 2-clause BSD-style terms and the
bundled LAPACK/BLAS notices. System GMP/MPFR/MPC licenses were inventoried.
DEP-5 and Debian NEW review remain P02/P03 work.

## Local Debian QA

```text
sbuild/lintian/autopkgtest/piuparts/reprotest: BLOCKED (not installed)
local apt tool installation:                  BLOCKED (unprivileged apt lock)
runtime:                                      installed pkg-config reports mplapack_mpfr 3.0.1
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

1. Install the Debian packaging QA toolchain (`debhelper`/`dh-octave`,
   `debuild`, `lintian`, `sbuild`, `autopkgtest`, `piuparts`, `reprotest`,
   `gbp`, `uscan`, `dput`, `reportbug`, and signing support) in a privileged
   Ubuntu/Debian build environment.
2. Resolve the standalone gmpfrxx provider's unversioned SONAME/ABI packaging
   decision. The validated MPFR-only MPLAPACK library does not link that
   provider, so this blocker is isolated to independent gmpfrxx consumers and
   does not change the interop runtime dependency closure.
3. Complete P02–P04 source packages using system dependencies and Debian
   copyright/repackaging policy.
4. Obtain Debian team/sponsor/Salsa/mentors and Launchpad identities before
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

Resume at P02 after the ABI and toolchain blockers are resolved. The current
draft is evidence to refine, not a submission artifact. Do not repeat the
release downloads or create duplicate ITP/RFS/PPA submissions. Do not begin
unrelated numerical work.

## Final milestone record

Branch: `topic/reldeb00-debian-ppa`

Starting commit: `18454dda239f76061cafc37b47856db58267c0ea`

Handoff commit: `4eb13233c232c29cded65dd86d6917fcea73c6e5`

Report commit: the subsequent report-only commit containing this correction

Files changed: `release/debian/*`, this report, and the controller goal file

Commands run: release-asset download/hash inspection; `git ls-remote`; CMake /
CTest gmpfrxx release smoke; package/SONAME inspection; Debian package-name
search; toolchain availability audit

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
ABI/SONAME policy, final package splits, full P03/P04 builds,
lintian/autopkgtest/reproducibility, PPA publication, ITP/Salsa/mentors/RFS,
and official acceptance remain undone.
