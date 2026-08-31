# M05 — Conversion and display

# Goal

Implement `char(A)`, `double(A)`, and `disp(A)`.

# Scope

Deterministic multiprecision textual output, explicit conversion to binary64,
and normal interactive display for the real `mp` scalars available before
M07.  Matrix conversion/display is extended after dense storage exists.

# Non-goals

- Implicit conversion of operations to binary64
- Complex formatting
- A guarantee that `double(A)` retains multiprecision information

# Design constraints

Display must format native multiprecision values without silently converting
through binary64. Text must be deterministic enough for tests. `double(A)` is
explicit and its expected precision loss must be documented.

# Implementation tasks

- Define a stable scalar textual form.
- Implement `char` directly from native values.
- Implement explicit scalar `double` conversion.
- Implement `disp` using multiprecision formatting.

# Required tests

Test scalar precision-sensitive and special-value output. Verify deterministic
text, explicit binary64 conversion and expected loss, and absence of hidden
binary64 display conversion.

# Gate

`G05` passes when conversion and display behavior is documented, deterministic
where required, and never silently substitutes binary64. This gate is planned
and is not passed by M00.

# Expected commit

`M05: implement mp conversion and display`
