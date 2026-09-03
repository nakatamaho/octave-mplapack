# C05 — Complex matrix multiplication via `Cgemm`

## Mission

Add dense complex matrix multiplication while retaining the real-only
`Rgemm` path for real operands.

## Dispatch and precision

- real × real remains the existing MPFR `Rgemm` implementation;
- real × complex, complex × real, and complex × complex use MPLAPACK `Cgemm`;
- scalar scaling uses native MPC arithmetic within the same complex boundary;
- every participating `mp` operand is promoted to
  `p_op = max(precisions)`, while builtin real/complex doubles are converted
  directly from their binary64 components;
- all MPC matrix elements, `alpha`, `beta`, result storage, and the active
  MPFR/MPC context at the Cgemm call use `p_op`.

The destructive Cgemm output is operation-owned. Inputs are copied into
uniform-precision temporaries before the call, so public `mp` values retain
value semantics.

## Backend audit

The controlled MPLAPACK build exposes the installed MPFR declaration:

```cpp
void Cgemm(const char *, const char *, mplapackint, mplapackint,
           mplapackint, mpc_class, mpc_class *, mplapackint,
           mpc_class *, mplapackint, mpc_class, mpc_class *, mplapackint);
```

The tested source is `mpblas/reference/Cgemm.cpp` at MPLAPACK commit
`a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`. The controlled build disables
optimized workers (`MPLAPACK_ENABLE_OPT=OFF`), and the reference implementation
executes on the calling thread. The project scope therefore establishes the
MPFR/MPC precision contract immediately around the invocation.

## Gates

`G-C05-UPSTREAM`, `G-C05-DISPATCH`, `G-C05-CGEMM`, `G-C05-PRECISION`,
`G-C05-MIXED`, `G-C05-SHAPES`, `G-C05-IMMUTABILITY`, and
`G-C05-REAL-RGEMM-PARITY` all pass when the native and public C05 suites and
the complete real regression wall pass.

## Required QA

Native ASan/UBSan/LSan coverage and public tests cover complex products,
mixed real/complex operands, builtin complex matrices, scalar scaling,
dimension errors, empty shapes, lifetime/immutability, ambient precision, and
the 1024-bit `2^-700` and 2048-bit `2^-1500` real and imaginary tails.
