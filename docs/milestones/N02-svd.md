# Goal

Implement the dense real and complex arbitrary-precision `svd` API for the
0.3.0 development line.

# Scope

Support one-output singular values and three-output full/economy factors,
including the deprecated numeric `0` economy option, scalar values, empty
shapes, 1024/2048-bit precision, and native real/complex reconstruction and
orthogonality tests.

# Non-goals

Do not implement `rank`, `cond`, `rcond`, eigenvalue APIs, sparse SVD,
generalized SVD, binary64 fallback, or any new real-only algorithm outside the
SVD surface.

# Design constraints

Use MPLAPACK `Rgesvd` for real input and `Cgesvd` for complex input. Keep the
one-operation/one-precision MPFR/MPC contract, copy destructive operands into
operation-owned buffers, check workspace queries and INFO, return real `mp`
singular values for complex input, and preserve the real/complex backend
boundary.

# Implementation tasks

- Reuse the N00 singular-values-only helpers for one-output calls.
- Implement full and economy U/S/V output with Octave-compatible shapes.
- Convert LAPACK VT to public V using a native transpose or conjugate
  transpose as appropriate.
- Add public wrappers, native/public tests, compatibility updates, tree gates,
  archive checks, and the milestone report.

# Required tests

Run native sanitized SVD tests, public real/complex shape and reconstruction
tests, full/economy/0 forms, scalar and empty values, orthogonality/unitarity,
input immutability, ambient precision restoration, 1024-bit `2^-700`,
2048-bit `2^-1500`, the M00-M23 wall, C00-C12 including C11L, and the ASan,
UBSan, and LSan gates.

# Gate

```text
G-N02-BACKEND
G-N02-ONE-OUTPUT
G-N02-FULL
G-N02-ECON
G-N02-REAL
G-N02-COMPLEX
G-N02-RECONSTRUCTION
G-N02-ORTHOGONALITY
G-N02-WORKSPACE
G-N02-PRECISION
G-N02-REGRESSION
```

# Expected commit

Implement the native Rgesvd/Cgesvd backend and public `@mp/svd` API with a
complete N02 regression and report.
