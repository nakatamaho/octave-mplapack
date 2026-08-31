# M01 — Build and dependency probe

# Goal

Build the smallest native `.oct` module and prove that Octave can load a module
linked to MPLAPACK's MPFR backend. The target public function is
`mplapack_version()` after `pkg load mplapack`.

# Scope

Report, where reliably obtainable, the Octave version, MPLAPACK version,
`backend = mpfr`, and MPFR version. Establish the minimal package native build.

# Non-goals

- Native `mp` storage or constructors
- Numerical matrix operations
- A general MPLAPACK wrapper layer

# Design constraints

Use `mkoctfile` through package tooling, honor `MKOCTFILE`, and discover
`mplapack_mpfr` through `pkg-config`. Do not hard-code a prefix or depend on an
MPLAPACK source/build tree. Keep `__mplapack_core__.oct` private.

# Implementation tasks

- Record the `pkg-config` version, flags, libraries, and resolved installation.
- Implement the smallest non-fabricated version probe.
- Build and load the module in Octave.
- Inspect linker dependencies and document the evidence.

# Required tests

Prove that `mkoctfile` produces the module, Octave loads it, runtime linker
dependencies resolve, and the MPLAPACK MPFR backend is actually linked without
access to an MPLAPACK build tree.

# Gate

`G01` passes when the build, load, linkage, dependency, and version-reporting
evidence succeeds. This gate is planned and is not passed by M00.

# Expected commit

`M01: add MPLAPACK MPFR native build probe`
