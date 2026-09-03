# C03 — Complex structural operations

## Mission

Implement the first complex structural and component operations while retaining
the accepted real M12 behavior.

## Semantics

- `real(Z)` and `imag(Z)` return real `mp` values with the source shape and
  precision;
- `conj(Z)` returns a complex value with the source shape and precision;
- `Z.'` transposes without conjugation;
- `Z'` transposes and conjugates;
- conjugation flips the sign of an imaginary signed zero.

All complex operations copy native MPFR/MPC values under an operation-local
precision scope. Real values continue through their existing real-only paths.

## Gate

`G-C03-REAL`, `G-C03-IMAG`, `G-C03-CONJ`, `G-C03-TRANSPOSE`,
`G-C03-CTRANSPOSE`, `G-C03-SIGNED-ZERO`, and `G-C03-REAL-PARITY`.

## Required QA

Native sanitizer coverage and public tests cover 128/512/1024/2048-bit
precision, shape and value invariants, signed zero, and the complete M01-M23
real wall.

## Expected commit

`C03: add complex real-imag-conjugate and transpose semantics`
