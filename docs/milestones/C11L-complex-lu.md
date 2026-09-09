# C11L — Mandatory Complex LU via `Cgetrf`

## Mission

Implement the required complex LU milestone through MPLAPACK MPFR `Cgetrf`,
with the same public semantics as real M21 and no incidental use of complex
arithmetic for real-only inputs.

## Dependency audit

The controlled MPLAPACK installation exposes:

```text
void Cgetrf(mplapackint const m, mplapackint const n, mpc_class *a,
            mplapackint const lda, mplapackint *ipiv, mplapackint &info)
```

The declaration is in `mplapack_mpfr.h`; the tested reference implementation
is `mplapack/reference/Cgetrf.cpp` at MPLAPACK commit
`a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`. No new upstream fix was required
by C11L. The MPFR precision-scope-header fix from the MPLAPACK development
branch remains required.

## Semantics

- one output returns the operation-owned packed `Cgetrf` factor;
- two outputs return `L,U` with `A=L*U` after absorbing row swaps into `L`;
- three outputs return builtin real `P` with `P*A=L*U`;
- `"vector"` returns the builtin real column vector `p` with
  `A(p,:)=L*U`;
- tall and wide matrices use `m×min(m,n)` and `min(m,n)×n` factors;
- singular matrices return partial factors through the native gate and retain
  `INFO` without mutating the public input;
- pivots are selected from the stored source precision, independent of the
  ambient default precision;
- empty inputs normalize to the same empty `0×0` public factors as real M21.

The implementation copies the public MPC matrix at `p_op`, enters one
`MpfrMpcPrecisionScope`, validates the MPFR/MPC precision contract at the
`Cgetrf` boundary, uses `mplapackint` pivots, and never routes the complex
operation through builtin binary64 complex arithmetic.

## Gates

`G-C11L-UPSTREAM`, `G-C11L-PACKED`, `G-C11L-TWO-OUTPUT`,
`G-C11L-MATRIX-P`, `G-C11L-VECTOR-P`, `G-C11L-RECTANGULAR`,
`G-C11L-SINGULAR`, `G-C11L-PIVOT-PRECISION`, `G-C11L-PRECISION`,
`G-C11L-IMMUTABILITY`, `G-C11L-LIFETIME`, and
`G-C11L-REAL-RGETRF-PARITY`: PASS.

## QA

- native complex `Cgetrf` gate under ASan/UBSan/LSan: PASS;
- square packed factors, canonical two-output factors, matrix/vector
  permutations, tall/wide shapes, singular partial factors, and empty
  shapes: PASS;
- 1024-bit/`2^-700` and 2048-bit/`2^-1500` tails: PASS;
- 512-bit versus 1024-bit precision-dependent pivot order: PASS;
- ambient precision restoration, public-input immutability, and output
  lifetime: PASS;
- complete native real+complex sanitizer wall: PASS;
- complete public M01–M23 plus C01–C11L wall: PASS;
- real M21 `Rgetrf` regression and permutation conventions: PASS.

## Result

`C11L PASS`

Implementation commit: `3bad050af108a6ca8739c97b91120e3053800ecc`.
