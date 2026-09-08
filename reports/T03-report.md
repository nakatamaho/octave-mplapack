# T03 report — polynomial core

## Result

`T03 PASS — POLYNOMIAL CORE CLOSED`

T03 adds arbitrary-precision polynomial methods for `polyval`, `polyvalm`,
`roots`, `poly`, `conv`, `deconv`, `polyder`, `polyint`, and `compan`.

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
