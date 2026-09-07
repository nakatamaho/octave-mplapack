# N08 — Dense real and complex mrdivide

N08 implements the public dense A / B and mrdivide (A, B) operations for real
and complex mp values. The matrix implementation is the
conjugate-transpose reduction (B' \ A')'; scalar denominators remain on the
native element-wise division path.

The existing square mldivide path still uses Rgesv/Cgesv and preserves its
singular-matrix error. Right division catches that error only and uses the
rank-revealing Rgelss/Cgelsy path, which provides Octave-compatible
minimum-norm results for singular square and rank-deficient rectangular
denominators. All converted operands, workspaces, and LAPACK arguments obey
the one-operation/one-precision MPFR/MPC contract.

The N08 regression covers scalar, matrix/scalar, matrix/matrix, real, complex,
mixed, square, rectangular, rank-deficient, singular, empty, special-value,
conjugate-transpose, immutability, 1024/2048-bit, ambient precision,
explicit-function, and permanent Grcar right-division cases.
