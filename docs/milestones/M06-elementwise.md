# M06 — Element-wise arithmetic

# Goal

Implement `A + B`, `A - B`, `A .* B`, and `A ./ B` for real `mp` values.

# Scope

Scalar/scalar and matrix/matrix operations, mixed precision, shape validation,
and deliberate division-by-zero behavior. Scalar expansion is optional only
when its semantics can deliberately match Octave.

# Non-goals

- Accidental broadcasting
- Matrix multiplication or linear solves
- Complex arithmetic or another MPLAPACK backend

# Design constraints

Never calculate through ordinary Octave doubles. The initial mixed-precision
rule is `max(lhs precision, rhs precision)`. Shape and scalar-expansion rules
must be explicit rather than emerging accidentally from implementation details.

# Implementation tasks

- Implement native real addition, subtraction, multiplication, and division.
- Apply the mixed-precision result rule consistently.
- Validate shapes and define any supported scalar expansion.
- Define and document division-by-zero results and diagnostics.

# Required tests

Cover scalar/scalar, matrix/matrix, mixed precision, incompatible shapes,
division by zero, and every deliberately supported scalar-expansion case.
Verify that the calculations do not silently use binary64.

# Gate

`G06` passes when all four operators obey documented native MPFR, precision,
shape, and error semantics. This gate is planned and is not passed by M00.

# Expected commit

`M06: implement element-wise mp arithmetic`
