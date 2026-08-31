# News

## 0.1.0-dev

- Bootstrapped the repository, package metadata, project contracts, and
  milestone plan.
- Planned MPFR real arithmetic as the first MPLAPACK backend.
- Added the private `__mplapack_core__.oct` module and public
  `mplapack_version()` diagnostic.
- Added an MPLAPACK MPFR `Rlamch_mpfr` runtime probe, dependency/linkage QA,
  deterministic source-package generation, and isolated package-install QA.
- Added internal RAII-backed MPLAPACK MPFR scalar storage with explicit
  per-object precision and immutable Octave custom-value ownership.
- Added deep-copy, module-lifetime, sanitizer, clear/shutdown, and installed-
  package lifecycle QA for the internal native value.
- Added the public scalar `mp` class with direct decimal-text and exact
  binary64 constructors at an initial project default of 128 bits.
- Added signed-zero and special-value preservation, matrix-construction
  firewalls, and installed public-wrapper lifecycle QA.
- Dense multiprecision matrices, conversion, precision control, and arithmetic
  are not implemented yet.
