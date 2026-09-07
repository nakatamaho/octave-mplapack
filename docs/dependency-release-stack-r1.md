# D01R1 forward dependency and package stack

This is the forward handoff for the renamed GNU Octave package. The
historical D00 manifest remains authoritative for the old `mplapack` 0.2.0
identity and is not rewritten.

## Identity table

| Layer | Version | Exact source identity | Tag | Archive | SHA256 | Size | Status |
|---|---:|---|---|---|---|---:|---|
| gmpfrxx_mkII | 1.4.1 | `32a7fb797202cdf92312ed9d133f96fdbcda590a` | `v1.4.1` | `gmpfrxx_mkII.1.4.1.tar.xz` | `395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4` | 15176064 | frozen |
| MPLAPACK | 3.0.1 | `c21a9f56224308afda9e7424ca9928d4cf840f7a` | external QA/tag owner | `mplapack-3.0.1.tar.xz` | `f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1` | 85807808 | supplied candidate used and verified |
| mplapack-interop | 0.3.0 | `392b72786f34d0bc1efcf35e2fd0cf0de58ec64f` | `v0.3.0` | `mplapack-interop-0.3.0.tar.gz` | `1282f77f98bb7b137d1a8800d1d6d426ed06000595aebc03e5fa5ac48b3bdf98` | 306282 | D02 frozen |

The D01R1 predecessor remains immutable provenance only:
`mplapack-interop 0.2.1`, commit
`b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6`, tag `v0.2.1`, archive
`mplapack-interop-0.2.1.tar.gz`, SHA256
`28769e877e0588a59d9c0d6736fb875624df8b836f570cc9e87eda7d74936d0f`.

The MPLAPACK archive supplied for D01R1 includes the macOS `/bin/sh`
pkg-config generation fix, macOS QD/DD load-check fixes, the Automake load
probe fix, the external-gmpfrxx pkg-config include-path fix, the public
precision-scope header, and generated release files. MPLAPACK release QA and
`v3.0.1` tag creation are maintained separately by its release maintainer;
this worktree neither creates nor modifies that tag.

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

## Dependency graph

```text
mplapack-interop 0.3.0
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
and `mplapack.h`, which rely on internal `INTEGER`/`REAL` definitions, are
not installed as public development headers.

The final tested runtime closure on the audit host is:

```text
libmplapack_mpfr.so.3
libmpc.so.3
libmpfr.so.6
libgmp.so.10
libstdc++.so.6, libgcc_s.so.1, libc.so.6
```

GMP, MPFR, and MPC are build/header dependencies of the MPLAPACK MPFR
backend and runtime shared-library dependencies of `libmplapack_mpfr.so.3`.
gmpfrxx_mkII supplies the public C++ MPFR/MPC value interface and has no
separate runtime library in this stack.

## Provenance and QA handoff

The final Octave build was made against the installed prefixes derived from
the gmpfrxx and MPLAPACK archives above. `pkg-config --modversion
mplapack_mpfr` reported 3.0.1, the precision-scope header was found in the
installed MPLAPACK include directory, and `readelf`/`ldd` checks found no
missing dependencies or non-host unresolved relocations. Full M00-M23,
C00-C12, mandatory C11L, N00-N07, lifecycle, precision-canary, firewall, and
sanitizer walls passed.

The D02 source package was generated twice from independent clean trees with
`SOURCE_DATE_EPOCH=0`, produced the identical SHA256 shown above, and the
tagged archive was copied to:

```text
/home/docker/src/mplapack-interop-0.3.0.tar.gz
```

The D02 package tag `v0.3.0` peels exactly to
`392b72786f34d0bc1efcf35e2fd0cf0de58ec64f`; the archive was regenerated from
that tagged tree and matched the pre-tag SHA256 and file list.

This document is the D01 handoff. Future binary/package work must consume the
exact archive/version/commit identities recorded here. If the external
MPLAPACK release maintainer changes the source after QA, re-run the dependency
and full-stack audit before using it as a release dependency.
