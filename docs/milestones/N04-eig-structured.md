# Goal

Implement the structured standard eigenproblem for dense real symmetric and
complex Hermitian `mp` matrices.

# Scope

Provide `eig(A)`, `[V,D]=eig(A)`, the explicit `"matrix"` form, and the
explicit `"vector"` form. Use MPLAPACK `Rsyevd` for real input and `Cheevd`
for complex input.

# Non-goals

General nonsymmetric eig, generalized eig(A,B), balancing, sparse eig, and
binary64 fallback remain deferred to later milestones.

# Design constraints

Symmetry/Hermiticity is checked by exact represented MPFR/MPC values. Every
destructive LAPACK invocation receives an operation-owned copy inside the
one-operation precision scope. Eigenvalues remain real `mp` values.

# Implementation tasks

Add the structured eigenvalue backend, native and public tests, dispatch,
documentation, archive manifests, and regression gates.

# Required tests

Test exact detection, real symmetric and complex Hermitian residuals,
orthogonality, matrix/vector output forms, repeated and nearly repeated
eigenvalues, input immutability, ambient precision, and 1024/2048-bit
high-dynamic-range canaries. Run the complete real and complex regression
walls plus all sanitizer gates.

# Gate

```text
G-N04-DETECTION
G-N04-REAL-SYMMETRIC
G-N04-COMPLEX-HERMITIAN
G-N04-VECTOR
G-N04-MATRIX
G-N04-RESIDUAL
G-N04-ORTHOGONALITY
G-N04-DEGENERATE
G-N04-PRECISION
G-N04-REGRESSION
```

# Expected commit

The implementation, report, status, and gate updates are committed and
pushed only after the complete N04 wall passes.
