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
| T03 polynomial core | NOT-RUN | `reports/T03-report.md` |
| T04 exact sets | NOT-RUN | `reports/T04-report.md` |
| T05 gamma/erf | NOT-RUN | `reports/T05-report.md` |
| T06 special-function audit | NOT-RUN | `reports/T06-report.md` |
| T07 serialization | NOT-RUN | `reports/T07-report.md` |
| T08 3-D graphics | NOT-RUN | `reports/T08-report.md` |
| T09 arbitrary-precision RNG | NOT-RUN | `reports/T09-report.md` |
| T10 1-D interpolation | NOT-RUN | `reports/T10-report.md` |
| T11 2-D interpolation | NOT-RUN | `reports/T11-report.md` |
| T12 nonlinear equations | NOT-RUN | `reports/T12-report.md` |
| T13 quadrature | NOT-RUN | `reports/T13-report.md` |
| T14 optimization | NOT-RUN | `reports/T14-report.md` |
| T05R1 late recheck | NOT-RUN | `reports/T05R1-report.md` |

## Precision contract

All numerical paths remain one-operation/one-precision MPFR/MPC paths.  The
new T00 drivers use operation-owned copies for destructive LAPACK calls and
establish the matching real and complex precision scopes at every backend
boundary.  No builtin binary64 fallback is part of the T-series interface.
