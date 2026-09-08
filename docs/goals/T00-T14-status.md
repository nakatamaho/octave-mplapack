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

Last required PASS milestone: `T14`
T05R1: `NOT NEEDED — T05 ALREADY CLOSED`

Final controller HEAD:
`246f9dafe3a1576172315c7b6667aeb44a3a1e4e`

Final dependency identities used by the controller:

| Dependency | Tested identity |
|---|---|
| gmpfrxx_mkII | `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1` |
| MPLAPACK | `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` / MPFR 3.0.1 interface |

The final wall passed M00–M23, C00–C12 including C11L, N00–N08, S00–S08,
T00–T14, Grcar/generalized eig, serialization, graphics, RNG,
interpolation, fzero/fsolve, quadrature, optimization, the unsupported API
firewall, and the installed-package lifecycle.  Native ASan, UBSan, and
LSan completed successfully.  The only CI repair was allowing the existing
`0.5.0-dev` development version in `tools/local-ci.sh`; no numerical behavior
was changed by that repair.

D04-READY: yes
T15-T20-READY-FOR-PLANNING: yes

D04 and T15–T20 were not started automatically.
