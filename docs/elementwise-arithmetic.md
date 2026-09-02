# Dense `mp` element-wise arithmetic

M11 extends the existing scalar MPFR arithmetic to real, two-dimensional
dense `mp` matrices. The native kernel writes directly into explicitly
precisioned `MpfrMatrixStorage` and does not call MPLAPACK or convert through
binary64.

## Operations

The supported operations are `+`, `-`, `.*`, `./`, unary `+`, and unary `-`.
For binary operands the result precision is:

| operands | result precision |
| --- | --- |
| `mp(pA)` and `mp(pB)` | `max(pA, pB)` |
| `mp(pA)` and real `double` | `pA` |
| real `double` and `mp(pB)` | `pB` |
| unary operation on `mp(p)` | `p` |

All arithmetic uses direct `mpfr_add`, `mpfr_sub`, `mpfr_mul`, `mpfr_div`, or
`mpfr_neg` with `MPFR_RNDN`. The current `mpbits()` value and the current
thread MPFR default do not select the arithmetic precision, and M11 does not
enter an MPLAPACK precision scope.

## Singleton expansion

Binary matrix operands use normal two-dimensional singleton expansion. Equal
dimensions or a dimension of one are compatible; the non-singleton dimension
is used for the result. Scalar `mp` values are `1x1` operands. Source matrices
are indexed directly in column-major order, without materializing expanded
copies.

Empty dimensions follow the same compatibility rule as builtin Octave dense
arrays. Incompatible dimensions raise a dimension error before result
allocation.

## Mixed binary64 values and special values

Real builtin doubles are transferred directly with `mpfr_set_d` into an
explicitly precisioned native value. Decimal text is not used, so incoming
binary64 `0.1` remains distinct from decimal text `"0.1"`, while dyadic
`0.125` agrees. NaN, infinities, signed zeros, and division by zero follow
the underlying MPFR semantics.

## Immutability and non-goals

Public operands are immutable and results own independent native storage.
MPLAPACK `Rgemm`/`Rgesv` remain the implementations of `*` and `\`. Matrix
assignment, transpose, concatenation, power, comparisons, logical indexing,
reductions, complex values, and sparse values remain outside M11.
