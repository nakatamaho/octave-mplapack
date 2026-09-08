# T03 report — polynomial core

## Result

`T03 PASS — POLYNOMIAL CORE CLOSED`

T03 adds arbitrary-precision polynomial methods for `polyval`, `polyvalm`,
`roots`, `poly`, `conv`, `deconv`, `polyder`, `polyint`, and `compan`.

## Controller metadata

| Field | Value |
|---|---|
| Repository | `octave-mplapack` |
| Branch | `topic/t00-t14-continuation` |
| Starting commit | `be8733167bfc7d78c28c60bd2af213b02769417a` |
| Implementation commit / tip | `f5bcf792c07f8e1171546937cdf022c89c04c88a` |
| D03 baseline | `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31`, tag `v0.4.0` |
| Dependencies | gmpfrxx_mkII `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1`; MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` |
| Octave | GNU Octave 11.1.0 |
| API scope | Polynomial evaluation, roots/characteristic polynomial, calculus, convolution, companion |
| Backend / algorithm | MPFR/MPC Horner, convolution/division, companion eigensolver, and native coefficient arithmetic |
| Precision policy | Coefficients, pivots, residuals, and stopping decisions stay at operation precision |
| Real/complex behavior | Real-only inputs use real paths; complex coefficients use MPC; no binary64 fallback |
| Octave differential QA | Vector/matrix forms, conjugate roots, coefficient layouts, and derivative/integral forms |
| 1024/2048 QA | High-precision polynomial canaries PASS in the controller wall |
| Sanitizers | Native ASan, UBSan, and LSan walls PASS in final controller run |
| Previous regression | T00–T02 and D03 M00–M23/C00–C12/S00–S08 walls passed |
| Status / TODO | PASS; `polyfit`/`polyeig`: `docs/todo/T03-polyfit-polyeig.md` |

## Contract and compatibility

* `polyval` uses element-wise Horner evaluation for scalar, vector, and matrix
  points; `polyvalm` uses matrix Horner evaluation for a square matrix.
* `roots` uses the arbitrary-precision companion matrix and existing MPFR/MPC
  eigensolver.  `poly` preserves Octave's vector-as-roots and square-matrix
  characteristic-polynomial semantics.
* Convolution, long division, differentiation, integration, and companion
  construction retain `mp` precision and complex values throughout.
* `polyder` supports the one-input derivative, one-output product derivative,
  and two-output quotient derivative forms documented by Octave.

## Focused evidence

The focused wall passed real and complex conjugate-root fixtures, Wilkinson-
style roots, polynomial evaluation and matrix evaluation, convolution and
division reconstruction, all audited `polyder` forms, integration, and
companion reconstruction.  It also passed below-binary64 root separation at
1024 bits with a `2^-700` spacing and a 2048-bit `2^-1500` fixture.

## Required real regression wall

`test/run_tests.m` passed M00–M23, C00–C12 including C11L, N00–N08, S00–S08,
and T00–T03.

## Explicit defer

`polyfit` and `polyeig` remain outside the T03 core and are recorded as
follow-up scope if later requirements need them.
