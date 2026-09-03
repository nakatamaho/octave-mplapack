# Goal

Establish the native arbitrary-precision complex foundation used by the
subsequent complex milestones.

# Scope

This milestone adds MPFR/MPC-owned scalar and dense column-major matrix
storage, complex native Octave payload types, and a composed per-thread
MPFR/MPC precision scope. It does not add public complex arithmetic.

# Non-goals

Public complex constructors, indexing, arithmetic, and LAPACK dispatch belong
to C01 and later milestones.

# Design constraints

Every complex element is an `mpfrxx::mpc_class` with equal explicit real and
imaginary precision. Dense storage is one contiguous `std::vector` and is
ABI-compatible with MPLAPACK's MPFR complex entry points. Native payloads are
immutable from Octave; copies are deep and ownership is RAII-based.

# Implementation tasks

- Add scalar and matrix complex storage with checked shape and leading
  dimension metadata.
- Add native complex scalar and matrix payload registration.
- Add `MpfrMpcPrecisionScope` with nested and exception-safe restoration of
  MPFR precision/rounding and MPC component precision/rounding.
- Add precision, lifetime, signed-zero, Inf/NaN, and TLS probes.

# Required tests

`make -C src check-deps`, `make -C src check-complex-storage`, the existing
M00-M23 real native test wall, and the existing public real regression suite.

The complex storage gate exercises 128, 256, 512, 1024, and 2048 bits.

# Gate

`C00 PASS` when G-C00-TYPE, G-C00-STORAGE, G-C00-PRECISION, G-C00-TLS,
G-C00-LIFETIME, G-C00-SPECIAL, and G-C00-REAL-REGRESSION pass.

# Expected commit

`C00: add complex native scaffold and MPFR/MPC precision scope`
