# ABI and Multi-Arch handoff

This is an audit record, not a final Debian package decision.

## gmpfrxx_mkII

The 1.4.1 release installs a header/CMake development interface and
`libgmpxx_mkII_default_context_provider.so`. The provider's SONAME is
unversioned:

```text
libgmpxx_mkII_default_context_provider.so
```

No pkg-config module is installed. Debian must not invent a versioned runtime
ABI package from this observation. P02 must either obtain an upstream SONAME/
ABI policy or package the provider with the development interface and explain
why a separate runtime package is not yet safe. Multi-Arch fields remain
`PENDING` until that decision is made.

The released MPLAPACK 3.0.1 source adds an important boundary to this audit.
Its MPFR reference and optimized build lists include
`mpblas/reference/mplapackinit.cpp`, but that source's default-context provider
definitions are guarded by `MPLAPACK_BUILD_WITH_GMP`, not by
`MPLAPACK_BUILD_WITH_MPFR`. The validated `libmplapack_mpfr.so.3` therefore has
no `gmpxx_mkII_*` dynamic exports and no NEEDED entry for
`libgmpxx_mkII_default_context_provider.so`; its observed NEEDED set is
`libmpc.so.3`, `libmpfr.so.6`, `libgmp.so.10`, `libstdc++.so.6`, `libc.so.6`,
`libgcc_s.so.1`, and the dynamic loader. This means the provider library is not
a runtime dependency of the MPFR-only MPLAPACK/Octave stack. It remains a
separate packaging question for independent gmpfrxx external-provider users,
where the unversioned public SONAME still prevents a safe Debian ABI package
decision.

Evidence used for this conclusion:

```text
MPLAPACK source: mpblas/reference/mplapackinit.cpp
MPLAPACK MPFR source lists: mpblas/reference/Makefile.am,
  mpblas/optimized/mpfr/Makefile.am, mplapack/reference/Makefile.am
libmplapack_mpfr.so.3: no gmpxx_mkII_* dynamic exports
gmpfrxx provider: SONAME libgmpxx_mkII_default_context_provider.so
```

## MPLAPACK

The validated MPFR runtime SONAME is:

```text
libmplapack_mpfr.so.3
```

The development interface is represented by the `mplapack_mpfr` pkg-config
module and the installed headers, including
`mplapack_mpfr_precision.h`. P03 must inspect the actual final package's
`dpkg-gensymbols`/shlibs result and select Multi-Arch fields according to the
headers and architecture-dependent libraries, rather than copying this
proposal mechanically.

## Octave bridge

`octave-mplapack-interop` builds an architecture-dependent `.oct` module. It
must depend on the exact MPLAPACK MPFR runtime package selected by P03 and on
the tested Octave ABI. The package is not `Architecture: all`.

## Status

```text
ABI audit:       PARTIAL
Multi-Arch:      PENDING Debian package build
SONAME leakage:  gmpfrxx provider is unversioned; explicit upstream decision required
```
