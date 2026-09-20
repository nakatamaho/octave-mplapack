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
`debian/patches/reproducible-mkoctfile-debug-paths.patch`. It does not alter
numerical code or the released upstream archive; it passes the source
directory through `-ffile-prefix-map` and `-fdebug-prefix-map` when invoking
the released `mkoctfile` build. This makes compiler/debug records independent
of the clean build directory and random `/tmp/oct-*.o` names.

Two independent clean resolute sbuilds of that patched source package
completed successfully and produced identical hashes:

```text
octave-mplapack-interop_0.5.0-1_amd64.deb
   f633b94666ef11cae16a7331d6a216fec98b1412fdb52725a9dcc6216aa6d711

octave-mplapack-interop-dbgsym_0.5.0-1_amd64.ddeb
   6fc50a6f59bc5e3dffbcb21fe100d513a1073d5b33db95f8d7eb52388f7fc6e6
```

The package and split-debug artifacts were byte-identical between the two
clean builds. The patch is packaging-specific and remains subject to Debian
review; it does not make P04 or the overall stack policy-ready.

## Current gate

```text
REPRODUCIBILITY: PASS (local patched P04 comparison)
```

This status does not weaken the already passing clean-build, isolated
autopkgtest, piuparts, or local APT-stack evidence. P05 remains PARTIAL for
the separate provider-ABI, Debian-policy, signing, and publication gates.
