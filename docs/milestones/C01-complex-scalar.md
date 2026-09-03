# Goal

Make complex scalar `mp` values first-class while preserving the real native
payload kind.

# Scope

Add direct builtin complex-double construction, exact two-component text
construction, deterministic canonical text, explicit complex-double
conversion, display, and special-value coverage.

# Non-goals

Complex dense indexing, structural operations, arithmetic, and LAPACK paths
are deferred to C02-C11L.

# Design constraints

Builtin complex doubles are converted component-by-component directly into
the stored `mpc_class` at the current project precision. Two text arguments
are parsed directly at that precision. Canonical text uses `(real,imag)` with
locale-independent MPFR component text and is accepted by the constructor.

# Implementation tasks

- Add `mp(complex_double)` and `mp(real_text, imag_text)`.
- Accept canonical complex scalar text for round trips.
- Return builtin `Complex` from explicit `double` conversion.
- Preserve real constructor payloads and expose `isreal(mp)`.

# Required tests

The C01 public scalar test, 1024/2048-bit precision canaries, signed-zero,
Inf/NaN, canonical round trips, direct component conversion, and the complete
real regression wall.

# Gate

`C01 PASS` requires G-C01-CONSTRUCT, G-C01-DOUBLE, G-C01-CHAR,
G-C01-DISP, G-C01-PRECISION, G-C01-SPECIAL, and G-C01-REAL-PARITY.

# Expected commit

`C01: add complex scalar construction and conversion`
