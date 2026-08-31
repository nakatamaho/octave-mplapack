# M02 — Native MPFR scalar value storage

# Goal

Introduce the smallest safe internal native representation for one
multiprecision scalar and prove its ownership and module-lifetime behavior.
The M02 value is not the public `mp` class.

# Scope

- Deterministic RAII ownership
- Explicit value precision
- Safe copy, destruction, assignment, temporaries, and moves if used
- A supported Octave 11.1 custom-value integration
- Immutable native payloads and deep clone support
- Module lock, clear, package-unload, and interpreter-shutdown safety
- Standalone sanitizer and installed-package lifecycle QA

# Non-goals

- Complete matrix construction or arithmetic
- User-visible pointer handles or a global handle registry
- Premature Octave 8 implementation throughout numerical code
- Public `mp()` construction, conversion, display, arithmetic, or matrices

# Design constraints

The implementation uses the installed Octave 11.1
`octave_base_dld_value`, type-ID macros,
`octave_value(octave_base_value *)`, checked type ID plus `dynamic_cast`, and
explicit DLD function locking. The DLD-aware base retains the containing shared
library for every value and the registered prototype. The registered internal
type is `mplapack_mpfr_scalar_internal`; it is never exposed as public `mp`.

`MpfrScalarStorage` owns `mpfrxx::mpfr_class`, the installed MPLAPACK MPFR
`REAL` type. Each object is constructed with explicit precision, and project
copy assignment uses copy-and-swap so value and precision move together. The
Octave payload is immutable. No raw pointer handle or global object registry is
used.

# Implementation tasks

- Document the inspected Octave API and selected native-value mechanism in
  `docs/native-value-design.md`.
- Implement Octave-independent `MpfrScalarStorage` and the internal custom
  scalar representation.
- Add private creation, inspection, equality, deep-clone, and exact module-lock
  commands for M02 QA without enabling the M03 constructor.
- Lock the native module, register the type once, and verify ordinary clear,
  package unload/reload, and interpreter shutdown.
- Keep matrix storage responsibilities assigned to M07.

# Required tests

`make -C src check-storage-sanitized` runs 10,000 deterministic ownership and
contiguous-container iterations with GCC AddressSanitizer, LeakSanitizer, and
UndefinedBehaviorSanitizer. `test/native_value.tst` covers assignment, deep
clone, cells, temporaries, simultaneous 128/256/512-bit values, direct `0.1`
parsing, wrong types, invalid input, stable type identity, and repeated
initialization.

`tools/local-ci.sh` additionally covers locked ordinary clear, live values
across package unload, reload/relock, shutdown destruction, M01 regression,
two clean builds, negative dependency handling, deterministic source packaging,
and lifecycle tests against an isolated installed package. The public `mp()`
constructor is checked to remain the M03 stub.

# Gate

`G02 PASS`: native storage and the custom Octave value pass sanitizer,
lifecycle, module-lock, package-install, regression, and clean-rebuild QA with
no known ownership defects.

# Expected commit

`M02: add native MPFR scalar value storage`
