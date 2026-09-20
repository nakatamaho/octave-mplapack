# Debian ABI handoff

This is a local packaging audit for the RELDEB00 draft stack. It is not a
Debian archive approval or a substitute for `debian/symbols` review.

| Binary package | Library | SONAME | `dpkg-shlibdeps`/runtime boundary |
|---|---|---|---|
| `libgmpfrxx-mkii-dev` | `libgmpxx_mkII_default_context_provider.so` | unversioned `libgmpxx_mkII_default_context_provider.so` | standalone provider only; not linked by the MPFR-only MPLAPACK stack |
| `libmplapack-mpfr3` | `libmplapack_mpfr.so.3` | `libmplapack_mpfr.so.3` | GMP, MPFR, MPC, libstdc++, libc |
| `libmplapack-mpfr3` | `libmplapack_mpfr_opt.so.3` | `libmplapack_mpfr_opt.so.3` | optimized companion; same numeric dependency family |
| `octave-mplapack-interop` | `__mplapack_core__.oct` | Octave extension, no public SONAME | Octave ABI plus `libmplapack_mpfr.so.3` |

The provider's unversioned SONAME produces the current P02 Lintian findings
(`shared-library-lacks-version`, `package-name-doesnt-match-sonames`, and
`lacks-ldconfig-trigger`). It must not be hidden by an unjustified override.
P02 remains a policy/ABI decision for Debian maintainers or the upstream
provider project.

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
Debian review; this document records the exact local evidence and the open
provider issue.
