# Generalized eigenproblems

N06 adds dense arbitrary-precision generalized eigenproblems:

```octave
lambda = eig (A, B)
[V, D] = eig (A, B)
[V, d] = eig (A, B, "vector")
[V, D, W] = eig (A, B)
[V, D] = eig (A, B, "chol")
[V, D] = eig (A, B, "qz")
```

The operation solves `A*V = B*V*D`. Three-output forms additionally return
left eigenvectors satisfying `W'*A = D*W'*B`. The default one-output form
returns an eigenvalue column; an explicit `"matrix"` one-output form returns
the diagonal eigenvalue matrix. `"vector"` selects a column for two-output
and three-output forms.

Exactly represented symmetric real or Hermitian complex pairs use the
positive-definite `Rsygvd`/`Chegvd` drivers when possible. `"chol"` requires
that structured pair and a positive-definite `B`; the default falls back to
QZ when `B` is singular or not positive definite. `"qz"` forces the general
`Rggev`/`Cggev` drivers. Generalized `"balance"` and `"nobalance"` options are
not accepted, matching the audited Octave interface.

Real QZ results are returned as complex `mp` values so real conjugate pairs
retain their imaginary components. The backend's `alpha/beta` representation
is divided at the stored operation precision; `beta = 0` therefore retains an
infinite eigenvalue rather than rejecting the problem. Mixed real/complex
pairs are promoted once to MPC at the maximum input precision.

All LAPACK calls operate on owned copies. The selected precision is uniform
through each MPFR/MPC scope and is independent of the ambient construction
default. No generalized path converts through builtin binary64 arithmetic.
