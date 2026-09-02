# Dense real `mp` QR factorization

M18 adds non-pivoted dense real QR through the installed MPLAPACK MPFR
`Rgeqrf` and `Rorgqr` routines. M19 adds three-output column-pivoted QR
through `Rgeqp3` and `Rorgqr` (see `pivoted-qr.md`):

```octave
R = qr (A);
[Q, R] = qr (A);
R = qr (A, "econ");
[Q, R] = qr (A, "econ");
```

The single-output form returns `R`.  Full QR has `Q` of size `m x m` and `R`
of size `m x n`; economy QR uses `Q` of size `m x n` and `R` of size `n x n`
when `m > n`, and has the same shapes as full QR when `m <= n`.  The numeric
`0` option is accepted as a deprecated economy alias; prefer `"econ"`.

`Rgeqrf` computes an operation-owned Householder representation and `Rorgqr`
generates `Q` only for two-output calls.  Public values are immutable and the
input matrix is never overwritten.  Every result uses the stored precision of
`A`; the current `mpbits()` setting and ambient MPFR default do not affect the
operation precision.

M18 supports dense real scalar and two-dimensional matrix values only.  Pivoted
three-output QR is provided by M19. `qr(A,B)`, sparse, complex, N-D, and QR
update operations remain deferred.
