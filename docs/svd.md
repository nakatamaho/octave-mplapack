# Singular value decomposition

The 0.3.0 development line provides dense arbitrary-precision real and
complex singular value decomposition through MPLAPACK `Rgesvd` and `Cgesvd`.

```octave
s = svd (A)
[U, S, V] = svd (A)
[U, S, V] = svd (A, "econ")
[U, S, V] = svd (A, 0)
```

The one-output result is a real `mp` column containing the `min (rows(A),
columns(A))` singular values in descending order. In the three-output form,
`S` is a real `mp` diagonal matrix and the factors satisfy
`A = U*S*V'`; for complex input the transpose is conjugating. The full form
returns `U` as `m x m`, `S` as `m x n`, and `V` as `n x n`. Economy mode
returns `U` as `m x k`, `S` as `k x k`, and `V` as `n x k`, where `k = min(m,n)`.
The numeric `0` option is accepted as the deprecated economy spelling.

Empty two-dimensional shapes follow the corresponding Octave full/economy
shape rules. A scalar is treated as a `1 x 1` dense input and preserves its
stored precision in all returned `mp` values.

## Precision and ownership

Each call uses the stored operand precision as its operation precision. The
destructive LAPACK input buffer, singular-value buffer, U/VT factors, and
workspace all have uniform MPFR or MPC precision under one operation-owned
precision scope. The complex path converts VT to V with native MPC conjugation.
Ambient `mpbits` changes do not alter existing values or SVD precision, and
the input remains unchanged after the query and execution calls.

No SVD path converts through binary64 or calls builtin Octave `svd`. Real
inputs stay on `Rgesvd`; complex inputs stay on `Cgesvd`.
