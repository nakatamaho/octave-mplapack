# M05 — Conversion and display

# Goal

Implement `char(A)`, `double(A)`, and `disp(A)`.

# Scope

Deterministic multiprecision textual output, explicit conversion to binary64,
and normal interactive display for real `mp` scalars and matrices.

# Non-goals

- Implicit conversion of operations to binary64
- Complex formatting
- A guarantee that `double(A)` retains multiprecision information

# Design constraints

Display must format native multiprecision values without silently converting
through binary64. Text must be deterministic enough for tests. `double(A)` is
explicit and its expected precision loss must be documented.

# Implementation tasks

- Define stable scalar and matrix textual forms.
- Implement `char` directly from native values.
- Implement explicit, dimension-preserving `double` conversion.
- Implement `disp` using multiprecision formatting.

# Required tests

Test scalar, matrix, empty, precision-sensitive, and special-value output as
supported. Verify deterministic text, explicit binary64 conversion and expected
loss, and absence of hidden binary64 display conversion.

# Gate

`G05` passes when conversion and display behavior is documented, deterministic
where required, and never silently substitutes binary64. This gate is planned
and is not passed by M00.

# Expected commit

`M05: implement mp conversion and display`
