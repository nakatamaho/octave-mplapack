# Dense `mp` Cholesky factorization

M17 provides dense real Cholesky factorization through the MPLAPACK MPFR
`Rpotrf` routine:

```octave
R = chol (A);
R = chol (A, "upper");
L = chol (A, "lower");
[R, p] = chol (A);
[L, p] = chol (A, "lower");
```

The default is `"upper"`.  Dense `chol` uses only the selected triangle of
the input; the ignored triangle is not checked for symmetry.  Thus the upper
form satisfies `R.' * R` for the symmetric matrix described by the upper
triangle, and the lower form satisfies `L * L.'` for the matrix described by
the lower triangle.

`Rpotrf` overwrites its input, so the native bridge factors an operation-owned
deep copy.  Public `mp` values remain immutable and the returned factor owns
independent storage.  A successful factor has the stored precision of `A`;
the current `mpbits()` setting is only a construction default and is
irrelevant to an existing factorization.  The bridge enters the MPLAPACK
uniform-precision scope at that source precision and restores the prior
thread default on every exit path.

With one output, a non-positive-definite input raises an Octave-facing error.
With two outputs, the factor/status form returns the positive failure index in
`p` and the partial factor shape/content observed from dense Octave.  A
successful call returns `p == 0`.  The status is a builtin numeric scalar, not
an `mp` value.

M17 is real dense only.  Sparse and complex Cholesky, the dense three-output
permutation form, `cholupdate`-family operations, `cholinv`, and automatic SPD
optimization of `mldivide` remain future work.
