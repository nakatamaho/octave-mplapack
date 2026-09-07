# N06 — generalized `eig(A,B)`

N06 completes dense generalized eigenproblems for real and complex `mp`
matrices on the 0.3.0-dev development line.

The public wrapper accepts Octave-compatible `matrix`/`vector` output forms,
three-output left eigenvectors, and `chol`/`qz` algorithm selection. It uses
`Rsygvd`/`Chegvd` for exactly symmetric/Hermitian definite pairs and falls
back to, or can force, `Rggev`/`Cggev` QZ. Generalized balance options are
rejected because Octave rejects them for this interface.

The implementation preserves the generalized identities
`A*V = B*V*D` and `W'*A = D*W'*B`, converts real conjugate pairs to complex MP
values, divides `alpha/beta` at the operation precision, and preserves
infinite eigenvalues for singular `B`. Mixed real/complex inputs are promoted
once to MPC at the maximum operand precision. Destructive backend calls use
operation-owned copies, with independent MPFR/MPC precision scopes.

Required QA covers real and complex definite and QZ pairs, singular `B`,
infinite eigenvalues, option validation, matrix/vector layouts, left and right
residuals, immutability, mixed inputs, ambient precision, and 1024/2048-bit
canaries. The complete previous real/complex regression and sanitizer walls
remain mandatory.
