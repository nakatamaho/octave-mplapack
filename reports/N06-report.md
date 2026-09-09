# N06 report — generalized eig

## Result

N06 PASS — dense real/complex generalized `eig(A,B)` is implemented and
validated on `topic/d01r1-mplapack-interop`.

## Implementation

- Real definite backend: MPLAPACK `Rsygvd`.
- Complex definite backend: MPLAPACK `Chegvd`.
- Real QZ backend: MPLAPACK `Rggev`, including `alpha/beta` and conjugate-pair
  conversion.
- Complex QZ backend: MPLAPACK `Cggev`, including arbitrary-precision
  `alpha/beta` division and singular-`B` special values.
- Mixed real/complex operands are promoted once to MPC at the maximum stored
  precision. Standard real-only operations remain on their real paths.
- All destructive calls use owned copies and the existing MPFR/MPC scope
  composition; no builtin binary64 complex fallback is present.

## Public contract

`eig(A,B)` supports matrix and vector eigenvalue layouts, three-output right /
eigenvalue / left forms, `chol`, and `qz`. Exactly symmetric/Hermitian pairs
select the definite path by default; a non-positive-definite `B` falls back to
QZ. Generalized `balance` and `nobalance` options are rejected in accordance
with the audited Octave behavior. Singular `B` produces an infinite
eigenvalue when QZ reports `beta = 0`.

## QA

```text
native make -C src check-generalized-eig: PASS
public test/eig_generalized.tst: PASS
full test/run_tests.m (M00-M23, C00-C12 including C11L, N00-N06): PASS
real definite and QZ residuals: PASS
complex definite and QZ residuals: PASS
left generalized residuals: PASS
matrix/vector and three-output forms: PASS
mixed real/complex generalized pair: PASS
singular-B infinite eigenvalue: PASS
1024-bit and 2048-bit QZ canaries: PASS
ambient precision restoration: PASS
input immutability: PASS
native ASan/UBSan/LSan test: PASS
```

## Gates

```text
G-N06-API:                  PASS
G-N06-QZ:                   PASS
G-N06-CHOL:                PASS
G-N06-REAL:                PASS
G-N06-COMPLEX:             PASS
G-N06-INFINITE-EIGENVALUES: PASS
G-N06-RIGHT-EIGENVECTORS:  PASS
G-N06-LEFT-EIGENVECTORS:   PASS
G-N06-MATRIX-VECTOR:       PASS
G-N06-PRECISION:           PASS
G-N06-REGRESSION:          PASS
```

The final implementation commit and complete wall results are recorded in
`docs/goals/N00-N07-D02-status.md` after the full local CI run.
