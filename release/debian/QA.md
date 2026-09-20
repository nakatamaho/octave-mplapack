# Debian/PPA QA tracker

This tracker uses `PASS`, `PARTIAL`, `FAIL`, `PENDING`, `N/A`, and `BLOCKED`.
It is a resumable controller record, not a claim that the current drafts are
upload-ready.

| Check | Status | Evidence / next action |
|---|---|---|
| Released source archives and SHA256 | PASS | `PROVENANCE.md`, `SHA256SUMS` |
| P02 source skeleton | PASS | source-only `.dsc` generation; binary draft remains partial |
| P02 provider ABI/SONAME policy | PASS (local draft) | packaging-only target SOVERSION 1, split runtime provider, and direct binary Lintian pass; Debian ABI review remains |
| P02 build-time/autopkgtest | PASS (local superficial) | split candidate clean resolute sbuild, copied-rootfs autopkgtest, provider smoke, and remove/reinstall pass; official policy/lifecycle remains pending |
| P03 source skeleton | PASS | source-only `.dsc` generation from 3.0.1 archive |
| MPC 1.4.1 prerequisite | PASS (local draft) | `mpclib3` binary build/lintian; PPA/Debian ownership pending |
| P03 binary build | PARTIAL | clean resolute sbuild build succeeds; policy/lifecycle review pending |
| P03 symbols/shlibs/Multi-Arch | PENDING | Debian policy review |
| P03 installed real/complex probes | PASS (superficial) | copied-resolute MPLAPACK MPFR backend autopkgtest passes; Debian policy review remains |
| P04 source skeleton | PASS | source-only `.dsc` generation from 0.5.0 archive |
| P04 binary build | PARTIAL | clean resolute sbuild build succeeds with injected MPC 1.4.1; package-policy review remains |
| P04 autopkgtest | PASS (superficial) | isolated copied resolute rootfs smoke passed; official testbed/public archive lifecycle remains pending |
| sbuild resolute amd64 | PARTIAL | registered schroot; clean P02/P03/P04 builds pass, Lintian policy remains |
| lintian --pedantic | PARTIAL | P02 binary candidates have only expected initial-upload warnings; source draft has licensing/unreleased-changelog findings and P03/P04 policy review remains |
| autopkgtest | PASS (superficial) | P02/P03/P04 copied Ubuntu 26.04/resolute rootfs smoke tests pass; superficial-only exit 8 is expected |
| piuparts | PASS (local) | resolute existing-rootfs install/purge test passed; package policy/ownership remains open |
| local APT stack | PASS (local) | file-repository install of P02/P03/MPC/P04 plus remove/reinstall smoke passed in resolute rootfs |
| reprotest/diffoscope | PASS (local patch) | two independent clean patched P04 builds are byte-identical; packaging-only source/debug prefix normalization removes the mkoctfile temporary/debug-path difference |
| license/DEP-5 review | PENDING | draft files explicitly incomplete |
| PPA Resolute build | BLOCKED | Launchpad account/PPA/upload key unavailable |
| PPA apt install | BLOCKED | requires published staging PPA |
| ITP | PENDING | drafts in `itp/`; reporter identity and WNPP recheck required |
| Salsa | BLOCKED | team namespace/maintainer identity unavailable |
| mentors | BLOCKED | signing key and account unavailable |
| RFS | PENDING | file after sponsored-package artifacts exist |
| NEW/sid acceptance | PENDING | downstream Debian process |
| Ubuntu sync | N/A | no accepted Debian package yet |

The isolated local piuparts/autopkgtest lifecycle checks and the local APT
dependency-stack install/remove/reinstall smoke now pass against an Ubuntu
26.04/resolute rootfs copy. A Debian packaging-only prefix-map patch was then
validated in two independent clean P04 sbuilds; the resulting binary package
and split debug package hashes matched exactly. The P02 provider candidate now
also builds with a versioned `.so.1` runtime split and direct binary Lintian
reports only the expected initial-upload warnings. The remaining local
actions are rerunning P02 copied-rootfs tests with that split package,
installed P03/P04 review, and Debian policy/identity work. No Debian/sid or
publication identity is implied.
