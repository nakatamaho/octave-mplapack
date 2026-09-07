# D01R1 forward dependency and package stack

This is the forward-looking handoff for the renamed GNU Octave package. The
historical D00 manifest remains authoritative for the old `mplapack` 0.2.0
identity and is not rewritten.

## Identity table

| Layer | Version | Commit | Tag | Archive | SHA256 | Status |
|---|---:|---|---|---|---|---|
| gmpfrxx_mkII | 1.4.1 | `32a7fb797202cdf92312ed9d133f96fdbcda590a` | `v1.4.1` | `gmpfrxx_mkII.1.4.1.tar.xz` | `395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4` | unchanged from D00 |
| MPLAPACK | 3.0.1 | `c21a9f56224308afda9e7424ca9928d4cf840f7a` | pending release-tag revalidation | `mplapack-3.0.1.tar.xz` | `f0ff9ff1ceeccc1a24ceb16973508ea9d8cf6f7bfad8cc3b84109c9da720a7b3` | supplied RC, 85591016 bytes; generated Makefile.in still needs the pkg-config fix; release QA maintained separately |
| octave-mplapack | 0.2.1-dev | pending | pending | `mplapack-interop-0.2.1-dev.tar.gz` | pending | D01R1 worktree |

The supplied MPLAPACK RC includes the macOS `/bin/sh`, QD/DD load-check,
Automake load-probe, and `Makefile.am` external-gmpfrxx pkg-config fixes. It
differs from the older D00 candidate (`fa3ccb...`, SHA256 `7c8d1d...`). The
archive's generated `Makefile.in` was audited and does not yet contain the
MPFR-branch `GMP_PC_CFLAGS` assignment, so the archive can still omit the
installed gmpfrxx include directory when built without autoreconf. It is not a
final archive until that generated-file mismatch is repaired and the separate
MPLAPACK release QA accepts the result.

## Historical D00 package

```text
Name: mplapack
Version: 0.2.0
Commit: 4a3eb50843a6bf365bdab1e82146ef1900a219f6
Tag: v0.2.0
Archive: mplapack-0.2.0.tar.gz
SHA256: 0e83e26182b0fbd95a064437a97307eb74d9291b49d91c6e53dac181b24a94db
```

This identity is retained as provenance only. It is not an alias package for
`mplapack-interop`.

## Forward dependency graph

```text
mplapack-interop 0.2.1
    requires
MPLAPACK 3.0.1 / mplapack_mpfr
    requires
gmpfrxx_mkII 1.4.1
    requires
GMP / MPFR / MPC
```

The Octave package uses the MPLAPACK `mplapack_mpfr` pkg-config interface and
the public `mpblas_mpfr.h`, `mplapack_mpfr.h`, and
`mplapack_mpfr_precision.h` headers. Internal aggregate headers `mpblas.h`
and `mplapack.h`, which rely on internal `INTEGER`/`REAL` definitions, are not
installed as public development headers.

## Freeze procedure

The final D01R1 row for `octave-mplapack` is filled only after the renamed
source is set to `Name: mplapack-interop`, `Version: 0.2.1`, its archive is
reproduced byte-identically, and tag `v0.2.1` points at that exact source
freeze commit. The final MPLAPACK row must likewise identify the exact
release tag and archive used by the full regression.
