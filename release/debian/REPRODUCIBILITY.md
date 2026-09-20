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

## P04 comparison performed (2026-09-20)

Two independent clean resolute sbuilds from the same corrected P04 source
package produced:

```text
build A  38e5db17c3371e373833ad3222d488a560297fe6ea35dac9a1815a587cf49f50  octave-mplapack-interop_0.5.0-1_amd64.deb
build B  659c00d4f42495d47a801fcd6069367f563dbddac80d3f5355e41424b0f42e92  octave-mplapack-interop_0.5.0-1_amd64.deb
```

The file lists and package metadata are equivalent, but the hashes differ.
`diffoscope` identified different `.note.gnu.build-id` and
`.gnu_debuglink` values in `__mplapack_core__.oct`; removing those two ELF
sections made the two extension binaries byte-identical. The clean build logs
show `mkoctfile` compiling through randomly named `/tmp/oct-*.o` temporaries,
which are retained in split DWARF data and therefore influence the build-id
and debuglink.

This is a real reproducibility defect in the draft P04 build path, not a
permission or runtime-loader issue. No Lintian override or source-semantic
workaround has been added. The Debian packaging review must either make the
object/debug paths deterministic or adopt a reviewed build-id/debug-symbol
policy before P04 can be called reproducible.

## Current gate

```text
REPRODUCIBILITY: PARTIAL (P04 comparison failed; remediation open)
```

This status does not weaken the already passing clean-build, isolated
autopkgtest, piuparts, or local APT-stack evidence, but it prevents a P05
PASS claim.
