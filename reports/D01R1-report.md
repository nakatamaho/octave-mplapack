# D01R1 RESULT

## Result

D01R1 PASS — MPLAPACK-INTEROP IDENTITY FROZEN

Release identity conclusion: MPLAPACK-INTEROP IDENTITY FROZEN

Binary distribution conclusion: B01-READY; architecture frozen, production
B01-B05 builds not started.

## Historical D00 package identity

```text
Repository: nakatamaho/octave-mplapack
Old package Name: mplapack
Old version: 0.2.0
Old freeze commit: 4a3eb50843a6bf365bdab1e82146ef1900a219f6
Old tag: v0.2.0
Old archive: mplapack-0.2.0.tar.gz
Old SHA256: 0e83e26182b0fbd95a064437a97307eb74d9291b49d91c6e53dac181b24a94db
Old tag unchanged: YES
```

## Frozen dependencies

### gmpfrxx_mkII

```text
Version: 1.4.1
Commit: 32a7fb797202cdf92312ed9d133f96fdbcda590a
Tag: v1.4.1
Tag target: 32a7fb797202cdf92312ed9d133f96fdbcda590a
Archive: gmpfrxx_mkII.1.4.1.tar.xz
Archive size: 15176064 bytes
SHA256: 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4
Changed during D01R1: NO
```

### MPLAPACK

```text
Version: 3.0.1
Tested source commit: c21a9f56224308afda9e7424ca9928d4cf840f7a
Archive: mplapack-3.0.1.tar.xz
Archive size: 85807808 bytes
SHA256: f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1
Runtime SONAME: libmplapack_mpfr.so.3
Tag: not created in this worktree
Release QA/tag owner: external MPLAPACK release maintainer
Changed during D01R1: NO; corrected candidate supplied before final QA
```

The supplied candidate includes the macOS `/bin/sh` pkg-config generation
fix, macOS QD/DD shared-library load-check fixes, Automake load-probe fix,
and external-gmpfrxx pkg-config include-path fix. It also contains the public
`mplapack_mpfr_precision.h` and generated release files. The older D00
candidate `fa3ccb4376d2a52c2672322e5b7199a9224bed7f` and SHA256
`7c8d1d7759a487bc01e8c1625599ec77b6c7e297c19b20ca45e8c342f5165e64` were
not used for the final D01R1 build. MPLAPACK release QA and release-tag
creation remain the responsibility of the release maintainer; no MPLAPACK
tag was created or modified here.

## Package identity

```text
Repository: nakatamaho/octave-mplapack
Package Name: mplapack-interop
Version before: 0.2.1-dev
Version after: 0.2.1
Freeze commit: b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6
Tag: v0.2.1
Tag target: b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6
Remote tag object: e48d6502850fce3ada5beecd9562240077414cf7
Archive: mplapack-interop-0.2.1.tar.gz
Archive size: 247628 bytes
SHA256 A: 28769e877e0588a59d9c0d6736fb875624df8b836f570cc9e87eda7d74936d0f
SHA256 B: 28769e877e0588a59d9c0d6736fb875624df8b836f570cc9e87eda7d74936d0f
Hashes identical: YES
Top-level directory: mplapack-interop-0.2.1/
Archive generated from tag: YES; hash identical to pre-tag candidate
Archive installed at: /home/docker/src/mplapack-interop-0.2.1.tar.gz
```

The package archive intentionally excludes the developer-only
`tools/install-local-octave-mplapack.sh`, which contains the local
`/home/docker` layout. The installer remains in the repository and the
standalone `/home/docker` helper; it defaults to the final archive and records
the final archive SHA256.

## Package-name preflight

```text
Octave: GNU Octave 11.1.0
Temporary package: isolated throwaway package
Name: mplapack-interop
Install: PASS
pkg list: PASS
pkg describe: PASS
pkg load: PASS
pkg unload: PASS
pkg uninstall: PASS
Hyphen supported: YES
Result: G-D01R1-NAME-SYNTAX PASS
```

## Rename diff audit

```text
DESCRIPTION: Name mplapack-interop, Version 0.2.1
README/NEWS/INDEX: updated to the renamed package identity
Help/examples/tests: updated and exercised with pkg load mplapack-interop
Release tooling: updated for the final archive and package identity
Package lifecycle: install/load/unload/uninstall/reinstall PASS
Historical D00 documentation: preserved
Internal numerical symbols: not renamed
Numerical source changed during D01R1: NO
Result: G-D01R1-RENAME PASS
```

## Migration QA

```text
Old v0.2.0 tag: unchanged
Old package source/archive: retained as historical provenance
Old unload/uninstall behavior: not changed by D01R1
New 0.2.1 install: PASS
New pkg list/describe/load: PASS
Real smoke: PASS
Complex smoke: PASS
Stale old package entry in clean package database: NO
Unload/reinstall: PASS
Result: PASS
```

## Full regression on the final candidate stack

The final `tools/local-ci.sh` run used the installed gmpfrxx 1.4.1 archive
and supplied MPLAPACK 3.0.1 candidate archive. The environment selected the
local prefix explicitly:

```text
PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:/home/docker/opt/octave-mplapack-stack/lib64/pkgconfig
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:/home/docker/opt/octave-mplapack-stack/lib64:/usr/local/lib
SOURCE_DATE_EPOCH=0
```

```text
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex Cgetrf: PASS
Compatibility firewall: PASS
1024-bit canaries: PASS
2048-bit canaries: PASS
low/high ambient precision: PASS
precision-scope restoration: PASS
operation-owned input immutability: PASS
native lifetime/shutdown tests: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
Package install/load/real smoke/complex smoke/help/examples/unload/uninstall/reinstall: PASS
Result: G-D01R1-REGRESSION PASS
```

The native tests covered real Rgemm, Rgesv, Rgels, Rgelss, Rpotrf, Rgeqrf,
Rorgqr, Rgeqp3, and Rgetrf, plus complex Cgemm, Cgesv, Cgelsy, Cpotrf,
Cgeqrf, Cungqr, Cgeqp3, and Cgetrf. The wall also checked signed-zero and
special values, mixed real/complex operands, thread/lifetime behavior,
public precision scope, shared-library relocations, and a negative dependency
diagnostic.

## Reproducibility and standalone archive

```text
Build A: PASS
Build B: PASS
File lists: identical
Top-level directory: identical
Version metadata: identical
SHA256 A/B: identical
Git metadata required: NO
Source-worktree headers required: NO
Clean extraction build: PASS
Result: G-D01R1-REPRODUCIBLE PASS
```

The final source archive is the canonical `pkg install` input and has also
been placed at `/home/docker/src/mplapack-interop-0.2.1.tar.gz`.

## Octave binary-distribution architecture audit

```text
pkg build design probe: PASS
Binary archive internal Name: mplapack-interop
Architecture-dependent path: Octave API-qualified directory
.oct location: src/__mplapack_core__.oct
Linux loader design: $ORIGIN/DT_RUNPATH
macOS loader design: @loader_path/@rpath
Windows loader design: package-local DLL directory
Production B01-B05 artifacts: NOT BUILT
Result: G-D01R1-BINARY-ARCH PASS
```

The package-local runtime layout, ABI key, relocation checks, target matrix,
and license handoff are defined in `docs/binary-distribution.md`. This
milestone freezes architecture only; it does not perform binary distribution.

## ABI compatibility key

```text
Octave: 11.1.0
Octave API: api-v61
OS: Linux
Architecture: x86_64
Compiler/toolchain: GNU C++ 15.2.0 / GNU Make
Required B01-B05 key: Octave major/minor + API + OS + architecture
Result: PASS for the audit host; target matrix handed to B01-B05
```

## Runtime dependency closure

```text
MPLAPACK runtime: libmplapack_mpfr.so.3
MPC runtime: libmpc.so.3
MPFR runtime: libmpfr.so.6
GMP runtime: libgmp.so.10
C/C++ runtimes: libstdc++.so.6, libgcc_s.so.1, libc.so.6
Octave libraries: host Octave runtime; not bundled in D01R1
gmpfrxx: header/interface dependency; no separate runtime library
Provenance: readelf/ldd and installed-prefix checks PASS
```

## Licensing inventory

```text
octave-mplapack / mplapack-interop: BSD-2-Clause
gmpfrxx_mkII: BSD-2-Clause
MPLAPACK: 2-clause BSD-style terms with original LAPACK/BLAS notices
GMP: dual GPL-2+ / LGPL-3+
MPFR: LGPL-3+
MPC: LGPL-3+
```

Detailed binary redistribution analysis remains outside D01R1 and belongs to
the later binary/package milestones.

## Binary artifact naming handoff

```text
Source: mplapack-interop-0.2.1.tar.gz
B01: mplapack-interop-0.2.1-octave11-linux-x86_64.tar.gz
B02: mplapack-interop-0.2.1-octave11-linux-aarch64.tar.gz
B03: mplapack-interop-0.2.1-octave11-macos-arm64.tar.gz
B04: mplapack-interop-0.2.1-octave11-macos-x86_64.tar.gz
B05: mplapack-interop-0.2.1-octave11-windows-x86_64.tar.gz
```

## F00 and PPA handoff

```text
Octave Packages index work: NO
PPA work: NO
Debian package: NOT CREATED
Launchpad upload: NOT PERFORMED
Recommended dependency order: gmpfrxx_mkII -> MPLAPACK -> mplapack-interop
```

## Revised release stack

```text
gmpfrxx_mkII:
    version: 1.4.1
    commit: 32a7fb797202cdf92312ed9d133f96fdbcda590a
    tag: v1.4.1
    archive: gmpfrxx_mkII.1.4.1.tar.xz
    sha256: 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4

MPLAPACK:
    version: 3.0.1
    commit: c21a9f56224308afda9e7424ca9928d4cf840f7a
    tag: external release QA/tag owner
    archive: mplapack-3.0.1.tar.xz
    sha256: f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1

mplapack-interop:
    version: 0.2.1
    commit: b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6
    tag: v0.2.1
    archive: mplapack-interop-0.2.1.tar.gz
    sha256: 28769e877e0588a59d9c0d6736fb875624df8b836f570cc9e87eda7d74936d0f
```

## Gates

```text
G-D01R1-NAME-SYNTAX: PASS
G-D01R1-DEPS: PASS
G-D01R1-RENAME: PASS
G-D01R1-IDENTITY: PASS
G-D01R1-NUMERICAL-EQUIVALENCE: PASS
G-D01R1-REGRESSION: PASS
G-D01R1-REPRODUCIBLE: PASS
G-D01R1-BINARY-ARCH: PASS
```

## Changes made during D01R1

```text
octave-mplapack:
  rename package identity mplapack -> mplapack-interop
  freeze package version 0.2.1
  add deterministic source archive/release metadata
  make Bash syntax checking follow the script shebang
  exclude the /home/docker-specific developer installer from public archives
  record the final archive checksum in the developer installer
  numerical implementation: unchanged

gmpfrxx_mkII:
  no changes

MPLAPACK:
  no changes in this worktree; external release QA/tag ownership retained
```

## Commits / push verification

```text
dd123dcb8eeeb8a1b2db33e8b4255891b2b3dcbe  Freeze package metadata
dfc23fd4cc4dec756471660936b3246600612624  Use Bash syntax checks
0354f74                               Installer defaults to frozen release
d2e0db5                               Exclude developer-only installer
b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6  Record final archive checksum
Branch pushed: topic/d01r1-0.2.1-release-freeze
Remote branch tip: b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6
Tag pushed: v0.2.1
Remote tag target: b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6
```

## Known limitations

- The MPLAPACK 3.0.1 release tag is intentionally not created or modified in
  this worktree; its release maintainer owns final MPLAPACK QA and tagging.
- No B01-B05 binary, Debian package, PPA upload, Launchpad upload, or Octave
  Packages registry submission was performed.
- If a later source-level defect is found in a frozen dependency, reopen the
  appropriate dependency freeze rather than altering this package tag.

## Next milestone

D01R1 is complete and B01-READY, but B01 is not started automatically. The
active numerical/API sequence continues with N00. Any future source-level
change to the frozen package or dependencies requires a new release-freeze
review.
