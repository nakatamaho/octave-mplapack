# Dense real `mp` pivoted QR

M19 adds dense real column-pivoted QR through the installed MPLAPACK MPFR
`Rgeqp3` and `Rorgqr` routines. The existing one- and two-output M18 forms
remain non-pivoted; a permutation output requests pivoting:

```octave
[Q, R, P] = qr (A);
[Q, R, P] = qr (A, "matrix");
[Q, R, p] = qr (A, "vector");
[Q, R, P] = qr (A, "econ");
[Q, R, p] = qr (A, 0);       % deprecated compatibility form
```

`Q` and `R` are immutable `mp` values. `P` is a builtin double permutation
matrix and `p` is a builtin double, one-based row vector. Their defining
relationships are:

```text
Q * R = A * P
Q * R = A(:,p)
```

For an `m`-by-`n` input, `P` is `n`-by-`n`. Full QR has `Q` `m`-by-`m` and
`R` `m`-by-`n`; economy QR uses `Q` `m`-by-`n` and `R` `n`-by-`n` when `m>n`,
and the same shapes as full QR when `m<=n`. The permutation is produced by
MPLAPACK's `Rgeqp3`; fixed-column JPVT control, `qr(A,B)`, sparse, complex,
N-D, and QR update operations are not implemented.

Pivoted operations use the stored precision of `A`, with all operation-owned
MPFR arrays and the `Rorgqr` call inside the corresponding precision scope.
The current `mpbits()` value does not affect an existing matrix or its pivot
selection. `Rgeqrf` remains the backend for non-pivoted one- and two-output
QR, and one-output `qr(A)` returns `R` without generating `Q`.
