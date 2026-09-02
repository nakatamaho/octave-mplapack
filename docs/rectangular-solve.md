# Dense MPFR rectangular solve

M15 extends `mp` left division to full-rank rectangular dense real systems
through MPLAPACK MPFR `Rgels`. For an `m x n` coefficient matrix and an
`m x nrhs` right-hand side, the result is an `n x nrhs` matrix. When `m > n`
the result is the full-column-rank least-squares solution; when `m < n` it is
the full-row-rank minimum-norm solution.

Square systems continue to use M09 `Rgesv`, and scalar left division continues
to use native MPFR arithmetic. Rectangular inputs are required to be full
rank. Rank-revealing drivers, pseudoinverses, normal equations, and complex
or sparse inputs are outside this milestone.

Before `Rgels`, the binding creates operation-owned copies of `A` and a
`max(m,n) x nrhs` padded `B` buffer. The workspace query and solve run inside
`MplapackMpfrPrecisionScope(p_op)`; `A_work`, `B_work`, and `WORK` all have
uniform `p_op` precision. No mixed-precision MPLAPACK call is issued and the
public operands are never overwritten. The workspace recommendation is
converted with finite, integral, range-checked validation.

On success the first `n` rows of the padded RHS form the public solution. A
positive `info` is reported as a deterministic rank-deficient error; a
negative `info` is reported as an internal `Rgels` argument error. Empty
rectangular systems use compatible Octave shapes without unsafe zero-size
LAPACK calls. The current `mpbits()` setting is a construction default only.
