# P00 — Packaging design

# Goal

Define the Debian and Ubuntu package architecture for `octave-mplapack`.

# Scope

Separate MPLAPACK runtime/development packages from the `octave-mplapack`
source and binary packages. Define Ubuntu 26.04 LTS as the first target and
Ubuntu 24.04 LTS as the secondary target.

# Non-goals

- Creating Debian metadata or building packages
- Creating a Launchpad archive
- Uploading prebuilt local `.deb` files as a PPA workflow

# Design constraints

Prefer system GMP, MPFR, MPC, QD, and other dependencies where technically
appropriate; do not bundle arbitrary copies into `octave-mplapack`. The initial
numerical product remains MPFR-only. Launchpad PPAs build from source packages,
and Ubuntu 24.04 compatibility must not block the initial Octave 11 design.

# Implementation tasks

- Map source, binary, runtime, development, and Octave package responsibilities.
- Research available dependency packages for each target series.
- Define source-package provenance and staging-to-stable flow.
- Record versioning, transitions, and unsupported combinations.

# Required tests

Review the design against both target series, confirm that it starts from
source packages, and validate that it neither vendors MPLAPACK nor assumes
developer-specific installation paths.

# Gate

`GP00` passes when the package architecture and target policy are reviewed and
actionable. This gate is planned and is not passed by M00.

# Expected commit

`P00: document Debian and Ubuntu packaging design`
