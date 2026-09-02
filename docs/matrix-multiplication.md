# Scope

M08 implements dense real `mp` multiplication through the installed
MPLAPACK MPFR reference `Rgemm` routine.  Scalar `mtimes` and matrix/scalar
scaling use the native MPFR scalar path; `mldivide` remains M09.

# MPLAPACK precision boundary

The MPLAPACK MPFR backend follows the uniform-precision calling contract
provided by `MplapackMpfrPrecisionScope` in the installed
`mplapack_mpfr_precision.h` header.  One invocation has one precision `p`:
the current-thread MPFR default and every participating `REAL` object are
`p` bits.  Mixed-precision arrays are never passed to MPLAPACK.

The upstream contract implementation used for M08 is commit
`1cf03d1a1aa2afecde5f1840fbe9663ecfc31e57`.  The caller, rather than
MPLAPACK, selects the operation precision.

# Operation precision and promotion

For two `mp` operands, `p = max(lhs precision, rhs precision)`.  Existing
matrices are immutable, so operation-owned column-major copies are promoted
to `p` before entering the precision scope.  Promotion uses direct MPFR
copying and preserves the stored value exactly.  A raw real double matrix,
when accepted as a mixed operand, is converted directly from its incoming
binary64 values at the other `mp` operand's precision.

The project construction default is not used to select `p`.  The temporary
scope restores the caller's current-thread default after success and errors.

# Rgemm call

Nondegenerate matrix products use `Rgemm("N", "N", m, n, k, alpha, A, lda,
B, ldb, beta, C, ldc)` with exact MPFR `alpha = 1` and `beta = 0`.  M07's
contiguous column-major `mpfr_class` storage is passed directly as `REAL *`;
there is no packing or transpose.  Dimensions and leading dimensions use
checked MPLAPACK integer conversions.

Before the call, a native contract checker verifies the TLS precision,
matrix storage precisions, and `alpha`/`beta` precision.  It only accepts a
match and never repairs a mismatch.

# Shapes and ownership

Dimension compatibility is checked before allocation.  Empty products are
handled without unsafe zero-size backend calls and retain `p` metadata.  A
`1x1` result is normalized to the existing scalar payload; all other results
are one native dense matrix payload.  Result storage is independent of both
inputs, and public inputs remain unchanged.

# Scalar scaling

`mp` scalar/matrix scaling is native MPFR element scaling at
`max(matrix precision, scalar precision)`.  Scaling by a real double uses
the matrix precision and direct binary64-to-MPFR conversion.  No double or
text arithmetic fallback is used.

# Non-goals

M08 does not implement matrix indexing, element-wise matrix operators,
matrix conversion/formatting, transpose-aware GEMM, complex matrices, sparse
matrices, or `Rgesv`/backslash.  The optimized/threaded MPFR backend is not a
dependency of this path.
