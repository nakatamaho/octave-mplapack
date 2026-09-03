# M19 — Dense real `mp` pivoted QR

# Goal

Add Octave-compatible dense real column-pivoted QR through MPLAPACK MPFR
`Rgeqp3`, reusing M18 `Rorgqr` Q generation and returning either a permutation
matrix or a one-based permutation vector.

# Scope

Three-output full/economy pivoted QR, matrix/vector permutation forms,
deprecated numeric-zero economy/vector compatibility, precision-safe
operation-owned buffers, and MPFR-native reconstruction and orthogonality QA.

# Non-goals

- `qr(A,B)`, fixed-column JPVT control, QR updates, rank, or condition APIs
- Sparse, complex, or N-D QR

# Design constraints

`Rgeqp3` overwrites its input and returns integer JPVT state, so all numerical
storage is operation-owned. JPVT is initialized to zero, validated, and
converted to a 1-based Octave permutation before constructing `P`. Every REAL
array uses the stored input precision inside `MplapackMpfrPrecisionScope`.
M18's non-pivoted `Rgeqrf` path remains selected for one/two-output calls.

# Implementation tasks

- Audit the installed `Rgeqp3` signature, JPVT mapping, call chain, threading,
  workspace query, and runtime linkage.
- Add a native pivoted factorization bridge with shared R extraction and
  `Rorgqr` generation, plus public `qr` output dispatch.
- Add deterministic permutation, precision, immutability, interoperability,
  sanitizer, and installed-package QA.

# Required tests

Run the controlled external pivoted-QR probe, native Rgeqp3 tests, matrix and
vector permutation reconstruction, full/economy tall and wide fixtures,
precision-dependent pivot canaries, 1024/2048-bit tails, scalar/empty cases,
M18 parity, and the complete M00–M18 regression suite.

# Gate

`G19-UPSTREAM`, `G19-PERMUTATION`, `G19-PIVOT`, `G19-ECON`, `G19-PRECISION`,
`G19-WORKSPACE`, `G19-PUBLIC`, `G19-M18-PARITY`, `G19-IMMUTABILITY`,
`G19-INTEROP`, and `G19-ROBUSTNESS` must all pass.

# Expected commit

`M19: add dense mp pivoted QR via MPLAPACK Rgeqp3`
