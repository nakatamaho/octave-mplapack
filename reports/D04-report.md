# D04 RESULT

## Result

```text
D04 PASS — MPLAPACK-INTEROP 0.5.0 SOURCE FROZEN
BINARY-DISTRIBUTION-READY
```

D04 froze the `mplapack-interop` 0.5.0 source stack. The package release tag
is an annotated `v0.5.0` tag whose local and remote peeled target is the
freeze commit below. The release branch and tag target were verified after
push. The GitHub Release `v0.5.0` now contains the exact source asset.

No new numerical functionality was implemented in D04. The release-only
source diff was audited against the fully tested implementation baseline
`519b57074977ef0f50af34bc9170dbdb0e90ce45`; it contains only version/release
metadata, documentation/manual generation, documentation checks, CI version
recognition, archive reproducibility/exclusion policy, and the local installer
archive-download/provenance update.

## Historical and accepted baselines

```text
immutable D03 predecessor:
  version: 0.4.0
  tag: v0.4.0
  commit: 34993eb569bfaa0d7665ae913a3a1f5a97ac2e31
  archive SHA256: 6bc87d42fbda49fa72830db34fbede7b8b9f46b7614b14dc53e7619c7781536c

T00-T14 result: ACCEPT
NEIGT00-NEIGT25 result: PASS
DOC00 result: ACCEPT
REAL_V0_1_RC_COMMIT: 0bef79cddd3fdd70abafdf38bc1a4ab492652d33
complex implementation baseline: 519b57074977ef0f50af34bc9170dbdb0e90ce45
accepted NEIGT25 tested revision: 03d1b49b3f4633602b146aa3fcde8d2bfe278e19
```

The T00–T14 reports retain their historical dependency identities. D04 uses
the official MPLAPACK 3.0.1 release described below and does not rewrite
those historical reports.

## D04 gate summary

| Gate | Result | Evidence |
|---|---|---|
| G-D04-PROVENANCE | PASS | official gmpfrxx/MPLAPACK release URLs, SHA256, sizes, tags, and standalone archive listings verified |
| G-D04-DEPENDENCY-QA | PASS | exact official MPLAPACK archive built with clean frozen dependency prefixes; gmpfrxx 192/192 and external consumers passed |
| G-D04-VERSION | PASS | authoritative package metadata changed from 0.5.0-dev to 0.5.0; user docs/manual/generated docs and release tooling synchronized |
| G-D04-REGRESSION | PASS | complete accepted wall passed on the same tested implementation/dependency stack; release-only runtime diff is empty |
| G-D04-REPRODUCIBLE | PASS | independent archive A/B, tagged-tree archive, file list, size, SHA256, and exact extraction replay agree |
| G-D04-FREEZE | PASS | freeze commit and local/remote annotated tag target are identical; no report-only commit is tagged |
| G-D04-HANDOFF | PASS | canonical dependency manifest, status, and this report are complete |

The release branch `topic/d04-0.5.0-release-freeze` and annotated tag
`v0.5.0` were pushed to `origin`. The remote tag was verified to peel to the
same `7187a0f…` freeze commit.

## gmpfrxx_mkII

```text
Repository:
  https://github.com/nakatamaho/gmpfrxx_mkII
C12/T00-T14 tested commit:
  32a7fb797202cdf92312ed9d133f96fdbcda590a
Freeze/release commit:
  32a7fb797202cdf92312ed9d133f96fdbcda590a
Version:
  1.4.1
Tag:
  v1.4.1
Tag target:
  32a7fb797202cdf92312ed9d133f96fdbcda590a
Archive:
  /home/docker/src/gmpfrxx_mkII.1.4.1.tar.xz
Archive size:
  15176064 bytes
SHA256:
  395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4
Release URL:
  https://github.com/nakatamaho/gmpfrxx_mkII/releases/download/v1.4.1/gmpfrxx_mkII.1.4.1.tar.xz
License:
  BSD 2-Clause, from the archive's LICENSE file
```

The archive was also retrieved with `curl` from the official release URL;
the downloaded size and SHA256 matched the local copy. It is a standalone
source archive with no Git metadata requirement.

The release tree was audited as an installed interface rather than assumed
to be header-only. It installs public/detail gmpfrxx headers and the
`libgmpxx_mkII_default_context_provider.so` support library; no MPLAPACK
source-tree include path was used by the clean consumer.

Clean install QA used:

```text
source: /tmp/d04-stack.byUrln/gmpfrxx-clean3-src
build:  /tmp/d04-stack.byUrln/gmpfrxx-clean3-build
install: /tmp/d04-stack.byUrln/gmpfrxx-clean3-prefix
CTest: 192/192 PASS
consumer: mpfr_class/mpc_class, explicit/default precision, copy/move,
          components, 1024-bit tail, 2048-bit tail, signed zero, Inf, NaN
scope: MPFR/MPC current-thread independence and lifetime checks PASS
```

The public contract remains one-operation/one-precision MPFR/MPC arithmetic;
there is no builtin binary64 complex fallback.

## MPLAPACK 3.0.1

```text
Repository:
  https://github.com/nakatamaho/mplapack
Release version:
  3.0.1
Release tag:
  v3.0.1
Release tag/source baseline:
  953d7a4916554546937a753a30b0619691072841
Release date:
  2026-09-15
Archive:
  /home/docker/src/mplapack-3.0.1.tar.xz
Archive size:
  85720132 bytes
SHA256:
  47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa
Release URL:
  https://github.com/nakatamaho/mplapack/releases/download/v3.0.1/mplapack-3.0.1.tar.xz
License:
  MPLAPACK 2-clause BSD-style license plus bundled LAPACK/BLAS notices
```

The earlier MPLAPACK RC artifact remains historical and is not used for this
freeze. D04 verified the official release asset with `curl`, archive size,
SHA256, one top-level directory, required generated build files, and absence
of Git metadata.

The clean build used:

```text
MPLAPACK source: exact extraction of mplapack-3.0.1.tar.xz
gmpfrxx: /tmp/d04-stack.byUrln/gmpfrxx-clean3-prefix
GMP/MPFR/MPC: clean external prefixes under /tmp/d04-stack.byUrln
backend: MPFR reference backend; optimized/OpenMP/QD/DD backends not claimed
installed prefix: /tmp/d04-stack.byUrln/mplapack-clean3-prefix
pkg-config: mplapack_mpfr = 3.0.1
public header: include/mplapack/mplapack_mpfr_precision.h
SONAME: libmplapack_mpfr.so.3
```

`mpblas.h` and `mplapack.h` are internal aggregate headers that rely on
internal `INTEGER`/`REAL` definitions and were not treated as installable
public development headers. The required public precision header was
installed and an external program including it passed:

```cpp
#include <mplapack_mpfr_precision.h>
MplapackMpfrPrecisionScope scope(p);
```

The scope establishes/restores the current-thread MPFR default precision,
supports nested same-thread temporary construction, and can be used at a
worker entry. It does not propagate parent-thread TLS state automatically to
new workers. Complex calls compose the tested MPFR/MPC scopes.

Runtime provenance from the clean installed library:

```text
NEEDED: libmpc.so.3, libmpfr.so.6, libgmp.so.10,
        libstdc++.so.6, libc.so.6, libgcc_s.so.1, loader
SONAME: libmplapack_mpfr.so.3
source-worktree path in include/libtool/runtime traces: absent
```

The external consumer covered `MplapackMpfrPrecisionScope`, Rgemm, Cgemm,
Rgesv, and Cgesv, including 1024-bit and 2048-bit cases. Real backend QA
covered Rgemm, Rgesv, Rgelss, Rpotrf, Rgeqrf/Rorgqr, Rgeqp3, and Rgetrf;
complex backend QA covered Cgemm, Cgesv, Cgelsy, Cpotrf, Cgeqrf, Cungqr,
Cgeqp3, and Cgetrf. Uniform precision, low/high ambient precision, scope
restoration, and worker-entry behavior passed in the accepted wall.

## octave-mplapack / mplapack-interop

```text
Repository:
  https://github.com/nakatamaho/octave-mplapack.git
Package name:
  mplapack-interop
C12/NEIGT tested implementation:
  519b57074977ef0f50af34bc9170dbdb0e90ce45
  (NEIGT25 isolated report revision: 03d1b49b3f4633602b146aa3fcde8d2bfe278e19)
Version before:
  0.5.0-dev
Version after:
  0.5.0
Freeze commit:
  7187a0f6c5a40a4d5774f4f913b166ccb6a5dffa
Tag:
  v0.5.0 (annotated, pushed and remotely verified)
Tag target:
  7187a0f6c5a40a4d5774f4f913b166ccb6a5dffa
Archive:
  /home/docker/src/mplapack-interop-0.5.0.tar.gz
Archive size:
  817463 bytes
SHA256 A:
  3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04
SHA256 B:
  3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04
Tagged-tree SHA256:
  3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04
License:
  BSD 2-Clause, from COPYING and LICENSE
```

The exact final archive was installed in a clean Octave package database and
replayed from extraction. The test passed version inspection, the frozen
MPLAPACK version/provenance, real solve/QR/LU, complex solve/QR/LU/Cholesky,
help lookup, uninstall, reinstall, and a second real/complex smoke. Expected
Octave function-shadow warnings for compatibility wrappers were observed;
they were not failures.

### Regression coverage

The complete accepted wall is recorded in:

```text
/tmp/d04-local-ci-final.yAROKj/local-ci.log
```

It ends with `PASS: D00 local CI` and includes:

```text
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex Cgetrf LU: PASS
N00-N08 native numerical/compatibility gates: PASS
S00-S08 script compatibility: PASS
T00-T14 advanced real API: PASS
SVT/SVD integration: PASS
NEIG06: PASS
NEIGT23/NEIGT24: PASS
package lifecycle: PASS
native ASan/UBSan/LSan wall: PASS
```

The complete NEIGT25 ordinary/V evidence is preserved in `neigt25-report.md`:

```text
ordinary smoke: 120 measured eig rows
ordinary demo: 168 measured eig rows
V smoke: 26/26 verification jobs implemented and passing
V demo: 26/26 verification jobs implemented and passing
Tier-S/Tier-A smoke split: 72/48 rows
V-S/V-A split: 16/10 jobs
```

The 26 verification statuses were replayed as follows in both V profiles:

```text
VS1-01..VS1-08: PASS
VS2-01..VS2-04: CERTIFIED_CLUSTER
VS3-01..VS3-04: PASS
VA1-01..VA1-02: CERTIFIED_SCHUR_TRIANGULAR
VA1-03:         CERTIFIED_BLOCK_SCHUR
VA2-01..VA2-03: CERTIFIED_ALL_FINITE
VA3-01..VA3-04: CERTIFIED_PERRON_PAIR
```

The NEIG evidence includes counted all-spectrum coverage, repeated/defective
and merged invariant-subspace certificates, verified pseudospectrum points
and positive-area cells, compatible eigenfactor boxes, triangular Schur for
separated simple cases, block Schur for the defective case, finite pencil
solve-reduction verification, and positive normalized left/right Perron
pairs. It does not claim diagonalizability for a defective block or exact
multiplicity from a disk count.

Required numerical evidence includes 1024-bit `2^-700`, 2048-bit `2^-1500`,
low/high ambient precision, lifetime, signed-zero/Inf/NaN, mixed real/complex,
real rank/Cholesky/QR-pivot/LU-pivot, complex scalar/Cgemm/Cgesv/Cgelsy/
Cpotrf/QR/Cgeqp3/Cgetrf, and the accepted MPFR/MPC scope contract.

### Reproducible certificates and source attribution

NEIGT25's replayable proof directory is:

```text
/tmp/neigt25-final-proof.R50XMe/replayable-proof/
schema/digest: neigt-s1-replay-v1 /
  0c4092117ddc2eb73658dbb3e61d1bfb9f2e5f4b54f0422295537d68c6e41c16
```

It separates measured MP inputs, work precision, raw solver outputs,
auxiliary candidates, and certificate targets. The proof was independently
replayed in a fresh Octave process with `mp_neig_replay` and passed. The S1
generator remains the specified Ozaki–Ogita Theorem-1 error-free triple-
product generator with its generation precision, paired-block rule,
requested/realized forms, and independent exactness checks. No MP-to-binary64
numerical fallback is used.

### Sanitizers and release-only audit

The accepted full wall reports native ASan, UBSan, and LSan PASS. The
release-only diff from `519b570...` to `7187a0...` has no changes under:

```text
src/ inst/ examples/ test/
```

Therefore the sanitizer and numerical implementation results are inherited
without changing the tested runtime implementation. The redundant second
full local-ci invocation on the metadata-only release tree was intentionally
cancelled after the user approved skipping that long duplicate wall; its
partial output is not counted as a PASS.

## Full frozen-stack rebuild

The clean stack was built in `/tmp/d04-stack.byUrln`:

```text
gmpfrxx archive only: PASS; installed cleanly, CTest 192/192
MPLAPACK archive only: PASS; exact official 3.0.1 archive, clean external deps
octave-mplapack archive only: PASS; exact final 0.5.0 archive replay
Git worktree dependency: none in final isolated replay
unfrozen header dependency: none observed
stale prefix: none selected; include/pkg-config/runtime traces audited
build: PASS
install: PASS
real smoke: PASS
complex smoke: PASS
```

The exact final package replay root was:

```text
/tmp/d04-final-archive-replay.RzpExH
```

It produced:

```text
PASS: exact D04 archive install/version/real-complex/help
PASS: exact D04 archive uninstall/reinstall
D04_EXACT_ARCHIVE_SHA256=3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04
D04_EXACT_ARCHIVE_SIZE=817463
```

## Provenance

```text
gmpfrxx archive:
  /home/docker/src/gmpfrxx_mkII.1.4.1.tar.xz
  v1.4.1 / 32a7fb797202cdf92312ed9d133f96fdbcda590a
gmpfrxx installed include:
  /tmp/d04-stack.byUrln/gmpfrxx-clean3-prefix/include
MPLAPACK source archive:
  /home/docker/src/mplapack-3.0.1.tar.xz
  v3.0.1 / 953d7a4916554546937a753a30b0619691072841
MPLAPACK installed include:
  /tmp/d04-stack.byUrln/mplapack-clean3-prefix/include/mplapack
MPLAPACK pkg-config:
  /tmp/d04-stack.byUrln/mplapack-clean3-prefix/lib/pkgconfig/mplapack_mpfr.pc
MPLAPACK runtime:
  libmplapack_mpfr.so.3
MPFR runtime: libmpfr.so.6
MPC runtime: libmpc.so.3
GMP runtime: libgmp.so.10
development path leakage: absent in clean dependency traces
```

The exact dependency graph is:

```text
mplapack-interop 0.5.0
    requires MPLAPACK 3.0.1
        requires gmpfrxx_mkII 1.4.1
            requires GMP / MPFR / MPC
```

GMP, MPFR, and MPC are build/header prerequisites and runtime shared-library
dependencies of the MPFR MPLAPACK backend. The package also requires GNU
Octave and its development/build prerequisites. The D04 stack does not claim
to freeze host compiler, Octave, or system-library release artifacts; the
tested environment was x86_64 Linux, GNU Octave 11.1.0, GCC/G++ 15.2,
GMP 6.3.0, MPFR 4.2.2, and MPC 1.4.1.

## Source archive reproducibility

The release helper used deterministic timestamps and sorted ustar entries.
The two independent builds and tagged-tree archive agree:

| Artifact | Size | SHA256 A | SHA256 B | Tagged-tree match |
|---|---:|---|---|---|
| `gmpfrxx_mkII.1.4.1.tar.xz` | 15176064 | `395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4` | `395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4` | official release asset |
| `mplapack-3.0.1.tar.xz` | 85720132 | `47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa` | `47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa` | official release asset |
| `mplapack-interop-0.5.0.tar.gz` | 817463 | `3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04` | `3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04` | exact match |

The package archive has one top-level directory and excludes `.git`, build
products, private prefixes, reports, D04 controller/status, the dependency
manifest, and the local installer. The report/status/manifest remain in the
repository for D01 handoff and are deliberately not self-included in the
release artifact.

## Licenses and provenance metadata

```text
gmpfrxx_mkII 1.4.1: BSD 2-Clause, archive LICENSE
MPLAPACK 3.0.1: MPLAPACK 2-clause BSD-style license plus bundled
                LAPACK/BLAS notices, archive COPYING
mplapack-interop 0.5.0: BSD 2-Clause, archive COPYING and LICENSE
GMP 6.3.0: GNU GPL/LGPL source license files with the GMP special exception
MPFR 4.2.2: GNU LGPL v3 source license files
MPC 1.4.1: GNU LGPL v3 source license files and exception text
```

D01 owns binary-distribution legal analysis and package-local redistribution
details; D04 records source license/provenance facts only.

## Upstream changes made during D04

```text
gmpfrxx_mkII: none
MPLAPACK: none; official v3.0.1 release archive/tag consumed as supplied
octave-mplapack:
  - release metadata 0.5.0 and release date
  - NEWS/README/Texinfo/Markdown/Doxygen release documentation
  - deterministic source-package exclusions and SHA256 checks
  - curl retrieval and exact provenance checks in the local installer
  - accepted 0.5.0 version recognition in local CI
```

No dependency headers, MPLAPACK implementation, installed `mp` methods,
compiler semantics, or public numerical API were modified in D04. The final
runtime implementation remains the tested T00–T14/NEIGT line.

## Known limitations and NOT_RUN items

```text
remote v0.5.0 tag push/remote target verification: PASS
GitHub Release `v0.5.0` with `mplapack-interop-0.5.0.tar.gz`: PASS
full duplicate local-ci after release-only metadata: NOT RUN; user-approved skip
NEIGT25 opt-in stress: NOT RUN
NEIGT25 plotting: NOT RUN; headless plot=false gate PASS
TeX/PDF manual output: NOT RUN; no working TeX toolchain
binary artifacts, Debian, Launchpad/PPA, Octave Packages registry: NOT RUN by scope
```

The expected Octave compatibility-wrapper shadow warnings remain visible when
loading the package. They are documented package behavior and did not fail
the lifecycle or numerical gates.

## Release-stack manifest

File:

```text
docs/dependency-release-stack-r1.md
```

The manifest is complete and D01-usable. It gives the exact versions,
commits, tags, archive names, sizes, SHA256 values, licenses, dependency
order, runtime SONAME, precision-scope contract, and the no-automatic-TLS-
propagation rule. The manifest and D04 report are excluded from the public
source archive to avoid self-referential release metadata.

## Frozen stack

```text
gmpfrxx_mkII:
    version: 1.4.1
    commit: 32a7fb797202cdf92312ed9d133f96fdbcda590a
    tag: v1.4.1
    archive: gmpfrxx_mkII.1.4.1.tar.xz
    sha256: 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4

MPLAPACK:
    version: 3.0.1
    commit: 953d7a4916554546937a753a30b0619691072841
    tag: v3.0.1
    archive: mplapack-3.0.1.tar.xz
    sha256: 47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa

octave-mplapack / mplapack-interop:
    version: 0.5.0
    commit: 7187a0f6c5a40a4d5774f4f913b166ccb6a5dffa
    tag: v0.5.0 (annotated, pushed and remotely verified)
    archive: mplapack-interop-0.5.0.tar.gz
    sha256: 3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04
```

## Next milestone

The next milestone is:

```text
D01 — Octave Binary Distribution Architecture
```

D01 must consume exactly the frozen versions/commits/tags/archives/SHA256
recorded above. It must not modify frozen numerical source. If D01 discovers
a source-level defect, reopen the freeze as D04R1 rather than editing the
frozen release silently.

No D01 work was started automatically.
