# Dense real LU factorization

M21 adds dense real arbitrary-precision LU factorization through the
installed MPLAPACK MPFR `Rgetrf` routine.  `Rgetrf` uses partial row pivoting;
it overwrites an operation-owned copy, so the public `mp` input is never
modified.

The supported forms are:

```octave
Y = lu (A)
[L, U] = lu (A)
[L, U, P] = lu (A)
[L, U, p] = lu (A, "vector")
```

`A` may be square, tall, or wide.  LU uses the stored precision of `A`; the
current `mpbits()` default is not consulted for an existing value.  Every
returned `mp` factor has the same precision as `A`, and the operation restores
the caller's current precision after success or failure.

The one-output form returns the packed LAPACK factorization with the same
shape as `A`: the upper trapezoid contains `U`, the strict lower trapezoid
contains the multipliers of unit-diagonal `L`, and the row permutation is not
encoded in the result.  The two-output form absorbs the row permutation into
the returned L-like factor, so its defining relation is:

```text
A = L * U
```

The two-output `L` therefore need not be triangular when pivoting occurs.
For the canonical three-output form:

```text
P * A = L * U
```

where `P` is a builtin double row-permutation matrix.  For the vector form,
`p` is a builtin double **column** vector of 1-based row indices and:

```text
A (p, :) = L * U
```

For `m x n` input and `k = min (m,n)`, canonical three-output factors have
shapes `L: m x k`, `U: k x n`, and `P: m x m`.  Singular matrices are still
factorized: a positive `Rgetrf` `INFO` is retained internally and does not
turn `lu` into a solve-style error.  A zero diagonal in `U` means the factors
do not define an inverse, not that factor extraction failed.

Only dense real values are supported.  Sparse/UMFPACK threshold and Q/R
outputs, complex LU, `luupdate`, `det`, `inv`, rank, condition estimation,
and triangular-solve optimizations are outside M21.
