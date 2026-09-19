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
