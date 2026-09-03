# M18 — Dense real `mp` QR factorization

# Goal

Add non-pivoted dense real `qr` through MPLAPACK MPFR `Rgeqrf` and `Rorgqr`,
with Octave-compatible single/two-output and full/economy forms.

# Scope

Scalar and two-dimensional dense real `mp` values, full and economy QR,
deprecated numeric-zero economy compatibility, precision-preserving immutable
operation-owned buffers, and MPFR-native reconstruction/orthogonality QA.

# Non-goals

- Pivoted QR and third-output permutation semantics
- `qr(A,B)`, QR updates, rank, or condition APIs
- Sparse, complex, or N-D QR

# Design constraints

`Rgeqrf` overwrites its input, so the public matrix is copied into a uniformly
stored-precision operation-owned buffer.  `Rorgqr` is called only when `Q` is
requested.  Workspace queries and calls run inside
`MplapackMpfrPrecisionScope(precision(A))`, with all REAL storage at that
precision; no ambient default or binary64 conversion participates.

# Implementation tasks

- Audit installed signatures, source call chains, threading, and runtime
  linkage for `Rgeqrf` and `Rorgqr`.
- Add native QR factorization, R extraction, Q generation, checked workspace
  handling, and public `qr` dispatch.
- Add full/economy shape, precision, numerical invariant, immutability,
  interoperability, sanitizer, and installed-package QA.

# Required tests

Run the controlled external QR probe, native QR tests, full/economy tall and
wide fixtures, scalar/empty cases, one-output R semantics, 1024/2048-bit
precision canaries, ambient-default independence, and the complete M00–M17
regression suite.

# Gate

`G18-UPSTREAM`, `G18-FULL`, `G18-ECON`, `G18-PRECISION`, `G18-WORKSPACE`,
`G18-PUBLIC`, `G18-IMMUTABILITY`, `G18-NUMERICAL`, `G18-INTEROP`, and
`G18-ROBUSTNESS` must all pass.

# Expected commit

`M18: add dense mp QR factorization via MPLAPACK Rgeqrf/Rorgqr`
