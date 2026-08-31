# P01 — Debian source package

# Goal

Create correct Debian packaging for source and binary package
`octave-mplapack`.

# Scope

Create the appropriate `debian/control`, `debian/rules`, `debian/changelog`,
`debian/copyright`, `debian/source/format`, and `debian/tests/` content based on
the approved P00 design.

# Non-goals

- Publishing to Launchpad
- Guessing installation directories manually
- Bundling MPLAPACK or unrelated dependency sources

# Design constraints

Use current `dh-octave` conventions where applicable and rely on Debian's Octave
packaging infrastructure instead of manually guessing installation paths. Build
dependencies must reflect actual probes and the MPFR backend baseline.

# Implementation tasks

- Research current Debian and `dh-octave` policy for the targets.
- Add source metadata, build rules, copyright, changelog, and tests.
- Declare verified build and runtime dependencies.
- Ensure the source package is reproducible and policy-aligned.

# Required tests

Validate Debian metadata and source-package generation with supported tooling.
Verify that install paths come from packaging infrastructure and that all
license and dependency declarations match the source.

# Gate

`GP01` passes when a policy-valid Debian source package can be generated from
the repository. This gate is planned and is not passed by M00.

# Expected commit

`P01: add Debian source package metadata`
