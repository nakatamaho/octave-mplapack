# M16 — Rank-deficient rectangular `mp` solve

# Goal

Extend rectangular dense real `A \ B` to rank-deficient minimum-norm
least-squares solutions through a validated rank-revealing MPLAPACK MPFR
driver.

# Scope

Scalar and square dispatch remain unchanged.  Every non-square 2-D dense real
matrix uses `Rgelss` and supports overdetermined and underdetermined systems,
multiple right-hand sides, mixed `mp`/double operands, precision-sensitive
rank, and operation-owned LAPACK buffers.

# Non-goals

- Changing square `Rgesv` singular behavior
- Public `rank`, singular-value, condition, or tolerance APIs
- Normal equations, pseudoinverse, custom rank estimation, or home-grown QR/SVD
- Complex, sparse, N-D, or other MPLAPACK backends

# Design constraints

The candidate audit selected `Rgelss`: the pinned `Rgelsy` implementation
misclassified an exact rank-one 512-bit fixture, while `Rgelss` and `Rgelsd`
passed.  `Rgelss` receives uniformly `p_op`-precision operation-owned `A`,
padded `B`, `RCOND`, singular values, and `WORK` under
`MplapackMpfrPrecisionScope`.  `RCOND` is `Rlamch_mpfr("E")` at `p_op`.
Public inputs and all driver state remain immutable/private.

# Implementation tasks

- Audit installed `Rgelsy`, `Rgelss`, and `Rgelsd` signatures, source call
  chains, workspace, rank semantics, and threading.
- Add checked `Rgelss` query/solve integration while retaining the M15 `Rgels`
  bridge for regression/reference tests.
- Route only non-square public `mldivide` through `Rgelss`; preserve scalar and
  square `Rgesv` dispatch.
- Add precision, rank, minimum-norm, mixed-input, lifecycle, sanitizer, and
  installed-package QA.

# Required tests

Run the controlled installed-driver comparison probe, exact rank-zero and
rank-one minimum-norm fixtures, full-rank M15 parity, multiple RHS, the
precision-dependent rank canary at 512/1024 bits, 1024/2048-bit tails, high
ambient defaults, workspace checks, binary64 semantics, empty cases, and the
complete M00–M15 regression suite.

# Gate

`G16-DRIVER-AUDIT`, `G16-UPSTREAM`, `G16-RANK`, `G16-MINNORM`,
`G16-PRECISION`, `G16-WORKSPACE`, `G16-M15-PARITY`, `G16-PUBLIC`,
`G16-IMMUTABILITY`, `G16-BINARY64`, `G16-INTEROP`, and `G16-ROBUSTNESS` all
pass for M16.

# Expected commit

`M16: add rank-deficient rectangular mp least-squares solve`
