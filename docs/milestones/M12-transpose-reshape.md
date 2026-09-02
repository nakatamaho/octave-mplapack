# M12 — Dense transpose and reshape

# Goal

Provide precision-preserving read-only `transpose`, `ctranspose`, and
two-dimensional `reshape` for dense real `mp` values.

# Scope

Implement `A.'`, `A'`, `reshape(A,m,n)`, `reshape(A,[m n])`, and one inferred
`[]` dimension using independent native MPFR matrix storage.

# Non-goals

- Concatenation, indexed assignment, matrix power, or comparisons
- N-D reshape, permutation, squeeze, or views
- Complex, sparse, or other numerical backends

# Design constraints

Structural operations copy existing MPFR values directly at the source
precision, preserve column-major order, and do not call MPLAPACK or consult or
modify the project/current-thread precision defaults. A `1x1` result uses the
canonical scalar payload.

# Implementation tasks

- Add native transpose and reshape copy helpers with checked dimensions.
- Add public `transpose`, `ctranspose`, and `reshape` dispatch.
- Add precision, empty-shape, differential, lifecycle, and sanitizer QA.
- Document structural semantics and deferred features.

# Required tests

Verify scalar, matrix, vector, empty, special-value, and 1024/2048-bit
precision cases; column-major reshape order; valid and invalid dimensions;
`[]` inference; M10/M11/M08/M09 interoperability; installed-package and
M00–M11 regressions.

# Gate

`M12` passes when transpose, reshape, Octave differential, precision,
interoperability, robustness, installed-package, and M00–M11 regression gates
pass from a clean source tree.

# Expected commit

`M12: add dense mp transpose and reshape`
