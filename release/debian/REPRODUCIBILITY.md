# Reproducibility handoff

Reproducible-build comparison is still open for RELDEB00. Clean sbuild
compilation has passed for P02, P03, MPC 1.4.1, and P04, but one clean build is
not a reproducibility proof.

## Completed evidence

- source archives are pinned by `release/debian/PROVENANCE.md` and
  `release/debian/SHA256SUMS`;
- clean Ubuntu 26.04/resolute amd64 sbuild builds completed successfully;
- the P04 corrected package was rebuilt after its test-control fixes;
- clean package contents and runtime linkage were inspected;
- generated build artifacts are not committed to the repository.

## Required comparison

For each source package, run two independent clean builds from the same
released source archive and compare the resulting `.deb`, `.dsc`, `.changes`,
and `.buildinfo` artifacts with `reprotest`/`diffoscope` or an equivalent
Debian reproducibility workflow. Record:

```text
source archive and SHA256
build command and testbed
variation set
artifact file list
SHA256 for build A and build B
diffoscope result
```

The comparison must not use `/usr/local`, a private MPLAPACK prefix, or a
developer worktree. If the artifacts differ, classify timestamps, build paths,
toolchain metadata, debug paths, and package content separately before any
override is proposed.

## Current gate

```text
REPRODUCIBILITY: PENDING
```

This pending status is deliberate. It does not weaken the already passing
clean-build, isolated autopkgtest, piuparts, or local APT-stack evidence.
