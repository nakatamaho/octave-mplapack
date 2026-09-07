# Goal

Complete dense standard `eig` for general real and complex `mp` matrices and
retain the structured symmetric/Hermitian dispatch from N04.

# Scope

Use MPLAPACK `Rgeevx` for general real input and `Cgeevx` for general complex
input. Provide eigenvalue-only, matrix, vector, balance, nobalance, and
three-output right/diagonal/left eigenvector forms. Keep generalized eig
deferred to N06.

# Non-goals

Generalized eigenproblems, sparse or N-dimensional eig, binary64 fallback,
new public arithmetic, and optimized complex worker support are outside N05.

# Design constraints

The input is never modified: every destructive `Rgeevx`/`Cgeevx` call receives
an operation-owned copy. Each call establishes one MPFR or MPFR/MPC scope at
the stored input precision, checks workspace queries and `INFO`, and returns
uniform operation-owned `mp` storage. Real general eigenpairs are explicitly
converted from LAPACK's conjugate-pair representation to complex `mp` columns;
no builtin binary64 complex kernel is permitted.

# Implementation tasks

Add native real/complex general eig backends, exact structured-shape dispatch,
public output and balance forms, permanent Grcar coverage, native/public
precision and immutability tests, compatibility-firewall updates, release
closure updates, and archive/sanitizer gates.

# Required tests

Cover real rotation and nonsymmetric matrices, complex non-Hermitian matrices,
right and left residuals, matrix/vector/three-output forms, balance and
nobalance, Grcar matrices, nearly repeated and nearly defective cases, badly
scaled cases, input immutability, ambient precision, 1024-bit `2^-700`,
2048-bit `2^-1500`, generalized-eig rejection, native sanitizers, and the
complete real/complex regression walls including C11L.

# Gate

```text
G-N05-BACKEND
G-N05-REAL-GENERAL
G-N05-COMPLEX-GENERAL
G-N05-BALANCE
G-N05-NOBALANCE
G-N05-RIGHT-EIGENVECTORS
G-N05-LEFT-EIGENVECTORS
G-N05-GRCAR
G-N05-NEAR-DEFECTIVE
G-N05-PRECISION
G-N05-REGRESSION
```

# Expected commit

The implementation, tests, documentation, report, status, and regression
gates are committed and pushed only after the complete N05 wall passes.
