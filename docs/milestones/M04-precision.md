# M04 — Precision API

# Goal

Implement `mpbits()`, `mpbits(n)`, `mpdigits()`, and `mpdigits(n)`.

# Scope

Querying and changing the default precision, applying it to new values, and a
documented, certified decimal-digit-to-bit conversion.  The fresh-session
initial default is 512 bits.

# Non-goals

- Retrospectively changing existing objects
- An undocumented guard-bit policy
- Making decimal digits the canonical internal unit

# Design constraints

Bits are canonical. There is exactly one process-local project state in
`mp_precision`; neither the `.m` wrappers nor MPFR's global default hold a
second value. Existing values retain their precision after the default
changes. `mpdigits(n)` maps to `ceil(n * log2(10))` bits, while `mpdigits()`
reports `floor(bits * log10(2))` complete digits. M04 uses no guard bits.

The native implementation uses directed MPFR lower and upper bounds and
accepts a conversion only when both bounds prove the same integer result.
Setters validate and convert before atomically committing state, so failure is
transactional. State survives clear and package unload/reload within a process
but is not persisted to another process.

# Implementation tasks

- Expose the M03 precision component through public `mpbits` and `mpdigits`
  wrappers backed by private native commands.
- Change the fresh-session project default from 128 to 512 bits.
- Return public precision counts as exact Octave `uint64` scalars.
- Accept real scalar integer-valued floating and Octave integer inputs within
  their exact ranges; reject invalid and overflowing requests without mutation.
- Certify bit/digit conversions using directed MPFR interval arithmetic.
- Keep state process-local, atomically accessed, and persistent across the
  module's safe unload/reload lifecycle.
- Ensure new values capture the current default and old/copy values retain
  their stored per-object precision.

# Required tests

Test the fresh 512-bit/154-digit state; 128/256/512-bit simultaneous values;
copy stability; required 1/10/38/100/1000 digit mappings; 128/332/333-bit
getter mappings; all invalid input classes; overflow rollback; constructor
semantics at multiple precisions; 10,000 state operations; clear;
unload/reload persistence; fresh-process reset; sanitizers; clean rebuilds;
and isolated source-package install/reinstall.

# Gate

`G04` passes when both APIs, certified conversions, transactional validation,
session lifetime, installed-package behavior, and immutable per-object
precision match the normative contract.

# Expected commit

`M04: add public precision controls`
