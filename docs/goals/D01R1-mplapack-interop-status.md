# D01R1 status — `mplapack-interop` identity and binary architecture

Status: **PASS — MPLAPACK-INTEROP IDENTITY FROZEN**

The D01R1 release-freeze branch is complete. The historical `mplapack` 0.2.0
identity and `v0.2.0` tag were not modified. The renamed package is frozen as
`mplapack-interop` 0.2.1.

## Frozen package identity

```text
Repository: nakatamaho/octave-mplapack
Branch: topic/d01r1-0.2.1-release-freeze
Freeze commit: b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6
Version: 0.2.1
Tag: v0.2.1
Tag target: b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6
Archive: mplapack-interop-0.2.1.tar.gz
Archive size: 247628 bytes
SHA256 A: 28769e877e0588a59d9c0d6736fb875624df8b836f570cc9e87eda7d74936d0f
SHA256 B: 28769e877e0588a59d9c0d6736fb875624df8b836f570cc9e87eda7d74936d0f
Hashes identical: YES
Remote tag target: verified
Archive from tagged tree: verified identical
```

The final archive is also installed at:

```text
/home/docker/src/mplapack-interop-0.2.1.tar.gz
```

The `/home/docker`-specific local installer remains in the repository for
developer use but is intentionally excluded from the public source archive.
The external helper `/home/docker/install-local-octave-mplapack.sh` defaults
to the frozen release archive and records the same SHA256.

## Dependency evidence

```text
gmpfrxx_mkII:
  version: 1.4.1
  commit: 32a7fb797202cdf92312ed9d133f96fdbcda590a
  tag: v1.4.1
  archive: gmpfrxx_mkII.1.4.1.tar.xz
  SHA256: 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4

MPLAPACK:
  version: 3.0.1
  tested source commit: c21a9f56224308afda9e7424ca9928d4cf840f7a
  archive: mplapack-3.0.1.tar.xz
  SHA256: f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1
  size: 85807808 bytes
  runtime: libmplapack_mpfr.so.3
```

The MPLAPACK archive supplied for D01R1 contains the macOS shell/load-probe
fixes, the external-gmpfrxx pkg-config include-path fix, the public
`mplapack_mpfr_precision.h`, and generated release files. MPLAPACK release QA
and `v3.0.1` tag creation remain owned by the release maintainer; this
worktree did not create or alter that tag. The clean installed consumer and
full Octave regression below used this exact archive and commit identity.

## Completed gates

### G-D01R1-NAME-SYNTAX — PASS

GNU Octave 11.1.0 accepted the exact hyphenated package name through isolated
install, list, describe, load, unload, and uninstall operations.

### G-D01R1-DEPS — PASS

The final Octave build used the supplied MPLAPACK 3.0.1 archive with
`pkg-config mplapack_mpfr` version 3.0.1, the public precision-scope header,
and runtime `libmplapack_mpfr.so.3`. Include, library, SONAME, dependency,
and external-consumer provenance checks passed. The external MPLAPACK release
tag itself is intentionally not claimed here.

### G-D01R1-RENAME — PASS

`DESCRIPTION`, README/NEWS/INDEX, help text, examples, tests, package
lifecycle checks, and release tooling use `mplapack-interop`. Historical D00
documentation deliberately retains the old `mplapack` identity.

### G-D01R1-IDENTITY — PASS

The release source has `Name: mplapack-interop`, `Version: 0.2.1`, archive
`mplapack-interop-0.2.1.tar.gz`, and tag `v0.2.1` points exactly at the
freeze commit. The old `v0.2.0` tag is unchanged.

### G-D01R1-NUMERICAL-EQUIVALENCE — PASS

D01R1 changed package identity and release tooling only. No numerical
implementation, public `mp` API, backend, or fallback behavior was changed.

### G-D01R1-REGRESSION — PASS

The final local CI used the frozen installed stack from the gmpfrxx 1.4.1 and
MPLAPACK 3.0.1 candidate archives. It passed:

```text
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex Cgetrf: PASS
1024-bit and 2048-bit precision canaries: PASS
ambient/default precision and scope restoration: PASS
compatibility firewall: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
package install/load/smoke/unload/uninstall/reinstall: PASS
```

The native wall included real Rgemm/Rgesv/Rgels/Rgelss/Rpotrf/Rgeqrf/Rorgqr/
Rgeqp3/Rgetrf and complex Cgemm/Cgesv/Cgelsy/Cpotrf/Cgeqrf/Cungqr/Cgeqp3/
Cgetrf coverage, lifetime tests, and dependency negative tests.

### G-D01R1-REPRODUCIBLE — PASS

Two independent deterministic source-package generations from the final
source produced identical file lists, top-level directory, size, and SHA256.
A clean extraction build and package lifecycle passed without Git metadata or
source-worktree headers.

### G-D01R1-BINARY-ARCH — PASS

The source/binary boundary, Octave API key, package-local runtime layout,
Linux `$ORIGIN`/`DT_RUNPATH`, macOS `@loader_path`/`@rpath`, Windows DLL
strategy, naming matrix, and license handoff are documented in
`docs/binary-distribution.md`. No B01-B05 production binary was built.

## Release engineering commits

```text
dd123dcb  Freeze mplapack-interop 0.2.1 package metadata
dfc23fd4  Use Bash syntax checks for Bash release helpers
0354f74   Make the local installer default to the frozen 0.2.1 archive
d2e0db5   Exclude the developer-only local installer from release archives
b19f679   Record the final 0.2.1 source archive checksum
```

The branch and `v0.2.1` tag were pushed. The tag is annotated; its peeled
target was verified remotely.

## Restrictions observed

No Debian package, PPA modification/upload, Launchpad upload, Octave Packages
registry submission, GitHub Release, or B01-B05 binary-distribution build was
performed.

## Result

```text
D01R1 PASS — MPLAPACK-INTEROP IDENTITY FROZEN
B01-READY
```

The next item in the active numerical/API sequence is N00. B01 is not started
automatically.
