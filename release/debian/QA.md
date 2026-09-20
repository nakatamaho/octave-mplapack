# Debian/PPA QA tracker

This tracker uses `PASS`, `PARTIAL`, `FAIL`, `PENDING`, `N/A`, and `BLOCKED`.
It is a resumable controller record, not a claim that the current drafts are
upload-ready.

| Check | Status | Evidence / next action |
|---|---|---|
| Released source archives and SHA256 | PASS | `PROVENANCE.md`, `SHA256SUMS` |
| P02 source skeleton | PASS | source-only `.dsc` generation; binary draft remains partial |
| P02 provider ABI/SONAME policy | BLOCKED | Debian review required for unversioned provider SONAME |
| P02 build-time/autopkgtest | PARTIAL | clean resolute sbuild build succeeds; lifecycle/autopkgtest pending |
| P03 source skeleton | PASS | source-only `.dsc` generation from 3.0.1 archive |
| MPC 1.4.1 prerequisite | PASS (local draft) | `mpclib3` binary build/lintian; PPA/Debian ownership pending |
| P03 binary build | PARTIAL | clean resolute sbuild build succeeds; policy/lifecycle review pending |
| P03 symbols/shlibs/Multi-Arch | PENDING | Debian policy review |
| P03 installed real/complex probes | PENDING | run against built packages |
| P04 source skeleton | PASS | source-only `.dsc` generation from 0.5.0 archive |
| P04 binary build | PARTIAL | clean resolute sbuild build succeeds with injected MPC 1.4.1; package-policy review remains |
| P04 autopkgtest | PASS (superficial) | isolated copied resolute rootfs smoke passed; official testbed/public archive lifecycle remains pending |
| sbuild resolute amd64 | PARTIAL | registered schroot; clean P02/P03/P04 builds pass, Lintian policy remains |
| lintian --pedantic | PARTIAL | P03/P04 drafts have only the expected initial-upload warning; P02 provider ldconfig/SONAME findings remain |
| autopkgtest | PASS (superficial) | copied Ubuntu 26.04/resolute rootfs smoke passed; this is not Launchpad/Debian acceptance |
| piuparts | PASS (local) | resolute existing-rootfs install/purge test passed; package policy/ownership remains open |
| reprotest/diffoscope | PENDING | reprotest installed; reproducibility run remains |
| license/DEP-5 review | PENDING | draft files explicitly incomplete |
| PPA Resolute build | BLOCKED | Launchpad account/PPA/upload key unavailable |
| PPA apt install | BLOCKED | requires published staging PPA |
| ITP | PENDING | drafts in `itp/`; reporter identity and WNPP recheck required |
| Salsa | BLOCKED | team namespace/maintainer identity unavailable |
| mentors | BLOCKED | signing key and account unavailable |
| RFS | PENDING | file after sponsored-package artifacts exist |
| NEW/sid acceptance | PENDING | downstream Debian process |
| Ubuntu sync | N/A | no accepted Debian package yet |

The isolated local piuparts/autopkgtest lifecycle checks now pass against an
Ubuntu 26.04/resolute rootfs copy. The next local actions are reproducibility,
P02 provider/package policy, and installed P03/P04 probe review without
changing the released upstream numerical sources. No Debian/sid or publication
identity is implied.
