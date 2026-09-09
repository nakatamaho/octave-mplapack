# T00–T14 controller status

This document tracks the continuation after the immutable D03 baseline.

## Immutable D03 baseline

| Item | Identity |
|---|---|
| D03 freeze commit | `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31` |
| D03 report/status commit | `ca78481559e00f80534aa4c89dedaa838fdf3953` |
| D03 tag | `v0.4.0` |
| D03 archive | `/home/docker/src/mplapack-interop-0.4.0.tar.gz` |
| D03 archive SHA256 | `6bc87d42fbda49fa72830db34fbede7b8b9f46b7614b14dc53e7619c7781536c` |

The D03 tag, archive, and freeze commit are historical and are not modified.

## Development identity

The T-series development version is `0.5.0-dev`.  D04 owns the final release
version and tag freeze.

## Milestones

| Milestone | Result | Evidence |
|---|---|---|
| T00 Schur/QZ | PASS | `reports/T00-report.md` |
| T01 advanced dense utilities | PASS | `reports/T01-report.md` |
| T02 matrix functions | PASS | `reports/T02-report.md` |
| T03 polynomial core | PASS | `reports/T03-report.md` |
| T04 exact sets | PASS | `reports/T04-report.md` |
| T05 gamma/erf | PASS | `reports/T05-report.md` |
| T06 special-function audit | PASS | `reports/T06-report.md`, `docs/special-functions-backend-matrix.md` |
| T07 serialization | PASS | `reports/T07-report.md`, `docs/serialization.md` |
| T08 3-D graphics | PASS | `reports/T08-report.md`, `docs/graphics.md` |
| T09 arbitrary-precision RNG | PASS | `reports/T09-report.md`, `docs/rng.md` |
| T10 1-D interpolation | PASS | `reports/T10-report.md`, `docs/interpolation-1d.md` |
| T11 2-D interpolation | PASS | `reports/T11-report.md`, `docs/interpolation-2d.md`, `docs/todo/T11-ND-interpolation.md` |
| T12 nonlinear equations | PASS | `reports/T12-report.md`, `docs/nonlinear-solvers.md` |
| T13 quadrature | PASS | `reports/T13-report.md`, `docs/quadrature.md` |
| T14 optimization | PASS | `reports/T14-report.md`, `docs/optimization.md` |
| T05R1 late recheck | NOT-NEEDED | `reports/T05R1-report.md` |

## Precision contract

All numerical paths remain one-operation/one-precision MPFR/MPC paths.  The
new T00 drivers use operation-owned copies for destructive LAPACK calls and
establish the matching real and complex precision scopes at every backend
boundary.  No builtin binary64 fallback is part of the T-series interface.

## Controller closure

Result: `T00-T14 CONTROLLER PASS`
Acceptance: `T00-T14: ACCEPT`

Last required PASS milestone: `T14`
T05R1: `NOT NEEDED — T05 ALREADY CLOSED`

Final tested controller HEAD:
`8ba6d849fa188765b372d9aa9f899d9de98a78cf`

Final dependency identities used by the controller:

| Dependency | Tested identity |
|---|---|
| gmpfrxx_mkII | `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1` |
| MPLAPACK | `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` / MPFR 3.0.1 interface |

The T00–T14 development milestone history referenced gmpfrxx_mkII
`32a7fb797202cdf92312ed9d133f96fdbcda590a` (`v1.4.1`) and the historical
MPLAPACK development/interface commit
`a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`.

Neither dependency repository was modified during T00–T14.

For D04 release-candidate QA, the authoritative MPLAPACK dependency is
instead the MPLAPACK 3.0.1 release candidate identified in the following
section by commit, tarball, and SHA256.

## D04 release-candidate provenance

`T00-T14: ACCEPT` and `D04-READY: YES` have been recorded. The first
documented D04 candidate was MPLAPACK 3.0.1 commit
`c21a9f56224308afda9e7424ca9928d4cf840f7a`, represented by the local release-
candidate archive `~/src/mplapack-3.0.1.tar.xz` and the archived QA copy
`release/logs/20260907_143628/source/mplapack-3.0.1.tar.xz`. The expected
SHA256 for both artifacts is
`f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1`; the
release-QA evidence directory is `release/logs/20260907_143628/`.

The local candidate archive hash was verified in the previous candidate
environment. D04
must verify the archived QA copy has the same hash before the source freeze.
Until the release process completes, this dependency must be described as the
`MPLAPACK 3.0.1 release candidate`, not as finally released MPLAPACK 3.0.1.

### Current D04 RC update — 2026-09-09

The current MPLAPACK 3.0.1 release candidate supersedes the previous
candidate identity:

```text
commit:  c7e56f15dd4dc6413a1dc80b9d1c4109b77d5078
archive: mplapack-3.0.1.tar.xz
SHA256:  77008a2d6cc7b2d310a4d606e013003923872a6840f1098dda8b6f337f137afa
```

The D04 source-freeze and regression evidence must use this exact commit or
an installed MPLAPACK build demonstrably derived from an archive with this
SHA256. The local archive `/home/docker/src/mplapack-3.0.1.tar.xz` now
verifies against this SHA256 and has size `85562992` bytes. The archived QA
copy from the previous candidate evidence directory is not present in this
worktree and must be checked separately if it is used for D04 provenance. The
dependency must continue to be described as the `MPLAPACK 3.0.1 release
candidate` until the release process completes.

Historical T-series identities such as `a59e5a0...` and earlier release-
preparation commits such as `fa3ccb...` remain milestone provenance. They are
not D04 release-QA provenance and require no reconciliation. D04 may consume
the local archive directly or an installed build demonstrably derived from it;
no rebuild is required solely to reconcile those historical Git SHAs.

The final wall passed M00–M23, C00–C12 including C11L, N00–N08, S00–S08,
T00–T14, Grcar/generalized eig, serialization, graphics, RNG,
interpolation, fzero/fsolve, quadrature, optimization, the unsupported API
firewall, and the installed-package lifecycle.  Native ASan, UBSan, and
LSan completed successfully.  The only CI repair was allowing the existing
`0.5.0-dev` development version in `tools/local-ci.sh`; no numerical behavior
was changed by that repair. The final documentation audit added the complete
advanced-numerics index, structured deferred TODO records, and common metadata
to every individual milestone report. The report/status pointer is updated by
the following documentation-only
commit; the tested controller source and evidence remain unchanged.

D04-READY: yes
T15-T20-READY-FOR-PLANNING: yes

D04 and T15–T20 were not started automatically.
