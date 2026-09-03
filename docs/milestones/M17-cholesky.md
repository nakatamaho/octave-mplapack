# M17 — Dense real `mp` Cholesky factorization

# Goal

Add dense real `chol` and `chol(A, "upper"|"lower")` through the installed
MPLAPACK MPFR `Rpotrf` routine, with Octave-compatible status output and
precision-preserving immutable values.

# Scope

Scalar and square dense matrices are supported, including one- and two-output
forms, selected-triangle semantics, empty `0x0` values, and operation-owned
factor storage at the source precision.

# Non-goals

- Sparse, complex, or N-D Cholesky
- The dense three-output permutation form
- `cholupdate`, `cholinsert`, `choldelete`, `cholshift`, `cholinv`, or `chol2inv`
- SPD-specialized `mldivide`, determinant, inverse, rank, or condition APIs

# Design constraints

`Rpotrf` is destructive, so the public matrix is copied into a uniformly
source-precision operation-owned buffer.  The selected `UPLO` triangle is
passed directly without a symmetry pre-check or arithmetic pre-symmetrization.
The call runs under `MplapackMpfrPrecisionScope(precision(A))`; all public
values remain immutable and all strict unused-triangle output entries are
deterministic `+0` on success.

# Implementation tasks

- Audit the installed `Rpotrf` signature, source call chain, threading, and
  runtime linkage.
- Add the native factorization bridge and public `chol` dispatch, including
  one-/two-output and partial-factor status behavior.
- Add precision, selected-triangle, immutability, interoperability, sanitizer,
  and installed-package QA.
- Keep scalar/square/rectangular solve dispatch unchanged.

# Required tests

Run the controlled external `Rpotrf` probe, exact upper/lower fixtures,
non-square and invalid-option errors, one-/two-output non-PD behavior,
0x0/scalar cases, ignored-triangle special values, 1024/2048-bit precision
canaries, ambient-default independence, reconstruction through `Rgemm`, the
complete M00–M16 regression suite, and installed-package QA.

# Gate

`G17-UPSTREAM`, `G17-PRECISION`, `G17-TRIANGLE`, `G17-PD`, `G17-PUBLIC`,
`G17-PARTIAL`, `G17-IMMUTABILITY`, `G17-RECONSTRUCT`, `G17-INTEROP`, and
`G17-ROBUSTNESS` all pass for M17.

# Expected commit

`M17: add dense mp Cholesky factorization via MPLAPACK Rpotrf`
