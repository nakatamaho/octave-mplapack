# Arbitrary-precision `norm`

N00 adds dense real and complex `mp` norm support to the 0.3.0 development
line. Every result is an `mp` scalar at the stored operand precision; the
ambient `mpbits` default does not change an existing operand or result
precision.

## Vectors

The following forms are supported for real and complex vectors, including
`1x1` values:

```octave
norm (x)
norm (x, 1)
norm (x, 2)
norm (x, Inf)
norm (x, -Inf)
norm (x, "fro")
norm (x, 0)
norm (x, p)       % positive finite p
```

The default and Frobenius vector forms use the MPLAPACK MPFR/MPC native
2-norm kernels. One-norm and infinity forms use arbitrary-precision absolute
values. Finite positive `p` values are evaluated directly with MPFR powers;
zero counts nonzero absolute values and `-Inf` selects the minimum absolute
value.

## Dense matrices

Real and complex two-dimensional dense matrices support:

```octave
norm (A)
norm (A, 1)
norm (A, 2)
norm (A, Inf)
norm (A, "fro")
```

The standard matrix forms use MPLAPACK `Rlange`/`Clange`. The matrix 2-norm
uses an operation-owned copy and an MPLAPACK `Rgesvd`/`Cgesvd` singular-values-
only path. The Frobenius form is the native `Rlange`/`Clange` result.

Matrix `p=0`, negative finite `p`, and other induced matrix p norms are not
implemented in N00 and fail with a package-owned error. Row/column options,
sparse values, and N-dimensional values remain outside the current dense
2-D API.

Empty dense matrices return zero for the supported forms. MPFR/MPC NaN and
infinity values remain NaN/infinity; no builtin binary64 numerical fallback is
used. Inputs are copied before destructive SVD calls and remain unchanged.

The public method is `inst/@mp/norm.m`; native implementation and the
singular-values-only helper are in `src/mp_norm.cc` and `src/mp_norm.h`. The
helper is intentionally private to the package backend and is designed for
reuse by N02 SVD.
