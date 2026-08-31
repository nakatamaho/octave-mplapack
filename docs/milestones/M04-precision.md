# M04 — Precision API

# Goal

Implement `mpbits()`, `mpbits(n)`, `mpdigits()`, and `mpdigits(n)`.

# Scope

Querying and changing the default precision, applying it to new values, and a
documented upward-rounded decimal-digit-to-bit conversion.

# Non-goals

- Retrospectively changing existing objects
- An undocumented guard-bit policy
- Making decimal digits the canonical internal unit

# Design constraints

Bits are canonical. Existing values retain their precision after the default
changes. `mpdigits(n)` rounds upward to sufficient bits and must not truncate
`n * log2(10)`. Any guard bits require a documented rationale and reporting
contract before implementation.

# Implementation tasks

- Define a validated default-precision configuration.
- Implement bit queries and updates.
- Implement and document decimal-digit conversion.
- Ensure newly constructed objects capture the current default.

# Required tests

Test the default query, precision changes, unchanged old values, changed new
values, invalid requests, direct string conversion at increasing precision,
and documented upward rounding from decimal digits to bits.

# Gate

`G04` passes when both APIs and object-lifetime precision semantics match the
normative contract. This gate is planned and is not passed by M00.

# Expected commit

`M04: implement precision configuration APIs`
