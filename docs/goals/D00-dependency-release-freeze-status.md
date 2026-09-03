# D00 dependency release freeze status

Controller: [`D00-dependency-release-freeze.md`](D00-dependency-release-freeze.md)

## Current state

Current substage: `D00-O` octave-mplapack 0.2.0 freeze

Last completed substage: `D00-M`

Overall result: `IN PROGRESS`

## Substage record

| Substage | Result | Evidence |
|---|---|---|
| D00-G gmpfrxx_mkII | PASS | v1.4.1, commit `32a7fb797202cdf92312ed9d133f96fdbcda590a`, clean install, 156 CTest cases, standalone scalar/precision/TLS probes, reproducible archive |
| D00-M MPLAPACK 3.0.1 | PASS | Candidate `fa3ccb4376d2a52c2672322e5b7199a9224bed7f`; public scope/backend consumers pass, archive-only configure/build/install pass, `mplapack_mpfr.pc` exports frozen gmpfrxx include flags, archive size `86024224`, SHA256 `7c8d1d7759a487bc01e8c1625599ec77b6c7e297c19b20ca45e8c342f5165e64` reproduced by A/B |
| D00-O octave-mplapack 0.2.0 | PENDING | — |
| D00-S frozen-stack rebuild | PENDING | — |
| D00-R reproducibility | PENDING | — |
| D00-T tags | PENDING | — |
| D00-H handoff | PENDING | — |

## Current identities

```text
GMPFRXX_C12_TESTED_COMMIT=32a7fb797202cdf92312ed9d133f96fdbcda590a
GMPFRXX_FREEZE_COMMIT=32a7fb797202cdf92312ed9d133f96fdbcda590a
GMPFRXX_RELEASE_VERSION=1.4.1
GMPFRXX_RELEASE_TAG=v1.4.1

MPLAPACK_C12_TESTED_COMMIT=a59e5a0a429b05e8f07cf7a8feab1f48aef7431d
MPLAPACK_C12_INTEGRATION_COMMIT=e6e1bcbf9513e9de47cb6c70afbd791e30868aae
MPLAPACK_FREEZE_COMMIT=fa3ccb4376d2a52c2672322e5b7199a9224bed7f
MPLAPACK_RELEASE_VERSION=3.0.1
MPLAPACK_RELEASE_TAG=not created before D00-T

OCTAVE_MPLAPACK_C12_TESTED_COMMIT=36cd341a8c14ce2d0a6790b287e5f7a7b0846cd3
OCTAVE_MPLAPACK_FREEZE_COMMIT=pending
OCTAVE_MPLAPACK_RELEASE_VERSION=0.2.0
OCTAVE_MPLAPACK_RELEASE_TAG=not created before D00-T
```

## D00 policy notes

- The gmpfrxx implementation was not modified. Its raw GMP `mpf` default is
  process-global; gmpfrxx's MPFR thread-scope behavior and MPC component
  behavior are kept distinct from that raw API.
- MPLAPACK D00 release fixes are limited to frozen gmpfrxx 1.4.1 provenance,
  generated-file inclusion in standalone archives, and deterministic tar
  metadata plus external gmpfrxx include flags in the MPFR pkg-config
  interface. No numerical source was changed.
- `mpblas.h` and `mplapack.h` remain internal aggregate headers because they
  depend on internal `INTEGER`/`REAL` definitions and are not public install
  targets. An attempted temporary promotion of those headers was removed from
  the D00 branch history by force-push; it is not a release fix.
- The original external probes `m20_complex_probe.cc` and
  `m21_rgetrf_probe.cc` included those internal aggregate headers and therefore
  produced a false installed-interface failure. Temporary copies using only
  the public MPFR backend headers were rebuilt and passed; the source probes
  were not changed.
- D00-M release defect fixes were audited as: bundled gmpfrxx 1.4.0 mismatch,
  nondeterministic archive PAX timestamps, missing generated gmpfrxx
  `Makefile.in`, and missing external gmpfrxx include flags in the MPFR
  pkg-config modules. The four fixes are commits
  `85b581ea0c9183cdbaf44d34eb48d7cc8eb3dcb2`,
  `f4e5818135dada8c6ef0a7f11954c53f11f4202a`,
  `3786c35a825ae3927b8621bed380e14877d17912`, and
  `fa3ccb4376d2a52c2672322e5b7199a9224bed7f`.
- `octave-mplapack-ppa` is untouched. No Debian package or Launchpad upload is
  part of D00.
