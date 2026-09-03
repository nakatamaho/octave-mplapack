# D00 dependency release freeze status

Controller: [`D00-dependency-release-freeze.md`](D00-dependency-release-freeze.md)

## Current state

Current substage: `D00-M` release archive revalidation after scope correction

Last completed substage: `D00-G`

Overall result: `IN PROGRESS`

## Substage record

| Substage | Result | Evidence |
|---|---|---|
| D00-G gmpfrxx_mkII | PASS | v1.4.1, commit `32a7fb797202cdf92312ed9d133f96fdbcda590a`, clean install, 156 CTest cases, standalone scalar/precision/TLS probes, reproducible archive |
| D00-M MPLAPACK 3.0.1 | IN PROGRESS | C12 scope integration, 1.4.1 provenance, deterministic tar metadata, generated gmpfrxx `Makefile.in`, and external gmpfrxx include flags repaired; current candidate `fa3ccb4376d2a52c2672322e5b7199a9224bed7f` is pushed |
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
- `octave-mplapack-ppa` is untouched. No Debian package or Launchpad upload is
  part of D00.
