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

- Native real addition, subtraction, multiplication, division, and negation
  use direct MPFR operations with `MPFR_RNDN`.
- `mp`/`mp` results use the greater operand precision. Mixed scalar binary64
  operands are converted directly at the `mp` operand precision.
- Division by zero, signed zeros, infinities, and NaNs follow verified MPFR
  behavior rather than project-specific exceptions.
- Public results wrap independently owned internal payloads without invoking
  the public constructor or current default precision.

# Required tests

Automated Octave and standalone sanitizer tests cover exact scalar arithmetic,
mixed precision, both mixed-binary64 operand orders, low-precision rounding,
division by zero, signed zero, special values, lifetime, unsupported types and
operators, and the matrix firewall.  A standalone direct-MPFR reference test
checks all production storage operations.

# Gate

`G06` passed when all four binary scalar operators and both unary signs obeyed
documented native MPFR, precision, lifetime, and error semantics without
creating a matrix representation.

# Expected commit

`M06: add scalar MPFR arithmetic`
