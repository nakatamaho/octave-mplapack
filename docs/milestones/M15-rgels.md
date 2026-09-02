# M15 — Full-rank rectangular `mp` solve

# Goal

Add dense real rectangular `A \ B` through MPLAPACK MPFR `Rgels` while
preserving the M08/M09 uniform-precision and immutable-value contracts.

# Scope

Full-column-rank overdetermined and full-row-rank underdetermined 2-D dense
systems, including multiple right-hand sides and mixed `mp`/double operands.

# Non-goals

- Rank-deficient or rank-revealing least-squares solving
- Normal equations, pseudoinverses, SVD, or condition estimation
- Complex, sparse, or N-D systems
- Reusable QR/LQ factorization objects

# Design constraints

Square systems remain on M09 `Rgesv`; scalar left division remains native
MPFR arithmetic. Rectangular `Rgels` calls use operation-owned uniformly
`p_op`-precision `A_work`, padded `B_work`, and `WORK` buffers under a
temporary `MplapackMpfrPrecisionScope`. Public operands are immutable and no
MPLAPACK mixed-precision call is possible.

# Implementation tasks

- Audit the installed `Rgels` signature, call chains, workspace query, and
  threading behavior.
- Add a checked native `Rgels` bridge and rectangular `mldivide` dispatch.
- Add QR/LQ, mixed-precision, workspace, empty-shape, and lifecycle QA.
- Document full-rank semantics and the deferred rank-revealing milestone.

# Required tests

Run installed-library QR/LQ precision canaries at 1024 and 2048 bits, public
single- and multiple-RHS rectangular solves, mixed `mp`/double conversion,
workspace-query validation, square/scalar parity, rank/error mapping, empty
cases, and the complete M00–M14 regression suite.

# Gate

`G15-UPSTREAM`, `G15-QR`, `G15-LQ`, `G15-WORKSPACE`, `G15-PRECISION`,
`G15-PUBLIC`, `G15-LIMITS`, `G15-IMMUTABILITY`, `G15-INTEROP`, and
`G15-ROBUSTNESS` must all pass for M15.

# Expected commit

`M15: add full-rank rectangular mp solve via MPLAPACK Rgels`
