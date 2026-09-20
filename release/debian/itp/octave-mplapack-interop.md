## ITP: octave-mplapack-interop -- multiple-precision MPLAPACK bindings for Octave

Package: octave-mplapack-interop
Type: new Debian source package (ITP)
Proposed binary: octave-mplapack-interop
Section: math
Priority: optional

Upstream: https://github.com/nakatamaho/octave-mplapack
Release: v0.5.0, commit `7187a0f6c5a40a4d5774f4f913b166ccb6a5dffa`
Source archive: `mplapack-interop-0.5.0.tar.gz`
SHA256: `3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04`
License: BSD-2-Clause
Depends: octave (>= 11.1.0)

Description:
 mplapack-interop provides an Octave package and native `.oct` bridge for
 arbitrary-precision MPLAPACK operations. The released 0.5.0 archive is the
 current advanced/complex release and must not be described as the older
 real-only development candidate.

Dependency relation:
 This source package follows `gmpfrxx-mkii` and `mplapack` in the proposed
 stack. Its native build consumes the installed `mplapack_mpfr` pkg-config
 module and runtime shared library; it must not use a private source prefix.

Local evidence:
 The release archive has been audited and a review-only `dh-octave` skeleton
 produces source metadata. A clean resolute amd64 sbuild, installed-package
 smoke in a copied testbed, local APT install/remove/reinstall, direct binary
 Lintian, and two-build binary-package reproducibility comparison pass
 locally. The current draft does not emit automatic dbgsym packages and still
 needs Debian debug-symbol policy, maintainer identity, official testbed
 acceptance, and archive review.

Maintenance request:
 Please advise whether the Debian Octave Group wants to maintain this package,
 with Debian Science co-maintenance for the MPLAPACK dependency chain.
