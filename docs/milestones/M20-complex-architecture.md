# Goal

Audit and freeze the architecture for a future complex MPFR/MPLAPACK backend
without adding public complex `mp` values.  M20 is a design-only milestone;
the accepted M00--M19 real implementation remains the production surface.

# Scope

- Inspect the pinned MPLAPACK MPFR complex scalar and routine interfaces.
- Probe installed complex GEMM, solve, Cholesky, and QR entry points.
- Define storage, precision, promotion, dispatch, and packaging decisions for
  a later complex implementation series.
- Record open backend, ABI, threading, and packaging issues.

# Non-goals

- No public complex constructors, operators, matrices, or indexing.
- No changes to real MPLAPACK calls or real public semantics.
- No MPLAPACK source changes and no PPA build or publication.
- No complex SVD, rank, solve, factorization, or display implementation.

# Design constraints

- Keep one public `mp` class with separate real and complex payload kinds.
- Use the installed MPLAPACK MPFR complex scalar directly where its ABI is
  safe, with one explicit precision for both components of each object.
- Preserve immutable public values and operation-owned destructive buffers.
- Keep real storage and real backend calls unchanged; complex support must not
  route existing real operations through complex kernels.
- Discover dependencies through `pkg-config`; do not hard-code install paths.
- Any future numerical call will normalize every REAL and COMPLEX participant
  to one operation precision and establish that precision in every worker.

# Implementation tasks

- Add the test-only installed complex backend probe.
- Audit headers, pinned source call chains, TLS/MPC state, and runtime linkage.
- Add `docs/complex-architecture.md`, update the architecture/packaging and
  milestone indexes, and record the real-only release decision.
- Run the M00--M19 regression and repository checks.

# Required tests

- Compile and run the installed complex probe at 1024 and 2048 bits, including
  GEMM tails, Cgesv, Cpotrf, Cgeqrf/Cungqr, component precision, and TLS scope
  restoration.
- Verify independent worker-thread default precision.
- Verify `ldd -r` resolves the controlled MPLAPACK MPFR dependency and that no
  optimized MPLAPACK DSO is accidentally linked.
- Run `tools/check-tree.sh`, `tools/check-format.sh`, and the full local CI
  M00--M19 real regression.

# Gate

M20 passes only when G20-TYPE, G20-PRECISION, G20-PUBLIC, G20-BACKEND,
G20-PACKAGING, G20-REAL-REGRESSION, and G20-RELEASE all pass.  The expected
release conclusion is `M20 PASS — REAL-PPA-GO`; public complex support remains
future work.

# Expected commit

`M20: freeze complex architecture design`
