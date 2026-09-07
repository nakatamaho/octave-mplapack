# Determinant and inverse

`mplapack-interop` N01 provides dense arbitrary-precision `det` and `inv`
for real and complex `mp` values.

## Determinant

Real determinants use MPLAPACK `Rgetrf`; complex determinants use `Cgetrf`.
The operation owns the LU copy, counts the row-swap parity, and multiplies
the diagonal of U at the stored operand precision. A singular factorization
returns an exact MPFR/MPC zero. The empty 0-by-0 determinant is one, while
nonsquare inputs are rejected.

Only the one-output form is implemented in N01. A possible reciprocal
condition output is intentionally deferred until the N03 condition-number
machinery is complete.

## Inverse

Real inverses use `Rgetrf` followed by an `Rgetri` workspace query and the
final `Rgetri` call. Complex inverses use the corresponding `Cgetrf` and
`Cgetri` path. Query and execution use the operation-owned factor copy,
uniform MPFR/MPC precision scopes, checked workspace sizes, and explicit INFO
validation. Singular and nonsquare inputs produce package diagnostics.

No path converts an input to binary64, and `inv` does not replace the
existing `A\b` solve operation with an explicit inverse.

## Precision and value semantics

The operation precision is the stored operand precision. Ambient `mpbits`
changes do not change an existing matrix's precision. Inputs remain unchanged
after determinant, inverse, singular, and workspace-query paths. Real inputs
remain on real MPLAPACK kernels; complex inputs remain on MPC kernels.
