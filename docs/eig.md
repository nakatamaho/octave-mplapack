# Dense eigenproblems

The 0.3.0 development line supports dense standard and generalized
eigenproblems for real and complex two-dimensional `mp` matrices.

```octave
lambda = eig (A)
[V, D] = eig (A)
[V, d] = eig (A, "vector")
[V, D, W] = eig (A)
[V, D] = eig (A, "balance")
[V, D] = eig (A, "nobalance")
[lambda] = eig (A, "vector")
[V, D] = eig (A, B)
[V, d] = eig (A, B, "vector")
[V, D, W] = eig (A, B)
[V, D] = eig (A, B, "chol")
[V, D] = eig (A, B, "qz")
```

Exactly represented real symmetric and complex Hermitian inputs use
MPLAPACK MPFR `Rsyevd` and MPC/MPFR `Cheevd`. General real inputs use
`Rgeevx`; general complex inputs use `Cgeevx`. Every destructive driver call
receives an operation-owned copy inside one scope matching the stored input
precision. No path converts a complex problem to builtin binary64 arithmetic.

Structured eigenvalues and diagonal matrices are real `mp` values. General
eigenvalues, right eigenvectors, left eigenvectors, and diagonal matrices are
complex `mp` values, including when the real general problem happens to have
only real eigenvalues. The standard identities are
`A*V = V*D` and `W'*A = D*W'`, where `'` is the complex-conjugate transpose.
For `[V,d]`, `d` is the complex eigenvalue column vector.

The optional `"balance"` and `"nobalance"` flags select the `Rgeevx`/`Cgeevx`
expert-driver path. `"matrix"` and `"vector"` select the matrix or column
eigenvalue layout; a one-output `eig(A,"matrix")` returns the diagonal
eigenvalue matrix, while the default one-output and `"vector"` forms return a
column. Three-output `"vector"` returns `[V,d,W]`. Structured
`Rsyevd`/`Cheevd` inputs have no balancing stage, so a balance flag has no
numerical effect on that path.

The structured/general choice is based on an exact represented-value check:
real off-diagonal pairs must compare exactly, while complex Hermitian pairs
must have equal real parts, opposite imaginary parts, and zero imaginary
diagonal entries. Nearly symmetric, non-Hermitian, Grcar, nearly defective,
and badly scaled matrices therefore exercise the general backend explicitly.
For `eig(A,B)`, `"chol"` selects the symmetric/Hermitian-definite
`Rsygvd`/`Chegvd` path and `"qz"` selects `Rggev`/`Cggev`; the default chooses
the definite path only for exactly symmetric/Hermitian pairs and falls back
to QZ when `B` is not positive definite. Generalized standard options such as
`"balance"` are rejected, and sparse eig, N-dimensional eig, and nonsymmetric
`"chol"` requests remain unsupported with package-owned diagnostics. The
generalized identities are `A*V = B*V*D` and
`W'*A = D*W'*B`.
