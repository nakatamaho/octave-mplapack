# M11 — Dense element-wise arithmetic

# Goal

Extend dense real `mp` matrices with native MPFR `+`, `-`, `.*`, `./`, unary
`+`, and unary `-`, including two-dimensional singleton expansion.

# Scope

Use explicitly precisioned native MPFR destination elements and preserve the
M07 one-payload column-major matrix representation. Existing M06 scalar
semantics remain authoritative.

# Non-goals

- Matrix power, transpose, concatenation, assignment, and comparison
- Logical operations, reductions, complex, sparse, or N-D arrays
- MPLAPACK calls for element-wise arithmetic

# Design constraints

MPLAPACK is not used by the element-wise kernel. Result precision is derived
from operands, current defaults do not participate, and public operands remain
immutable.

# Implementation tasks

- Add one native MPFR element-wise kernel with checked broadcasting.
- Extend public arithmetic dispatch for scalar and dense matrix operands.
- Add mixed binary64, special-value, precision, lifecycle, and sanitizer QA.

# Required tests

Verify same-shape, scalar, row, column, outer singleton, and compatible empty
shapes against builtin Octave semantics. Verify mixed precision, binary64
source semantics, signed zero, Inf, NaN, division by zero, and M00-M10
regressions from source and installed packages.

# Gate

`M11` passes when arithmetic, broadcasting, precision, binary64, special-value,
robustness, installed-package, and M00-M10 regression gates pass.

# Expected commit

`M11: add dense mp element-wise arithmetic`
