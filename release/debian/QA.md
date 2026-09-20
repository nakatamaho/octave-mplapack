# Debian/PPA QA tracker

This tracker uses `PASS`, `PARTIAL`, `FAIL`, `PENDING`, `N/A`, and `BLOCKED`.
It is a resumable controller record, not a claim that the current drafts are
upload-ready.

| Check | Status | Evidence / next action |
|---|---|---|
| Released source archives and SHA256 | PASS | `PROVENANCE.md`, `SHA256SUMS` |
| P02 source skeleton | PASS | source-only `.dsc` generation; binary draft remains partial |
| P02 provider ABI/SONAME policy | BLOCKED | Debian review required for unversioned provider SONAME |
| P02 build-time/autopkgtest | PENDING | run in a clean Debian environment |
| P03 source skeleton | PASS | source-only `.dsc` generation from 3.0.1 archive |
| MPC 1.4.1 prerequisite | PASS (local draft) | `mpclib3` binary build/lintian; PPA/Debian ownership pending |
| P03 binary build | PARTIAL | local `.deb` build with corrected staged pkg-config metadata; clean testbed pending |
| P03 symbols/shlibs/Multi-Arch | PENDING | Debian policy review |
| P03 installed real/complex probes | PENDING | run against built packages |
| P04 source skeleton | PASS | source-only `.dsc` generation from 0.5.0 archive |
| P04 binary build | PARTIAL | local `.deb` build and installed smoke pass with MPC 1.4.1; clean testbed pending |
| P04 autopkgtest | PARTIAL | smoke source passes locally; no clean Debian testbed |
| sbuild sid amd64 | BLOCKED | `sbuild` unavailable in current environment |
| lintian --pedantic | PARTIAL | P03/P04 drafts have only the expected initial-upload warning; P02 provider ldconfig/SONAME findings remain |
| autopkgtest | PARTIAL | local smoke source passes; no clean Debian testbed |
| piuparts | BLOCKED | `piuparts` unavailable in current environment |
| reprotest/diffoscope | BLOCKED | tools unavailable in current environment |
| license/DEP-5 review | PENDING | draft files explicitly incomplete |
| PPA Resolute build | BLOCKED | Launchpad account/PPA/upload key unavailable |
| PPA apt install | BLOCKED | requires published staging PPA |
| ITP | PENDING | drafts in `itp/`; reporter identity and WNPP recheck required |
| Salsa | BLOCKED | team namespace/maintainer identity unavailable |
| mentors | BLOCKED | signing key and account unavailable |
| RFS | PENDING | file after sponsored-package artifacts exist |
| NEW/sid acceptance | PENDING | downstream Debian process |
| Ubuntu sync | N/A | no accepted Debian package yet |

The next local action is to install or use a privileged Debian/sid QA
environment, then rerun P02 through P05 without changing the released
upstream numerical sources.
