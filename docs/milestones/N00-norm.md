# N00 — arbitrary-precision `norm`

N00 completes the first reduction in the dense real+complex numerical API.
It adds a public `@mp/norm` method while retaining the accepted MPFR/MPC
one-operation/one-precision contract.

## Gate result

```text
G-N00-API: PASS
G-N00-REAL: PASS
G-N00-COMPLEX: PASS
G-N00-MATRIX: PASS
G-N00-VECTOR: PASS
G-N00-2NORM: PASS
G-N00-PRECISION: PASS
G-N00-SPECIAL: PASS
G-N00-REGRESSION: PASS
```

Native tests cover real and complex vectors/matrices, standard norms,
finite-vector p values, empty shapes, NaN/infinity, operation-owned SVD
copies, 1024-bit/`2^-700` and 2048-bit/`2^-1500` values, and ambient precision
independence. Public tests cover the same forms plus rejected matrix options
and package-owned errors. Full real and C00-C12/C11L regression is rerun after
the milestone.

## Backend

`Rlange`/`Clange` provide standard matrix norms, `Rnrm2`/`RCnrm2` provide
native vector 2-norms, and `Rgesvd`/`Cgesvd` provide singular-values-only
matrix 2-norms. Complex absolute values use MPC/MPFR-native operations.

## Deferrals

Induced matrix norms other than 1, 2, infinity, and Frobenius, matrix zero or
negative finite p forms, row/column norm options, sparse inputs, and N-D
inputs remain deferred. N02 reuses the private singular-value helper for the
public SVD implementation.
