# P06 — Ubuntu series and architecture matrix

# Goal

Validate and maintain the explicitly approved Ubuntu series and architecture
matrix.

# Scope

The initial desired matrix is:

```text
Ubuntu 26.04 LTS
  amd64
  arm64

Ubuntu 24.04 LTS
  amd64
  arm64
```

# Non-goals

- Adding architectures merely because Launchpad can build them
- Adding older Ubuntu releases without explicit review
- Allowing the secondary target to compromise the Octave 11 design

# Design constraints

Ubuntu 26.04 LTS is primary and Ubuntu 24.04 LTS is secondary. Every matrix
entry requires usable dependencies, successful source builds, installed-package
tests, and an explicitly maintained support decision.

# Implementation tasks

- Confirm dependency availability for each matrix entry.
- Enable only the reviewed Launchpad builds.
- Collect build, install, and autopkgtest evidence for each entry.
- Document exclusions and future series changes explicitly.

# Required tests

For every enabled series/architecture pair, verify source build, dependency
resolution, package installation, native module loading, and the P04 functional
test against the installed package.

# Gate

`GP06` passes when all four approved matrix entries have complete successful
evidence or an explicitly reviewed scope revision. This gate is planned and is
not passed by M00.

# Expected commit

`P06: validate Ubuntu series and architecture matrix`
