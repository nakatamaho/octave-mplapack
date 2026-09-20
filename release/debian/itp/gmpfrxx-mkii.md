## ITP: gmpfrxx-mkii -- C++ multiple-precision GMP/MPFR/MPC headers

Package: gmpfrxx-mkii
Type: new Debian source package (ITP)
Proposed binary: libgmpfrxx-mkii-dev
Section: science
Priority: optional

Upstream: https://github.com/nakatamaho/gmpfrxx_mkII
Release: v1.4.1, commit `32a7fb797202cdf92312ed9d133f96fdbcda590a`
Source archive: `gmpfrxx_mkII.1.4.1.tar.xz`
SHA256: `395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4`
License: BSD-2-Clause

Description:
 gmpfrxx_mkII provides C++ wrappers and precision-context support around GMP,
 MPFR, and MPC. It is the system-header/provider dependency for the MPFR
 MPLAPACK stack and related arbitrary-precision consumers.

Dependency relation:
 This source package is first in the proposed dependency chain. MPLAPACK's
 MPFR build consumes its installed headers; the provider shared-library
 SONAME and final Debian runtime/development split still require Debian
 Science policy review.

Local evidence:
 The released archive's upstream tests passed 156/156. A review-only Debian
 source skeleton, provider-header smoke test, clean resolute amd64 sbuild,
 copied-rootfs lifecycle/autopkgtest smoke, local APT install/remove/reinstall
 smoke, and direct binary Lintian evidence are present. The provider split is
 still a draft: maintainer identity, DEP-5 review, Debian ABI/symbols policy,
 and official testbed/archive acceptance remain open.

Maintenance request:
 Please advise whether Debian Science wants to maintain this package and how
 the unversioned `libgmpxx_mkII_default_context_provider.so` ABI should be
 split or versioned.
