# Reproducibility handoff

Reproducible-build comparison is locally complete for the current P04 binary
package draft, while Debian debug-symbol policy and the remaining package
policy gates are still open. Clean sbuild compilation has passed for P02, P03,
MPC 1.4.1, and P04.

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

## P04 comparison performed (initial draft, 2026-09-20)

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

This was a real reproducibility defect in the unpatched draft P04 build path,
not a permission or runtime-loader issue. The initial comparison remains
retained as the before state.

## Packaging-only remediation and comparison (2026-09-20)

The Debian draft now carries
`debian/patches/reproducible-mkoctfile-debug-paths.patch` and a packaging-only
`dh_strip` normalization in `debian/rules`. It does not alter numerical code
or the released upstream archive; it compiles stable per-source objects,
normalizes the extracted source/debug root with `debugedit`, and clears the
generated build-id before stripping. This makes the binary package independent
of the clean build directory and random `/tmp/oct-*.o` names.

Two independent clean resolute sbuilds of that patched source package
completed successfully and produced the same binary-package hash:

```text
octave-mplapack-interop_0.5.0-1_amd64.deb
   c9e974a7141c5d9aa52f0b3caacf2f162f23dd6b08f5d0469860a6a1bf69b59f

automatic dbgsym: not emitted by the current draft; Debian maintainer
debug-symbol policy remains open
```

The ordinary binary package was byte-identical between the two clean builds.
The packaging change is subject to Debian review, especially the final
debug-symbol policy; it does not make P04 or the overall stack policy-ready.

## Current gate

```text
REPRODUCIBILITY: PASS (local patched P04 comparison)
```

This status does not weaken the already passing clean-build, isolated
autopkgtest, piuparts, or local APT-stack evidence. P05 remains PARTIAL for
the separate provider-ABI, Debian-policy, signing, and publication gates.
