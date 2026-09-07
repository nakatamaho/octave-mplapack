# S05 report — ranges, rounding, and utility arithmetic

## Result

```text
S05 PASS — RANGES, ROUNDING, AND UTILITY ARITHMETIC CLOSED
```

Implementation commit: `b97ed2ea231cbb9bb1fd8b7334911d86cb2db7db`.

## Public API

```text
colon(a,b) and colon(a,s,b): PASS — native MPFR ranges
linspace: PASS — native MPFR real and MPC complex forms
logspace: PASS — native MPFR powers of ten and pi endpoint behavior
floor/ceil/fix/round: PASS — native MPFR real matrix forms
rem/mod: PASS — native MPFR signs and singleton expansion
hypot/atan2: PASS — native MPFR utility arithmetic and singleton expansion
signbit: PASS — native MPFR logical sign-bit results
eps: PASS — local spacing at each value's stored MPFR precision
```

The range implementation performs its loop and step progression with MPFR at
the selected operation precision. It rejects zero steps and steps that become
too small to advance at that precision. `linspace` preserves both supplied
endpoints and promotes to MPC only when a complex endpoint is present.
`logspace` handles the Octave `pi` endpoint rule without generating that final
value through binary64 arithmetic.

Rounding, remainder, modulus, `hypot`, `atan2`, `signbit`, and `eps` use
native MPFR storage and operations. Two-dimensional singleton expansion is
supported for the binary utilities. Complex forms not covered by the dense
real utility contract are rejected explicitly. No S05 numerical path silently
falls back to builtin binary64 complex arithmetic, and no existing real-only
operation is routed through a complex kernel.

## Precision and edge coverage

```text
256-bit ordinary ranges and utility fixtures: PASS
1024-bit 2^-700 canary: PASS
2048-bit 2^-1500 canary: PASS
ambient default changed after source construction: PASS
stored-precision eps(1) = 2^-(p-1): PASS
signed zero signbit: PASS
zero-step and too-small-step rejection: PASS
complex colon/logspace/rounding firewall: PASS
```

## Gates

```text
G-S05-COLON: PASS
G-S05-LINSPACE: PASS
G-S05-LOGSPACE: PASS
G-S05-ROUNDING: PASS
G-S05-REM: PASS
G-S05-MOD: PASS
G-S05-UTILITY: PASS
G-S05-EPS: PASS
G-S05-PRECISION: PASS
G-S05-REGRESSION: PASS
```

`test/script-compat/s05.tst` and the dedicated S05 gate passed. The required
post-milestone wall `tools/local-ci.sh` also passed M00–M23,
C00–C12 including mandatory C11L, N00–N08, S00–S05, native
ASan/UBSan/LSan gates, clean rebuild #2, deterministic source-package
generation, and isolated package install/unload/uninstall/reinstall QA.

The active package metadata remains `0.4.0-dev`; the immutable `v0.3.1`
source release and frozen gmpfrxx/MPLAPACK dependencies remain unchanged.

## Next milestone

Proceed automatically to S06 — Descriptive statistics.
