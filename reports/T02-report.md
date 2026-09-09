# T02 report — matrix functions

## Result

`T02 PASS — MATRIX FUNCTIONS CLOSED`

T02 adds matrix-valued `expm`, `sqrtm`, and `logm` methods for arbitrary-
precision real and complex `mp` values.  These are separate from the
element-wise functions and keep all matrix arithmetic in MPFR/MPC storage.

## Controller metadata

| Field | Value |
|---|---|
| Repository | `octave-mplapack` |
| Branch | `topic/t00-t14-continuation` |
| Starting commit | `7dc79f2d4c4fb7aa91a45822566bd0abc5ae533c` |
| Implementation commit / tip | `be8733167bfc7d78c28c60bd2af213b02769417a` |
| D03 baseline | `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31`, tag `v0.4.0` |
| Dependencies | gmpfrxx_mkII `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1`; MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` |
| Octave | GNU Octave 11.1.0 |
| API scope | Matrix `expm`, `logm`, and `sqrtm` for dense real/complex `mp` |
| Backend / algorithm | MPFR/MPC Schur reduction, scaling/squaring, triangular recurrence, and Mercator series |
| Precision policy | p-aware stopping and residuals; operation precision is never capped at binary64 |
| Real/complex behavior | Real inputs remain real when mathematically valid; complex promotion uses MPC only |
| Octave differential QA | Optional residual outputs, shapes, domains, and reconstruction checks |
| 1024/2048 QA | High-precision matrix-function and ambient-scope canaries PASS |
| Sanitizers | Native ASan, UBSan, and LSan walls PASS in final controller run |
| Previous regression | T00–T01 and D03 M00–M23/C00–C12/S00–S08 walls passed |
| Status / TODO | PASS; `funm`: `docs/todo/T02-funm.md` |

## Algorithms and contract

* `expm` uses precision-adaptive scaling and squaring with a Taylor series.
  The series is terminated using MPFR `eps` at the current result scale, so a
  fixed-degree approximant cannot cap accuracy at high source precision.
* `sqrtm` computes a complex Schur form through the T00 backend and applies
  the upper-triangular square-root recurrence.  Real matrices with negative
  eigenvalues are allowed to produce complex results.
* `logm` uses inverse scaling by repeated Schur-form square roots followed by
  a Mercator series.  Its stopping threshold is derived from MPFR `eps` at the
  current result scale and the source precision, rather than a host epsilon or
  a fixed binary64 threshold.
* `sqrtm(A)` supports the optional residual output.  `logm(A)` retains the
  optional residual output as an arbitrary-precision matrix norm.

## Focused evidence

`test/t02_matrix_functions.tst` passed zero, diagonal, inverse-pair,
commuting, nonnormal, negative-spectrum square-root, and
`expm(logm(A))` cases at 256 bits.  The high-precision wall also passed
1024-bit `2^-700` and 2048-bit `2^-1500` canaries with precision metadata
preserved.

## Required real regression wall

`test/run_tests.m` passed M00–M23, C00–C12 including C11L, N00–N08, S00–S08,
and T00–T02.

## Scope

General `funm` is explicitly deferred by the T-series goal and is not part of
T02.
