# D02R1 dependency release stack

This repository-only manifest is the canonical handoff for the frozen
`mplapack-interop` 0.3.1 source release. It is intentionally excluded from
the public source archive because it records that archive's checksum; putting
it into the archive would make the release metadata self-referential.

## Frozen stack

| Layer | Repository | Version | Freeze commit | Tag | Archive | SHA256 | Size | License | Depends on |
|---|---|---:|---|---|---|---|---:|---|---|
| gmpfrxx_mkII | `github.com/nakatamaho/gmpfrxx_mkII` | 1.4.1 | `32a7fb797202cdf92312ed9d133f96fdbcda590a` | `v1.4.1` | `gmpfrxx_mkII.1.4.1.tar.xz` | `395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4` | 15176064 | BSD 2-Clause | GMP, MPFR, MPC |
| MPLAPACK | `github.com/nakatamaho/mplapack` | 3.0.1 | `c21a9f56224308afda9e7424ca9928d4cf840f7a` | upstream release owner | `mplapack-3.0.1.tar.xz` | `f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1` | 85807808 | 2-clause BSD-style plus original LAPACK/BLAS notices | frozen gmpfrxx 1.4.1; GMP, MPFR, MPC |
| octave-mplapack (`mplapack-interop`) | `github.com/nakatamaho/octave-mplapack` | 0.3.1 | `41123b30a03b594aefaa9dec8ac82c8690a128df` | `v0.3.1` | `mplapack-interop-0.3.1.tar.gz` | `21a7c6751a17e783196c0e28e45d521a9251a1e3f2c210f38ab733fc89e0624b` | 306951 | BSD 2-Clause | MPLAPACK 3.0.1; gmpfrxx 1.4.1; GMP, MPFR, MPC; Octave |

The canonical archive files used for the freeze are installed at:

```text
/home/docker/src/gmpfrxx_mkII.1.4.1.tar.xz
/home/docker/src/mplapack-3.0.1.tar.xz
/home/docker/src/mplapack-interop-0.3.1.tar.gz
```

The gmpfrxx archive is the existing GitHub Release asset for `v1.4.1`.
MPLAPACK 3.0.1 is the supplied upstream QA archive at commit `c21a9f5`;
this workflow did not create or modify an MPLAPACK release tag. The only
new public tag created by D02R1 is `octave-mplapack:v0.3.1`.

## Dependency graph and runtime closure

```text
mplapack-interop 0.3.1
    requires
MPLAPACK 3.0.1 / mplapack_mpfr
    requires
gmpfrxx_mkII 1.4.1
    requires
GMP / MPFR / MPC
```

GMP 6.3.0, MPFR 4.2.2, and MPC 1.4.1 are normal host build/header
prerequisites in the tested environment. They are also runtime dependencies
of `libmplapack_mpfr.so.3` (`libgmp.so.10`, `libmpfr.so.6`, and
`libmpc.so.3`). The tested host resolves these normal prerequisites from
`/usr/local`; no MPLAPACK or gmpfrxx development prefix from `/usr/local` was
selected. The frozen gmpfrxx wrapper is header-oriented and installs the
`libgmpxx_mkII_default_context_provider.so` support library.

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
complex fallback is part of the frozen stack.

## QA environment and handoff

The full freeze QA ran on x86_64 Linux with GNU Octave 11.1.0, GCC/G++ 15.2,
the MPFR backend, and the installed frozen dependencies. It passed the full
M00-M23 real wall, C00-C12 complex wall including mandatory C11L, N00-N08,
1024-bit/2048-bit canaries, ambient precision/lifetime checks, sanitizer
wall, external installed-header consumers, and isolated package lifecycle.

The exact evidence is in `reports/N08-D02R1-report.md`. The historical D00
manifest remains in `docs/dependency-release-stack.md`; it is not rewritten by
this D02R1 handoff.
