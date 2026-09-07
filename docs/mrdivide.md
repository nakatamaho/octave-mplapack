# Dense right division

N08 adds dense arbitrary-precision right division to mplapack-interop.
For A of shape m x n and B of shape p x n,

    X = A / B

returns an m x p result satisfying X * B = A for a consistent full-rank
system, or Octave-compatible least-squares/minimum-norm semantics otherwise.
The public function form mrdivide (A, B) is equivalent to the operator.

The matrix path uses the identity

    (B' \ A')'

where ' is the conjugate transpose for complex values. Full-rank square
systems use the existing Rgesv/Cgesv backend; rectangular and rank-deficient
systems use Rgelss/Cgelsy. A square singular coefficient matrix first follows
the existing mldivide Rgesv/Cgesv path and, only for right division, retries
through the rank-revealing backend to obtain the minimum-norm result. The
public square-singular mldivide error contract is unchanged.

When one operand is builtin double, it is converted once into the other
operand's stored precision. The operation chooses p_op as the maximum stored
precision of its mp operands, uses operation-owned copies for destructive
LAPACK calls, and never invokes builtin binary64 complex arithmetic as a
numerical fallback. A scalar denominator uses the existing native element-wise
rdivide path and does not call LAPACK.

Empty two-dimensional matrices and finite, infinite, and NaN values follow the
established dense mp storage and backend behavior. Invalid dimensions are
rejected with the package's existing mplapack:mp:DimensionMismatch diagnostic.
