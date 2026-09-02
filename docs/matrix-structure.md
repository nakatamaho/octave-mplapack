# Dense `mp` transpose and reshape

M12 adds read-only structural operations for real two-dimensional `mp`
matrices. `transpose` and `ctranspose` allocate independent native storage and
copy each MPFR value exactly into the transposed column-major position. The
current backend is real-only, so conjugate transpose has the same numeric
result as transpose while remaining a separate public method for future
complex support.

`reshape(A,m,n)` and `reshape(A,[m n])` preserve Octave's column-major linear
element order. One `[]` dimension may be inferred from the source element
count; two unknown dimensions are rejected. Structural operations preserve the
source matrix precision and do not consult or modify `mpbits()` or the current
thread MPFR default. A one-element result is normalized to the existing scalar
native representation. N-D reshape, assignment, permutation,
and views remain outside M12.
