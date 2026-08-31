# P03 — PPA staging

# Goal

Publish a verified source package only to a staging PPA first.

# Scope

Define and execute publication to a confirmed archive conceptually named
`ppa:<Launchpad user or team>/mplapack-staging`.

# Non-goals

- Stable PPA publication
- Hard-coding an unconfirmed Launchpad identity
- Automatically creating, replacing, exporting, or manipulating private GPG
  keys

# Design constraints

Launchpad builds from an uploaded signed source package. The process must
document confirmed Launchpad account/team, PPA, signing-key registration,
`dput` configuration, and required authorization without automating private-key
management.

# Implementation tasks

- Confirm Launchpad identity, staging archive, permissions, and signing setup.
- Prepare and sign the reviewed source upload using user-managed keys.
- Upload to staging and monitor all requested builds.
- Preserve source and build logs for later gates.

# Required tests

Confirm source acceptance, successful staging builds for requested targets,
correct dependency resolution, installability, and traceability to the reviewed
source package.

# Gate

`GP03` passes when the confirmed staging PPA contains successful, traceable
builds from the approved source upload. This gate is planned and is not passed
by M00.

# Expected commit

`P03: document staging PPA publication evidence`
