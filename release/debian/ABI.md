# Debian ABI handoff

This is a local packaging audit for the RELDEB00 draft stack. It is not a
Debian archive approval or a substitute for `debian/symbols` review.

| Binary package | Library | SONAME | `dpkg-shlibdeps`/runtime boundary |
|---|---|---|---|
| `libgmpxx-mkii-default-context-provider1` | `libgmpxx_mkII_default_context_provider.so.1` | `libgmpxx_mkII_default_context_provider.so.1` | standalone provider runtime; not linked by the MPFR-only MPLAPACK stack |
| `libgmpfrxx-mkii-dev` | `libgmpxx_mkII_default_context_provider.so` (development symlink) | links to provider ABI package above | headers/CMake metadata and the provider linker symlink |
| `libmplapack-mpfr3` | `libmplapack_mpfr.so.3` | `libmplapack_mpfr.so.3` | GMP, MPFR, MPC, libstdc++, libc |
| `libmplapack-mpfr3` | `libmplapack_mpfr_opt.so.3` | `libmplapack_mpfr_opt.so.3` | optimized companion; same numeric dependency family |
| `octave-mplapack-interop` | `__mplapack_core__.oct` | Octave extension, no public SONAME | Octave ABI plus `libmplapack_mpfr.so.3` |

The local P02 candidate applies a packaging-only CMake target version/SOVERSION
of `1`, splits the runtime provider into
`libgmpxx-mkii-default-context-provider1`, and leaves only the linker symlink
in `libgmpfrxx-mkii-dev`. Direct Lintian on both binary packages reports only
the expected `initial-upload-closes-no-bugs` warnings. This is a local draft
resolution, not Debian archive approval; maintainer ownership, symbols policy,
and source-package licensing review remain open.

The released `libmplapack_mpfr.so.3` was checked with `readelf -d` and has no
dependency on the standalone gmpfrxx provider. The P04 extension was checked
with `ldd -r`; no unresolved symbols or development-prefix RPATH/RUNPATH were
observed in the clean resolute build.

## Evidence commands

```text
dpkg-deb -c <package>.deb
readelf -d <library>
ldd -r <extension>.oct
dpkg-shlibdeps -O <extension>.oct
lintian --pedantic <package>.deb
```

Final package names, symbols files, and Multi-Arch fields remain subject to
Debian review; this document records the exact local candidate and the
remaining submission decisions.
