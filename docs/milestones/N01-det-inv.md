# Goal

Implement dense arbitrary-precision real and complex `det` and `inv`.

# Scope

Add public `@mp/det` and `@mp/inv` methods, native MPFR/MPC backend paths,
Rgetrf/Cgetrf pivot handling, Rgetri/Cgetri workspace-query handling,
precision-aware tests, documentation, and regression integration.

# Non-goals

Do not implement `det` reciprocal-condition output, SVD, rank, condition
numbers, eigenvalue APIs, binary distribution, Debian packaging, PPA work,
or final 0.3.0 release tagging.

# Design constraints

Use stored operand precision and operation-owned destructive copies. Keep
real and complex kernels separate. Never use builtin binary64 arithmetic as a
fallback. Preserve the historical 0.2.1 tag and release archive.

# Implementation tasks

- Add precision-scoped Rgetrf/Rgetri and Cgetrf/Cgetri determinant/inverse paths.
- Check workspace queries and all LAPACK INFO values.
- Add public wrappers, native tests, Octave tests, and release-wall checks.
- Document supported behavior and the N03 second-output deferral.

# Required tests

Test pivot parity, exact singular determinant zero, inverse values, empty and
nonsquare shapes, real and complex inputs, immutability, ambient precision,
1024-bit/`2^-700`, 2048-bit/`2^-1500`, workspace queries, sanitizer behavior,
and the complete M00-M23/C00-C12/C11L regression wall.

# Gate

```text
G-N01-DET
G-N01-DET-PIVOT
G-N01-INV
G-N01-WORKSPACE
G-N01-SINGULAR
G-N01-PRECISION
G-N01-IMMUTABILITY
G-N01-REAL-COMPLEX
G-N01-REGRESSION
```

# Expected commit

One implementation/report/status commit on
`topic/d01r1-mplapack-interop`, pushed after all N01 gates pass.
