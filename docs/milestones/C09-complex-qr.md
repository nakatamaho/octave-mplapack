# C09 — Non-pivoted complex QR via `Cgeqrf` / `Cungqr`

## Mission

Extend dense `mp` QR to complex input for full and economy forms, including
one-output R-only calls and the deprecated `qr(A,0)` economy spelling, while
leaving real QR on `Rgeqrf`/`Rorgqr`.

## Semantics

- one output returns R and does not construct Q;
- full tall QR returns Q `m×m` and R `m×n`;
- economy tall QR returns Q `m×n` and R `n×n`;
- wide matrices retain the full `m×m` Q and `m×n` R shapes;
- R's strict lower triangle is exact complex zero;
- complex orthogonality is `Q' * Q = I`, using conjugate transpose;
- `Q * R` reconstructs the input within the operation precision.

## Backend and precision

The installed MPFR declarations of `Cgeqrf` and `Cungqr` use `mpc_class`
factor, reflector, and workspace arrays with `mplapackint` dimensions. The
wrapper performs a workspace query and actual call for `Cgeqrf`, then queries
and calls `Cungqr` only when Q is requested. All destructive factor and
generator inputs are operation-owned copies. Every query/work array is
allocated at `p_op`, and the MPFR/MPC scope and post-call contract checks
ensure that active defaults and stored components agree.

## Gates

`G-C09-UPSTREAM`, `G-C09-FULL`, `G-C09-ECON`, `G-C09-ONE-OUTPUT`,
`G-C09-WORKSPACE`, `G-C09-ORTHOGONALITY`, `G-C09-RECONSTRUCTION`,
`G-C09-PRECISION`, and `G-C09-REAL-QR-PARITY`: PASS.

## Required QA

Native ASan/UBSan/LSan coverage checks full/economy/wide shapes, R-only
dispatch, workspace queries, exact R zeros, unitary Q, reconstruction,
operation-owned input safety, empty shapes, ambient precision restoration, and
1024-bit `2^-700` / 2048-bit `2^-1500` complex tails. Public tests cover the
same forms plus `qr(A,0)` and real QR regression parity. The full native real
wall and complete public M01–M23 plus C01–C09 wall pass.

## Result

C09 PASS. Proceed to C10: pivoted complex QR.
