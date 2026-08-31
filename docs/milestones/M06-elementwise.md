# M06 — Element-wise arithmetic

# Goal

Implement `A + B`, `A - B`, `A .* B`, and `A ./ B` for real `mp` values.

# Scope

Scalar/scalar operation infrastructure, mixed precision, and deliberate
division-by-zero behavior.  Dense element-wise matrix operations are extended
after M07 establishes matrix storage and shape.

# Non-goals

- Matrix operations, broadcasting, or scalar expansion
- Matrix multiplication or linear solves
- Complex arithmetic or another MPLAPACK backend

# Design constraints

Never calculate through ordinary Octave doubles. The initial mixed-precision
rule is `max(lhs precision, rhs precision)`. M06 must not add matrix shape,
broadcasting, or scalar-expansion behavior before M07.

# Implementation tasks

- Implement native real addition, subtraction, multiplication, and division.
- Apply the mixed-precision result rule consistently.
- Define and document division-by-zero results and diagnostics.

# Required tests

Cover scalar/scalar mixed precision, division by zero, special values, and
unsupported matrix operands. Verify that scalar calculations do not silently
use binary64.

# Gate

`G06` passes when all four scalar operators obey documented native MPFR,
precision, and error semantics without creating a matrix representation.

# Expected commit

`M06: implement element-wise mp arithmetic`
