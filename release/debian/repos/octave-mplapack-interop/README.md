# P04 `octave-mplapack-interop` packaging workspace

Status: **AUDIT PARTIAL / DRAFT SKELETON ONLY**. No Debian source package is
submitted from this workspace. The `debian/` directory is a review aid for
P04 and is not upload-ready.

Input archive: `mplapack-interop-0.5.0.tar.gz` with SHA256
`3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04`.

The Octave package name is `mplapack-interop`, minimum Octave is 11.1.0, and
the native `.oct` bridge must build against installed MPLAPACK pkg-config
metadata rather than a private prefix. P04 depends on completed P02/P03
packages and their Debian QA.

The 0.5.0 archive is a normal Octave package with `DESCRIPTION`, `inst/`,
`src/Makefile`, `test/`, `examples/`, and documentation. Its Makefile uses
`mkoctfile`, `pkg-config`, and the `mplapack_mpfr` module; it does not require
a private source-tree include or library path. Debian's `dh-octave` buildsystem
can invoke `pkg install` for the source tree, while the native build still
needs the final P03 development package and the gmpfrxx provider boundary.

The released 0.5.0 surface includes the later complex and advanced numerical
APIs recorded in its own NEWS/README; this is not the historical real-only
v0.1 candidate. P04 must package the released 0.5.0 archive as-is and must
not silently describe it as the v0.1 real-only API. No Debian build or QA PASS
is claimed until P02/P03 and the `dh-octave`/lintian/lifecycle toolchain are
available.

The extracted `dh_octave_make` helper also generated a candidate skeleton from
`DESCRIPTION` in a temporary copy. The generated Debian Octave team/Salsa
fields are not authoritative and were deliberately not committed; P04 still
requires team review, final MPLAPACK package names, and package QA.

The draft package is named `octave-mplapack-interop` and depends on the draft
`libmplapack-mpfr-dev`/`libmplapack-mpfr3` split. The included autopkgtest
now contains the intended installed-package smoke coverage: real arithmetic,
solve/factorization, complex construction, eig/SVD, deterministic RNG, and
binary serialization. It remains a draft because it has not run from a clean
Debian binary-package testbed; the P03 runtime package and Debian QA toolchain
are still unavailable.
