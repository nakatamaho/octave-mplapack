# Debian Multi-Arch handoff

These are proposed fields for the draft packages, pending Debian team review.
They are not claims that the packages are ready for the archive.

| Package | Architecture | Proposed Multi-Arch | Reason / open review |
|---|---|---|---|
| `libgmpfrxx-mkii-dev` | `any` | `same` provisionally | headers and CMake metadata are architecture-independent in intent, but the provider shared object is architecture-dependent and has an unresolved unversioned SONAME |
| `libmplapack-mpfr3` | `any` | `same` | architecture-specific shared libraries with parallel-installable development interfaces |
| `libmplapack-mpfr-dev` | `any` | `same` | headers and pkg-config metadata refer to architecture-specific libraries |
| `octave-mplapack-interop` | `any` | unset provisionally | compiled `.oct` module is architecture-specific and has Octave ABI dependencies |

The `libgmpfrxx-mkii-dev` row is intentionally provisional. Debian policy
review must decide whether the provider belongs in a versioned runtime binary
package, remains development-only, or needs an upstream SONAME change. No
Multi-Arch field should be copied into an official package before that review.

The MPLAPACK and Octave package decisions are based on the clean resolute
build, `dpkg-deb` contents, `readelf`, and `dpkg-shlibdeps` evidence. They must
be repeated in the target Debian/Ubuntu packaging environment.
