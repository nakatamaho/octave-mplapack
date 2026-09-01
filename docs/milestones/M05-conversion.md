# M05 — Conversion and display

# Goal

Implement scalar `char(A)`, `double(A)`, and `disp(A)` without implicit
precision loss.

# Scope

Deterministic multiprecision textual output, explicit conversion to binary64,
and normal interactive display for the real `mp` scalars available before
M07.  Matrix conversion/display is extended after dense storage exists.

# Non-goals

- Implicit conversion of operations to binary64
- Complex formatting
- A guarantee that `double(A)` retains multiprecision information

# Design constraints

Display formats native multiprecision values without converting through
binary64.  Canonical text uses normalized scientific notation, special forms
`0`, `-0`, `Inf`, `-Inf`, and `NaN`, and enough base-10 digits for exact
source-precision reconstruction.  `double(A)` is explicit and uses MPFR RNDN.

# Implementation tasks

- Define a stable normalized scalar textual form.
- Use `mpfr_get_str` and `mpfr_free_str` through project RAII.
- Implement `char` directly from immutable native values.
- Implement explicit scalar `double` with `mpfr_get_d` and `MPFR_RNDN`.
- Implement `disp` using the canonical text independently of Octave format.

# Required tests

Test exact native round-trip at 128, 256, 333, 512, and 1024 bits; signed zero
and special values; locale and default-precision independence; binary64 bit
patterns, subnormal/overflow/underflow, and a tie-to-even midpoint; bare and
explicit display; sanitizer ownership; implicit-conversion and matrix
firewalls; and isolated installed-package lifecycle.

# Gate

`G05` passes when scalar conversion and display behavior is documented,
source-precision round-trip and binary64 rounding tests pass, no unsupported
operation silently substitutes binary64, and M01-M04 plus installed-package
QA remain passing.  G05 passed on the configured Octave 11.1 / MPFR 4.2.2 /
MPLAPACK 3.0.1 environment.

# Expected commit

`M05: add scalar conversion and display`
