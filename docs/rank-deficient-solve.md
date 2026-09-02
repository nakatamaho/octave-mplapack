# Dense MPFR rank-deficient rectangular solve

M16 extends rectangular dense real `mp` left division to rank-deficient
systems.  For `A` of size `m x n` and `B` of size `m x nrhs`, `A \ B` returns
an `n x nrhs` minimum-norm least-squares solution.  This includes the
full-column-rank overdetermined case (`m >= n`) and full-row-rank or
rank-deficient underdetermined cases (`m < n`).

The public rectangular path uses the installed MPLAPACK MPFR `Rgelss`
driver.  `Rgelsy` was audited but rejected because its pinned MPFR path
misclassified an exact rank-one fixture at 512 bits; `Rgelsd` passed but adds
unneeded divide-and-conquer and integer-workspace complexity.  `Rgelss`
provides SVD-based rank determination and the minimum-norm solution.

Before each call, the binding derives `p_op` from the operands, copies `A`
and a `max(m,n) x nrhs` padded `B` into operation-owned storage, and creates
`RCOND`, singular values, and `WORK` at `p_op`.  A
`MplapackMpfrPrecisionScope(p_op)` surrounds both the workspace query and the
actual call.  No mixed-precision MPLAPACK invocation is issued and public
inputs are never overwritten.  The default rank threshold is `Rlamch_mpfr("E")`
at `p_op`, not a binary64 constant or the ambient `mpbits()` setting.

For `m != n`, rank deficiency is supported and the reported rank remains an
internal diagnostic.  `info > 0` is a deterministic convergence error and
`info < 0` is an internal argument error.  Square systems continue to use
M09 `Rgesv`, including their existing singular behavior; scalar division is
unchanged.

The effective numerical rank can change with `p_op`.  A direction below the
machine epsilon at one operand precision can be resolved at a higher
precision.  Rank tolerance is not a public argument in M16.  Rank-revealing
public APIs, singular values, condition estimates, complex and sparse systems
remain future work.
