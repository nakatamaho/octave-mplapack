# C10 — Pivoted Complex QR via `Cgeqp3`

## Mission

Extend dense complex `mp` QR to the pivoted three-output forms while keeping
the existing real `Rgeqp3` implementation for real values:

```text
[Q,R,P] = qr(A)
[Q,R,P] = qr(A,"econ")
[Q,R,p] = qr(A,"vector")
[Q,R,P] = qr(A,"matrix")
[Q,R,p] = qr(A,0)
```

The complex factorization satisfies `Q*R = A*P` for matrix permutations and
`Q*R = A(:,p)` for vector permutations. `P` and `p` remain builtin real
structural outputs.

## Backend and implementation

The installed MPFR declaration of `Cgeqp3` uses `mpc_class` A, reflector, and
complex workspace arrays, an installed `mplapackint*` `JPVT`, and MPFR real
workspace. The binding initializes `JPVT` to zero, performs the workspace
query and actual call inside `MpfrMpcPrecisionScope(p_op)`, validates the
returned permutation, and forms Q through the existing `Cungqr` path. R is
extracted from the operation-owned factorization storage with exact strict
lower zeros.

The bridge maps `JPVT` as source-column-to-destination-column matrix P, or as
the one-based vector p, matching the real API. Complex inputs dispatch only to
the MPC path; real inputs continue to use `Rgeqp3`/`Rorgqr`.

## Precision and ownership

`p_op` is the stored input precision. A, tau, complex work, real work, Q, and
R are all allocated at `p_op`; contract checks verify the active MPFR/MPC
scope, default precision, storage precision, and uniform element precision at
each LAPACK boundary. Destructive LAPACK calls receive operation-owned copies,
and ambient precision is restored after return.

## Gates

`G-C10-UPSTREAM`, `G-C10-PERMUTATION`, `G-C10-MATRIX-P`,
`G-C10-VECTOR-P`, `G-C10-ECON`, `G-C10-PIVOT-PRECISION`,
`G-C10-RECONSTRUCTION`, `G-C10-ORTHOGONALITY`, and
`G-C10-REAL-RGEQP3-PARITY`: PASS.

## Required QA

Native ASan/UBSan/LSan coverage checks full, economy, and wide shapes,
matrix/vector permutation mapping, exact JPVT validation, reconstruction,
unitarity, operation-owned input safety, empty shapes, ambient precision,
and 1024/2048-bit pivot-order canaries. Public tests cover all required
`qr` forms, complex structural outputs, real parity, lifetime, and the same
precision canary. The full native real wall and complete public M01–M23 plus
C01–C10 wall pass.

## Result

C10 PASS. Proceed to C11: mixed real/complex API closure.
