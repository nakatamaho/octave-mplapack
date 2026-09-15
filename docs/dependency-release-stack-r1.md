# D04 dependency release stack

This repository-only manifest is the canonical binary-distribution handoff
for the `mplapack-interop` 0.5.0 source freeze. It is excluded from the
public source archive because it records the archive checksum and would make
the release metadata self-referential. Historical D00/D02R1 manifests remain
available separately and are not reattributed to this stack.

## Canonical release table

| Layer | Repository | Version | Freeze/source commit | Tag | Archive | SHA256 | Size | License | Depends on |
|---|---|---:|---|---|---|---|---:|---|---|
| gmpfrxx_mkII | `github.com/nakatamaho/gmpfrxx_mkII` | 1.4.1 | `32a7fb797202cdf92312ed9d133f96fdbcda590a` | `v1.4.1` | `gmpfrxx_mkII.1.4.1.tar.xz` | `395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4` | 15176064 | BSD 2-Clause | GMP, MPFR, MPC |
| MPLAPACK | `github.com/nakatamaho/mplapack` | 3.0.1 | `953d7a4916554546937a753a30b0619691072841` | `v3.0.1` | `mplapack-3.0.1.tar.xz` | `47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa` | 85720132 | 2-clause BSD-style plus original LAPACK/BLAS notices | frozen gmpfrxx 1.4.1; GMP, MPFR, MPC |
| octave-mplapack (`mplapack-interop`) | `github.com/nakatamaho/octave-mplapack` | 0.5.0 | `7187a0f6c5a40a4d5774f4f913b166ccb6a5dffa` | `v0.5.0` | `mplapack-interop-0.5.0.tar.gz` | `3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04` | 817463 | BSD 2-Clause | MPLAPACK 3.0.1; gmpfrxx 1.4.1; GMP, MPFR, MPC; Octave |

The canonical local dependency archives are:

```text
/home/docker/src/gmpfrxx_mkII.1.4.1.tar.xz
/home/docker/src/mplapack-3.0.1.tar.xz
```

The final package archive generated from the D04 freeze commit is:

```text
/home/docker/src/mplapack-interop-0.5.0.tar.gz
```

Its size is `817463` bytes and its SHA256 is
`3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04`.
Two independent archive builds, the tagged-tree extraction, and an isolated
install/replay all produced the same identity. The D04 report records the
commands and evidence paths.

## Dependency graph and runtime closure

```text
mplapack-interop 0.5.0
    requires
MPLAPACK 3.0.1 / mplapack_mpfr
    requires
gmpfrxx_mkII 1.4.1
    requires
GMP / MPFR / MPC
```

GMP 6.3.0, MPFR 4.2.2, and MPC 1.4.1 are normal host build/header
prerequisites in the D04 QA environment. They are also runtime dependencies
of `libmplapack_mpfr.so.3` (`libgmp.so.10`, `libmpfr.so.6`, and
`libmpc.so.3`). The frozen gmpfrxx interface is header-oriented and installs
the `libgmpxx_mkII_default_context_provider.so` support library.

MPLAPACK installs the public MPFR backend headers under `include/mplapack/`,
including `mplapack_mpfr_precision.h`, and installs
`libmplapack_mpfr.so.3` plus `lib/pkgconfig/mplapack_mpfr.pc`. The internal
aggregate headers `mpblas.h` and `mplapack.h` use internal `INTEGER`/`REAL`
definitions and are intentionally not installed as public development
headers.

## Precision and thread contract

`MplapackMpfrPrecisionScope` establishes and restores the current-thread MPFR
default precision, supports nested same-thread MPLAPACK temporary
construction, and can be used at worker entry. It does not automatically
propagate a parent thread's TLS state into a new worker. The interop complex
paths compose the tested MPFR scope with the MPC scope. No builtin binary64
complex fallback is part of the release stack.

## License and provenance

```text
gmpfrxx_mkII 1.4.1: BSD 2-Clause; source tag v1.4.1
MPLAPACK 3.0.1: 2-clause BSD-style license plus bundled LAPACK/BLAS notices;
                source tag v3.0.1, release baseline 953d7a4916554546937a...
mplapack-interop 0.5.0: BSD 2-Clause
GMP: GNU LGPL v3 or later, with the GMP special exception
MPFR: GNU LGPL v3 or later
MPC: GNU LGPL v3 or later
```

Exact license files and upstream notices are included in the corresponding
source archives. D01 owns binary-distribution analysis and package-local
redistribution obligations.

## QA handoff

The D04 QA environment is x86_64 Linux with GNU Octave 11.1.0, GCC/G++ 15.2,
the MPFR backend, and the installed frozen dependencies. D04 records the
complete M00–M23 real wall, C00–C12 complex wall including mandatory C11L,
N00–N06, SVD/NEIG integration, N/S/T compatibility checks, 1024/2048-bit
canaries, ambient precision/lifetime checks, sanitizer coverage, external
installed-header consumers, isolated package lifecycle, and reproducible
source-archive evidence in `reports/D04-report.md`.

D01 must consume exactly the three version/commit/tag/archive identities in
the completed table above. If D01 finds a source-level defect, reopen D04 as
D04R1; do not edit a frozen source tree silently.

## D04 freeze identity

```text
package freeze commit: 7187a0f6c5a40a4d5774f4f913b166ccb6a5dffa
package tag:           v0.5.0
package tag target:    7187a0f6c5a40a4d5774f4f913b166ccb6a5dffa
release date:          2026-09-15
```

The `v0.5.0` tag is present locally and on `origin`, and both point exactly to
the freeze commit. The release branch and tag target were verified after the
push. The GitHub Release `v0.5.0` contains the exact package asset below; no
Debian package, PPA operation, or binary artifact was created.
