# D00 RESULT

## Result

All D00 gates PASS. The source freeze, reproducible archives, remote tags,
and handoff metadata are complete; no numerical implementation is pending.

Release conclusion:

`D00 PASS — RELEASE STACK FROZEN`

D01 readiness:

`D01-READY`

## Historical checkpoint

REAL_V0_1_RC_COMMIT:
`0bef79cddd3fdd70abafdf38bc1a4ab492652d33`

REAL_V0_1_ARCHIVE:
`mplapack-0.1.0.tar.gz`, top-level directory `mplapack-0.1.0/`.

REAL_V0_1_SHA256:
`35d004adf831c79fe470ff890ce3698dfe7e6f624ea31c174b1d60a03d110db6`
(size `161819` bytes; two historical builds matched).

## C12 baseline

COMPLEX_FINAL_COMMIT:
`36cd341a8c14ce2d0a6790b287e5f7a7b0846cd3`

C12 result:
`COMPLEX GOAL PASS`, `REAL-COMPLEX-API-CLOSED`,
`DEPENDENCY-FREEZE-READY`

## gmpfrxx_mkII

Repository: `github.com/nakatamaho/gmpfrxx_mkII`

C12 tested commit: `32a7fb797202cdf92312ed9d133f96fdbcda590a`

Freeze commit: `32a7fb797202cdf92312ed9d133f96fdbcda590a`

Version: `1.4.1`

Tag: `v1.4.1` (existing annotated tag)

Tag target: `v1.4.1^{}` = `32a7fb797202cdf92312ed9d133f96fdbcda590a`

Archive: `/home/docker/work/d00-release-artifacts/gmpfrxx_mkII.1.4.1.tar.xz`

Archive size: `15176072` bytes

SHA256 A: `93fbf257ab3c3e00342109fea9096f43cf32e29fd1b7dbafd91f8e23f81b3890`

SHA256 B: `93fbf257ab3c3e00342109fea9096f43cf32e29fd1b7dbafd91f8e23f81b3890`

Hashes identical: `PASS`

License: BSD 2-Clause (`LICENSE`)

Installed headers: four top-level public headers plus public/detail headers
under `include/gmpfrxx_mkII/`.

Libraries: `libgmpxx_mkII_default_context_provider.so`, SONAME
`libgmpxx_mkII_default_context_provider.so`; numerical wrapper is header-only.

pkg-config: none installed.

CMake metadata: installed under `lib/cmake/gmpfrxx_mkII/`, including config,
version, imported targets, and GMP/MPFR/MPC find modules.

GMP dependency: build/header dependency; raw GMP MPF default is process-global.

MPFR dependency: build/header dependency; MPFR TLS behavior was detected and
validated by the standalone tests.

MPC dependency: build/header dependency; this host has no MPC TLS API, so the
tested MPC environment policy is used rather than an invented TLS path.

Standalone consumer: PASS. Construction/copy/move, `mpfr_class`, `mpc_class`,
explicit/default precision, component access, special values, source-worktree
exclusion, and installed-interface linking all passed.

1024: PASS, including precision-tail and thread/default probes.

2048: PASS, including precision-tail and thread/default probes.

TLS/MPC probe: PASS for the supported MPFR TLS and MPC environment contract;
no MPC TLS was claimed. CTest: 156/156 PASS.

Result: `G-D00-GMPFRXX PASS`

## MPLAPACK

Repository: `github.com/nakatamaho/mplapack`

C12 tested commit: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`

C12 tested branch: `topic/octave-mplapack-complex-mpfr-scope`

Freeze commit: `fa3ccb4376d2a52c2672322e5b7199a9224bed7f`

Version: `3.0.1`

Tag: `v3.0.1`; existing repository convention is lightweight `v3.0.0` tags.

Tag target: `fa3ccb4376d2a52c2672322e5b7199a9224bed7f`; remote target verified.

Release branch: `topic/d00-3.0.1-release-freeze`, with the C12 topic work
merged into `master` at `e6e1bcbf9513e9de47cb6c70afbd791e30868aae` and the
release-line fixes applied normally on the D00 branch.

C12 topic integration: PASS; `mplapack_mpfr_precision.h` and
`MplapackMpfrPrecisionScope` remain present and installed publicly.

Tree/diff audit: PASS. Differences from the C12 integration are limited to
the frozen gmpfrxx 1.4.1 bundled-source alignment, deterministic archive
metadata, generated gmpfrxx `Makefile.in` inclusion, and external gmpfrxx
include flags in pkg-config. No numerical source changed. The temporary
public installation of internal `mpblas.h`/`mplapack.h` was force-removed and
is absent from the release branch.

gmpfrxx dependency: frozen `gmpfrxx_mkII` 1.4.1, commit
`32a7fb797202cdf92312ed9d133f96fdbcda590a`; bundled archive is also 1.4.1.

gmpfrxx provenance: PASS. Archive-only extraction configured against the
isolated gmpfrxx prefix; `mplapack_mpfr.pc` exports that include path; clean
consumer dependency/CFLAGS evidence contains no MPLAPACK source-worktree
include.

Required header: `mplapack_mpfr_precision.h`, installed under
`include/mplapack/`; `#include <mplapack_mpfr_precision.h>` and
`MplapackMpfrPrecisionScope scope(p)` compile/run from the installed prefix.

Required scope: establishes/restores current-thread MPFR default precision;
supports same-thread nested temporaries and worker-entry setup; does not
propagate parent-thread TLS into new workers. Complex calls compose the
tested MPFR/MPC scope behavior.

pkg-config: `mplapack_mpfr`, version `3.0.1`; `mplapack_mpfr_opt` is also
installed. Internal `mpblas.h` and `mplapack.h` are not installed.

Runtime SONAME: `libmplapack_mpfr.so.3`

Other runtime libraries: `libmpc.so.3`, `libmpfr.so.6`, `libgmp.so.10`, and
normal C++/C runtime libraries. The validated Octave module uses the MPFR
reference backend and does not link `libmplapack_mpfr_opt`.

Real backend QA: PASS for Rgemm, Rgesv, Rgels, Rgelss, Rgelsd, Rpotrf,
Rgeqrf/Rorgqr, Rgeqp3, Rgetrf, uniform scope, ambient precision, restoration,
and 1024/2048 canaries.

Complex backend QA: PASS for Cgemm, Cgesv, Cgelsy/Cgelss/Cgelsd, Cpotrf,
Cgeqrf/Cungqr, Cgeqp3, Cgetrf, precision boundaries, ambient scope, and
immutability. Optimized complex support is not claimed beyond the validated
reference configuration.

1024: PASS, including real and complex high-precision canaries.

2048: PASS, including real and complex high-precision canaries.

Thread/worker audit: reference backend validated; MPFR scope is explicit at
call/worker entry; no automatic parent-to-worker TLS propagation is claimed;
optimized complex backend is not enabled in the Octave release validation.

External consumer: PASS for installed Rgemm, Cgemm, Rgesv, Cgesv, and the
precision scope. Source probes using internal aggregate headers were filtered
to the installed public interface for this boundary test.

Archive: `/home/docker/work/d00-release-artifacts/mplapack-3.0.1.tar.xz`

Archive size: `86024224` bytes

SHA256 A: `7c8d1d7759a487bc01e8c1625599ec77b6c7e297c19b20ca45e8c342f5165e64`

SHA256 B: `7c8d1d7759a487bc01e8c1625599ec77b6c7e297c19b20ca45e8c342f5165e64`

Hashes identical: `PASS`

License: 2-clause BSD-style terms in `COPYING`, plus original LAPACK/BLAS
notices.

Result: `G-D00-MPLAPACK PASS`

## octave-mplapack

Repository: `github.com/nakatamaho/octave-mplapack`

C12 tested implementation: `36cd341a8c14ce2d0a6790b287e5f7a7b0846cd3`

Freeze commit: `4a3eb50843a6bf365bdab1e82146ef1900a219f6`

Version before: `0.2.0-dev`

Version after: `0.2.0`

Tag: `v0.2.0` annotated; no earlier release-tag convention existed.

Tag target: `4a3eb50843a6bf365bdab1e82146ef1900a219f6`; remote dereference
verified. The annotated tag object is `91d9b53f279d45b763bfcc3ea1fb019efa457818`.

Minimum Octave: `11.1.0` from `DESCRIPTION`.

gmpfrxx dependency: frozen 1.4.1, commit
`32a7fb797202cdf92312ed9d133f96fdbcda590a`.

MPLAPACK dependency: frozen 3.0.1, commit
`fa3ccb4376d2a52c2672322e5b7199a9224bed7f`, `pkg-config mplapack_mpfr`
version 3.0.1, runtime `libmplapack_mpfr.so.3`.

M00-M23 real regression: PASS. This includes real storage, arithmetic,
matrix, BLAS/LAPACK, inspection, structure, concatenation, assignment,
Rgemm, Rgesv, Rgels/Rgelss/Rgelsd, Rpotrf, Rgeqrf/Rorgqr, Rgeqp3, Rgetrf,
lifecycle, and release closure.

C00-C12 complex regression: PASS for complex storage, scalar/matrix,
structure, elementwise, Cgemm, Cgesv, rank-revealing solves, Cpotrf,
Cgeqrf/Cungqr, Cgeqp3, mixed real/complex closure, and compatibility firewall.

C11L: PASS for complex `Cgetrf`, rectangular/singular/pivot behavior,
source-precision pivots, ambient scope, immutability, and lifetime.

Compatibility firewall: PASS; real-only APIs remain real-only and no builtin
binary64 complex fallback is used.

1024: PASS, including `2^-700` real/complex canaries and ambient-precision
checks.

2048: PASS, including `2^-1500` real/complex canaries and ambient-precision
checks.

ASan: PASS.

UBSan: PASS.

LSan: PASS through `ASAN_OPTIONS=detect_leaks=1:halt_on_error=1` with the
accepted native suite.

Package lifecycle: PASS from the final archive in a clean HOME: install,
`pkg load`, real/complex smoke, all M/C test files, help, examples, unload,
uninstall, post-uninstall visibility, reinstall, and second smoke.

Archive: `/home/docker/work/d00-release-artifacts/mplapack-0.2.0.tar.gz`

Archive size: `231432` bytes

SHA256 A: `0e83e26182b0fbd95a064437a97307eb74d9291b49d91c6e53dac181b24a94db`

SHA256 B: `0e83e26182b0fbd95a064437a97307eb74d9291b49d91c6e53dac181b24a94db`

Hashes identical: `PASS`

License: BSD 2-Clause (`COPYING`, `LICENSE`)

Result: `G-D00-OCTAVE PASS`

## Full frozen-stack rebuild

gmpfrxx archive only: PASS; extracted `gmpfrxx_mkII.1.4.1.tar.xz`, clean
CMake build/install, 156/156 CTest.

MPLAPACK archive only: PASS; extracted `mplapack-3.0.1.tar.xz`, configured,
built, and installed against only the isolated gmpfrxx archive install and
normal GMP/MPFR/MPC prerequisites.

octave-mplapack archive only: PASS; extracted `mplapack-0.2.0.tar.gz`, built
and tested against only the two frozen dependency prefixes.

Git worktree dependency: `NONE`.

Unfrozen header dependency: `NONE` for gmpfrxx/MPLAPACK/octave layers; normal
system GMP/MPFR/MPC/Octave headers are recorded prerequisites.

Stale prefix: `NONE`; runtime and compile paths were isolated to the recorded
gmpfrxx/MPLAPACK prefixes plus normal system prerequisite paths.

Build: PASS.

Install: PASS.

Real smoke: PASS.

Complex smoke: PASS, including Cgemm/Cgesv/Cgetrf.

Result: `G-D00-STACK PASS`

## Provenance

gmpfrxx include path: `/tmp/d00-stack-gmpfrxx.FQtAwP/prefix/include`

MPLAPACK include path: `/tmp/d00-stack-mplapack.Fdfc6f/prefix/include/mplapack`

MPLAPACK pkg-config path: `/tmp/d00-stack-mplapack.Fdfc6f/prefix/lib/pkgconfig`

MPLAPACK runtime path: `/tmp/d00-stack-mplapack.Fdfc6f/prefix/lib`

libmplapack_mpfr SONAME: `libmplapack_mpfr.so.3`

MPFR runtime: `libmpfr.so.6`, version 4.2.2

MPC runtime: `libmpc.so.3`, version 1.4.1

GMP runtime: `libgmp.so.10`, version 6.3.0

Development path leakage: PASS; compiler flags, pkg-config output,
dependency/runtime inspection, and archive extraction showed no development
worktree use. The configured frozen prefix is intentionally visible in the
recorded pkg-config metadata and is not a hidden dependency.

Result: `G-D00-PROVENANCE PASS`

## Release-stack manifest

File: [`docs/dependency-release-stack.md`](../docs/dependency-release-stack.md)

Complete: PASS for versions, source commits, archive names, sizes, SHA256,
dependencies, public interface, SONAMEs, licenses, historical provenance, and
tested toolchain.

D01 usable: PASS; no repository archaeology is required to consume the
frozen versions, commits, tags, archives, hashes, licenses, SONAMEs, or tested
dependency order.

## Reproducibility

```text
gmpfrxx A == gmpfrxx B: PASS
MPLAPACK A == MPLAPACK B: PASS
octave-mplapack A == octave-mplapack B: PASS
```

All archives have one expected top-level directory, identical A/B file lists,
no `.git`, no private build products, and no developer-path-only files.

## Gates

G-D00-GMPFRXX: `PASS`

G-D00-MPLAPACK: `PASS`

G-D00-OCTAVE: `PASS`

G-D00-STACK: `PASS`

G-D00-PROVENANCE: `PASS`

G-D00-REPRODUCIBLE: `PASS`

G-D00-TAGS: `PASS`

G-D00-HANDOFF: `PASS`

## Upstream changes made during D00

gmpfrxx_mkII:

- No source changes. Existing v1.4.1 commit/tag was independently audited.

MPLAPACK:

- `85b581ea0c9183cdbaf44d34eb48d7cc8eb3dcb2` — align bundled gmpfrxx with
  1.4.1.
- `f4e5818135dada8c6ef0a7f11954c53f11f4202a` — reproducible source archives.
- `3786c35a825ae3927b8621bed380e14877d17912` — include generated gmpfrxx
  `Makefile.in` in standalone archives.
- `fa3ccb4376d2a52c2672322e5b7199a9224bed7f` — export external gmpfrxx
  headers in MPFR pkg-config.
- No numerical implementation change; internal aggregate headers remain
  uninstalled.

octave-mplapack:

- `54bd7b33186da7a4f01f69bb4e3828971db7e588` — prepare 0.2.0 release
  metadata and D00 controller.
- `739b3e9b9c09456676a7574bf65c30d837b78a72` — record D00-M release defect
  audit.
- `1042395` — record D00-M freeze gate.
- `4a3eb50843a6bf365bdab1e82146ef1900a219f6` — align local CI with the
  0.2.0 complex release; update the release QA wall and use public MPLAPACK
  headers for external probes.

## Known limitations

- The validated host has MPFR TLS support but no MPC TLS API. The frozen
  contract therefore uses explicit MPFR scope and MPC environment semantics;
  no automatic MPC TLS or parent-to-worker propagation is claimed.
- gmpfrxx documentation contains two historical statements describing raw GMP
  MPF defaults as thread-local; source behavior and release contract correctly
  identify the raw GMP default as process-global. This is recorded and does
  not affect the validated MPFR/MPC paths.
- The D00 artifact paths are local verification paths. D01 owns public mirror
  or binary-distribution placement.

## Environment

```text
OS/kernel: Ubuntu host, Linux 6.8.0-138-generic
Architecture: x86_64
Compiler: g++ 15.2.0-16ubuntu1
Octave: 11.1.0
GMP: 6.3.0
MPFR: 4.2.2
MPC: 1.4.1
```

## Next milestone

Final D00 conclusion:

`D00 PASS — RELEASE STACK FROZEN`

`D01-READY`

`D01-READY`; D01 is a separate goal and is not started automatically. Do not
modify frozen numerical source in D01. If D01 finds a source-level defect,
reopen the freeze as D00R1.
