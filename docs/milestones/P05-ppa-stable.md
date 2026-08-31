# P05 — PPA stable

# Goal

Promote only staging packages that passed all required gates to the stable PPA.

# Scope

Publish to a confirmed archive conceptually named
`ppa:<Launchpad user or team>/mplapack` while preserving source/build
provenance.

# Non-goals

- Publishing an untested package
- Rebuilding silently from different source for stable promotion
- Assuming an unconfirmed Launchpad identity

# Design constraints

Stable publication must correspond exactly to reviewed source and staging gate
evidence. Any required rebuild must be explicit, reproducible, and versioned;
private signing-key management remains a user responsibility.

# Implementation tasks

- Verify all staging build and autopkgtest results.
- Confirm the stable archive identity and permissions.
- Copy or upload the exact approved source through a provenance-preserving
  Launchpad workflow.
- Verify the published binaries and record promotion evidence.

# Required tests

Install from the stable archive, repeat package load and M10 functional smoke
tests, and compare source versions and checksums with the approved provenance.

# Gate

`GP05` passes when stable publication is complete, functional, and provably
derived from the approved source. This gate is planned and is not passed by
M00.

# Expected commit

`P05: record stable PPA promotion`
