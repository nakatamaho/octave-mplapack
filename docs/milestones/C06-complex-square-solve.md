# C06 — Complex square solve via `Cgesv`

## Mission

Extend dense square `A \ B` to complex participation while preserving the
real `Rgesv` path.

## Dispatch and precision

- real square `mp` systems continue to use `Rgesv`;
- any complex coefficient or right-hand side uses `Cgesv`;
- all participating `mp` values are normalized to
  `p_op = max(precisions)`;
- real values are converted to MPC with exact `+0i`, and builtin complex
  doubles are converted directly from binary64 components;
- A, B, and every destructive working copy have uniform `p_op` precision;
- the pivot array is `std::vector<mplapackint>`, using the installed
  MPLAPACK integer type;
- multiple right-hand sides are supported.

`Cgesv` overwrites both arguments, so the binding copies coefficient and RHS
matrices into operation-owned storage. Singular `info > 0` is mapped to the
established `mplapack:mp:SingularMatrix` error.

## Backend audit

The controlled MPLAPACK MPFR header declares `Cgesv` with `mpc_class` A/B
arrays and `mplapackint *ipiv`. The tested implementation is
`mplapack/reference/Cgesv.cpp` at commit
`a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`; it calls the reference `Cgetrf`
and `Cgetrs` routines. The controlled build disables optimized workers.

## Gates

`G-C06-UPSTREAM`, `G-C06-CGESV`, `G-C06-MIXED`, `G-C06-PIVOT`,
`G-C06-SINGULAR`, `G-C06-MULTIRHS`, `G-C06-PRECISION`,
`G-C06-IMMUTABILITY`, and `G-C06-REAL-RGESV-PARITY` all pass.

## Required QA

Native ASan/UBSan/LSan and public tests cover complex multiple-RHS solves,
mixed real/complex and builtin complex operands, pivot typing, singular and
non-square errors, ambient precision, operation lifetime/immutability, and
1024-bit `2^-700` / 2048-bit `2^-1500` real and imaginary tails.
