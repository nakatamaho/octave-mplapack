# Structured eigenvalues

The 0.3.0 development line supports the dense standard eigenproblem for
exactly represented real symmetric and complex Hermitian `mp` matrices.

```octave
lambda = eig (A)
[V, D] = eig (A)
[V, D] = eig (A, "matrix")
[V, d] = eig (A, "vector")
```

Real symmetric input is evaluated by MPLAPACK MPFR `Rsyevd`; complex Hermitian
input is evaluated by MPC/MPFR `Cheevd`. Both routines receive operation-owned
copies. The operation enters one precision scope matching the stored input
precision, so MPFR/MPC temporaries and outputs remain uniform at that
precision. The input is never modified.

Eigenvalues are returned as a real `mp` column vector. With two outputs, `D`
is a real `mp` diagonal matrix and `d` is the same real `mp` column vector in
the explicit vector form. Real symmetric eigenvectors are real `mp`; complex
Hermitian eigenvectors are complex `mp`. The expected identities are
`A*V = V*D` and `V'*V = I` (using transpose rather than ctranspose for real
input).

Detection is an exact represented-value check: every real off-diagonal pair
must compare exactly, while a complex Hermitian pair must have equal real
parts and exactly opposite imaginary parts, with zero imaginary diagonal.
This avoids routing a nearly symmetric general matrix through the structured
driver. General and generalized eigenvalue problems are deferred to N05 and
N06 respectively and are rejected with package-owned errors.

Eigenvectors for repeated eigenvalues are not compared element by element;
their invariant-subspace residuals and orthogonality are the stable contract.
