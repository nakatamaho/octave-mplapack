# D00 dependency release freeze status

Controller: [`D00-dependency-release-freeze.md`](D00-dependency-release-freeze.md)

## Current state

Current substage: `D00-H` handoff gate

Last completed substage: `D00-T` release tags

Overall result: `D00 PASS — RELEASE STACK FROZEN`

The source freeze identities, reproducible archives, and remote release tags
are fixed and verified. The handoff manifest and final report are complete.

## Substage record

| Substage | Result | Evidence |
|---|---|---|
| D00-G gmpfrxx_mkII | PASS | Version 1.4.1, existing tag `v1.4.1`, commit `32a7fb797202cdf92312ed9d133f96fdbcda590a`, clean install, 156/156 CTest, scalar/precision/TLS/MPC probes, reproducible standalone archive |
| D00-M MPLAPACK 3.0.1 | PASS | Freeze `fa3ccb4376d2a52c2672322e5b7199a9224bed7f`; C12 scope work retained; archive-only build against frozen gmpfrxx; public precision header and external consumers pass; archive SHA256 `7c8d1d7759a487bc01e8c1625599ec77b6c7e297c19b20ca45e8c342f5165e64` |
| D00-O octave-mplapack 0.2.0 | PASS | Source freeze `4a3eb50843a6bf365bdab1e82146ef1900a219f6`; version 0.2.0; release QA script corrected for complex/public-header coverage; source archive SHA256 `0e83e26182b0fbd95a064437a97307eb74d9291b49d91c6e53dac181b24a94db` |
| D00-S frozen-stack rebuild | PASS | Three-layer rebuild from source archives only; clean Octave archive build/install; M00-M23 real wall, C00-C12 complex wall, C11L, sanitizer wall, and package lifecycle pass |
| D00-R reproducibility | PASS | gmpfrxx A/B, MPLAPACK A/B, and octave-mplapack A/B source archives have identical SHA256 and identical file lists/top-level directory |
| D00-T tags | PASS | MPLAPACK `v3.0.1` and octave-mplapack `v0.2.0` pushed and verified against their exact freeze commits |
| D00-H handoff | PASS | Final manifest and report contain versions, commits, tags, archives, hashes, sizes, licenses, dependency graph, SONAMEs, and regression evidence |

## Frozen identities

```text
GMPFRXX_C12_TESTED_COMMIT=32a7fb797202cdf92312ed9d133f96fdbcda590a
GMPFRXX_FREEZE_COMMIT=32a7fb797202cdf92312ed9d133f96fdbcda590a
GMPFRXX_RELEASE_VERSION=1.4.1
GMPFRXX_RELEASE_TAG=v1.4.1
GMPFRXX_ARCHIVE=gmpfrxx_mkII.1.4.1.tar.xz
GMPFRXX_ARCHIVE_SIZE=15176072
GMPFRXX_SHA256=93fbf257ab3c3e00342109fea9096f43cf32e29fd1b7dbafd91f8e23f81b3890

MPLAPACK_C12_TESTED_COMMIT=a59e5a0a429b05e8f07cf7a8feab1f48aef7431d
MPLAPACK_C12_INTEGRATION_COMMIT=e6e1bcbf9513e9de47cb6c70afbd791e30868aae
MPLAPACK_FREEZE_COMMIT=fa3ccb4376d2a52c2672322e5b7199a9224bed7f
MPLAPACK_RELEASE_VERSION=3.0.1
MPLAPACK_RELEASE_TAG=v3.0.1
MPLAPACK_ARCHIVE=mplapack-3.0.1.tar.xz
MPLAPACK_ARCHIVE_SIZE=86024224
MPLAPACK_SHA256=7c8d1d7759a487bc01e8c1625599ec77b6c7e297c19b20ca45e8c342f5165e64

OCTAVE_MPLAPACK_C12_TESTED_COMMIT=36cd341a8c14ce2d0a6790b287e5f7a7b0846cd3
OCTAVE_MPLAPACK_FREEZE_COMMIT=4a3eb50843a6bf365bdab1e82146ef1900a219f6
OCTAVE_MPLAPACK_RELEASE_VERSION=0.2.0
OCTAVE_MPLAPACK_RELEASE_TAG=v0.2.0
OCTAVE_MPLAPACK_ARCHIVE=mplapack-0.2.0.tar.gz
OCTAVE_MPLAPACK_ARCHIVE_SIZE=231432
OCTAVE_MPLAPACK_SHA256=0e83e26182b0fbd95a064437a97307eb74d9291b49d91c6e53dac181b24a94db
```

## D00-M defect audit

The D00-M release-line audit found four release-blocking defects. They were
fixed without changing numerical algorithms:

1. The bundled gmpfrxx source was 1.4.0 instead of the frozen 1.4.1 source:
   `85b581ea0c9183cdbaf44d34eb48d7cc8eb3dcb2`.
2. `make dist` emitted nondeterministic PAX atime/ctime metadata:
   `f4e5818135dada8c6ef0a7f11954c53f11f4202a`.
3. The standalone archive omitted generated gmpfrxx `Makefile.in` and could
   not configure after extraction:
   `3786c35a825ae3927b8621bed380e14877d17912`.
4. External gmpfrxx include flags were missing from `mplapack_mpfr.pc`:
   `fa3ccb4376d2a52c2672322e5b7199a9224bed7f`.

`mpblas.h` and `mplapack.h` are internal aggregate headers. They use internal
`INTEGER`/`REAL` definitions and are intentionally not installed. A temporary
attempt to promote them was removed from the D00 branch by force-push and is
not part of the release tree. The external M20/M21 probes were validated
through the installed public backend headers instead.

## Policy confirmations

- The gmpfrxx raw GMP `mpf` default remains process-global; this is not
  represented as TLS. MPFR thread-local behavior and MPC environment behavior
  remain separate and are tested as such.
- The MPLAPACK public scope establishes/restores current-thread MPFR default
  precision, supports nested same-thread temporary construction, and can be
  used at worker entry. It does not propagate parent-thread TLS state into new
  workers.
- No builtin binary64 complex fallback was used or added.
- Existing real-only operations were not routed through complex kernels.
- No Debian package, Launchpad upload, PPA change, release tag outside D00-T,
  or D01 work was performed.
