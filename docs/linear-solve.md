# Dense MPFR linear solve

M09 adds dense real `mp` left division through the installed MPLAPACK MPFR
`Rgesv` routine. The coefficient matrix must be square; a right-hand side may
contain one or more columns. Rectangular least-squares, complex, sparse, and
reusable factorization interfaces are outside this milestone.

## Uniform precision boundary

Public operands remain immutable and may have different precisions. The
operation precision is the maximum precision of participating `mp` operands
(or the precision of the sole `mp` operand with a builtin real double). Native
operation-owned copies of `A` and `B` are promoted to that precision. The
caller enters `MplapackMpfrPrecisionScope` at the same precision before
calling `Rgesv`; mixed-precision MPLAPACK calls are never issued.

`Rgesv` overwrites both arrays during LU factorization and solve, so public
payloads are never passed to the backend. The returned operation-owned `B`
buffer is the solution and a 1x1 result is normalized to the scalar payload.

## Status and empty systems

`info == 0` returns the solution. Positive `info` is reported as a
deterministic singular-matrix error; negative `info` is reported as an
internal `Rgesv` argument error. A `0x0` coefficient matrix with a compatible
empty right-hand side returns an empty result without calling `Rgesv`.

Scalar left division uses native MPFR division/scaling rather than LAPACK.
The current `mpbits()` setting is restored after every operation and does not
select the precision of existing operands.
