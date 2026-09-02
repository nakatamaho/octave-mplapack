# M14 — Dense `mp` indexed assignment

# Goal

M14 adds value-semantic, in-bounds indexed assignment for dense real `mp`
matrices.  The implementation always creates an independent native payload,
so assignment through an alias cannot mutate the original object.  The
complete result remains a uniformly precisioned `MpfrMatrixStorage`.

Supported forms include two-subscript scalar/vector/matrix assignment,
single scalar linear assignment, and colon-linear assignment.  Matrix growth,
deletion, logical assignment, general vector linear assignment, complex,
sparse, and N-D values remain outside the milestone.

The result precision is `max(lhs, rhs)` for two `mp` values and the lhs
precision for a builtin double rhs.  Structural copies use direct MPFR value
transfer and never consult or mutate the current precision default.

The M14 gate requires value-semantic alias safety, verified Octave index and
shape behavior, precision widening/preservation, binary64 and special-value
handling, interoperability with M10–M13, sanitizer/lifecycle QA, and the full
M00–M13 regression suite.

# Scope

The supported surface is `A(i,j)=x`, row/column and submatrix assignment,
single scalar linear assignment, and `A(:)=scalar_or_compatible_rhs` for real
dense `mp` and builtin double values.

# Non-goals

Matrix growth, deletion, logical/general-vector assignment, complex, sparse,
N-D, and chained/cell/field assignment are deferred.

# Design constraints

Public payloads remain immutable. The native bridge always deep-copies the
lhs and performs direct MPFR copies/conversions without MPLAPACK or a precision
scope.

# Implementation tasks

Use shared M10 index validation, M13 exact promotion semantics, checked storage
arithmetic, and one native assignment kernel for two-subscript and linear
forms.

# Required tests

Cover alias/value semantics, scalar expansion, row/column/submatrix and linear
assignment, `end`, precision widening/preservation, binary64 and special
values, unsupported growth/deletion, lifecycle, sanitizers, and M00–M13
regressions.

# Gate

The milestone passes only when the G14 value, index, shape, precision,
binary64, limits, interoperability, and robustness gates all pass.

# Expected commit

`M14: add dense mp indexed assignment`
