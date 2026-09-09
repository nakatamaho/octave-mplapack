# C07 — Complex rank-revealing rectangular solve

## Mission

Provide complex rectangular `A \\ B` through an audited MPLAPACK rank-revealing
backend, with minimum-norm solutions, rank-deficient support, and precision
derived from the participating stored values.

## Backend candidate audit

The controlled MPLAPACK MPFR headers and reference sources were audited for
`Cgelsy`, `Cgelss`, and `Cgelsd`. `Cgelsy` uses QR with column pivoting, a
complex work array, and `2*n` real workspace; its `rcond` controls rank. The
SVD alternatives `Cgelss` and `Cgelsd` were directly exercised as audit
candidates. `Cgelsd` additionally requires real workspace and integer `iwork`
whose sizes are substantially larger; `Cgelss` uses the real workspace in its
singular-value path. The selected production backend is `Cgelsy` because its
rank-revealing QR path meets the required semantics with the smallest audited
workspace contract.

The tested declarations are from MPLAPACK commit
`a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` and use `mpc_class` complex arrays,
`mpfr_class` singular-value/rcond and real workspace, and installed
`mplapackint` pivot/work-index types.

## Semantics and implementation

- `p_op = max` of all participating stored precisions;
- `rcond = Rlamch_mpfr("E")` evaluated inside the `p_op` scope;
- A, B, complex workspace, real workspace, and all destructive work copies use
  exactly `p_op` precision;
- real and builtin complex operands are promoted without routing through
  binary64 complex arithmetic;
- A and B are copied before `Cgelsy`, which overwrites its arguments;
- full-column-rank, full-row-rank, rank-one, rank-zero, inconsistent
  rank-deficient, and multiple-RHS cases are supported;
- the returned solution has `n` rows and preserves the complex result type;
- real-only `A \\ B` dispatch remains on the established real rank-revealing
  path.

The inherited C06 public test was updated so a supported 2×1 complex system is
checked as a least-squares solve rather than as the former non-square error.

## Gates

`G-C07-CANDIDATE-AUDIT`, `G-C07-UPSTREAM`, `G-C07-FULL-RANK`,
`G-C07-RANK-DEF`, `G-C07-MIN-NORM`, `G-C07-RANK-PRECISION`,
`G-C07-WORKSPACE`, `G-C07-MIXED`, `G-C07-IMMUTABILITY`, and
`G-C07-REAL-RGELSS-PARITY`: PASS.

## Required QA

The native ASan/UBSan/LSan probe directly exercises all three candidates and
the selected `Cgelsy` wrapper. Public tests cover full-column-rank and
underdetermined minimum-norm systems, rank-deficient and zero-rank systems,
mixed real/complex and builtin operands, precision-sensitive rank, 1024-bit
`2^-700` and 2048-bit `2^-1500` real/imaginary tails, ambient precision,
operation-owned immutability, lifetime, and dimension diagnostics. The full
native real regression wall and complete public M01–M23 plus C01–C07 wall
pass.

## Result

C07 PASS. Proceed to C08: complex Cholesky.
