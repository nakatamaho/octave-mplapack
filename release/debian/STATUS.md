# RELDEB00 status

## Completed local stages

```text
R00  PASS    released archives, tags/commits, licenses, and SHA256 recorded
P00  PASS    candidate names available in local Debian/BTS audit
P01  PARTIAL packaging boundary and license audit recorded
```

## Pending stages

```text
P02  PARTIAL  local `1.4.1+dfsg` source and `.so.1` provider split build cleanly; Debian ABI/metadata review remains
P03  PARTIAL  clean `resolute` chroot build succeeds with target-suite metadata; policy, lifecycle, and Debian review remain
P04  PARTIAL  clean `resolute` chroot build succeeds with MPC 1.4.1 and the reproducibility patch; lifecycle/PPA review remain
P05  PARTIAL  clean sbuild/autopkgtest/piuparts/local APT and binary-package reproducibility pass locally; provider/debug-symbol policy, lintian, signing remain
U00  PENDING  staging PPA metadata and credentials
U01  BLOCKED  Launchpad account, PPA, and upload key not configured
U02  PENDING  requires U01
D00  PENDING  ITP intentionally deferred until the Debian Octave Group Salsa repository exists; then recheck WNPP and reporter identity
D01  PARTIAL  Salsa account and SSH authentication verified; octave-team repository/access and signing/mentors publication remain pending
D02  BLOCKED  sponsor/RFS workflow requires Debian submission identity
```

The local machine is Ubuntu 26.04 amd64 with Octave 11.1.0. It has the Debian
build/QA toolchain and a registered `resolute-amd64-sbuild` schroot. Clean
P02/P03/P04 source builds, copied-rootfs autopkgtest, piuparts, local APT
install/remove/reinstall, and two-build P04 binary-package reproducibility with
the packaging-only prefix-map/debugedit patch have completed there. The latest local APT
stack uses the `1.4.1+dfsg` provider split and target-suite metadata; the
reinstall smoke still passes. The new P02 candidate also cleanly builds a
versioned provider runtime split; direct binary Lintian has only the expected
initial-upload warnings. Source-package metadata, licensing, Debian policy,
and installed P03/P04 review remain open. No Debian upload identity, upload
key, Launchpad credential, or official lifecycle PASS is recorded.

The complete project `tools/local-ci.sh` run also passed on 2026-09-20 with
the validated MPLAPACK stack selected through `PKG_CONFIG_PATH` (exit status
`0`). It covered the native M00–M21 probes, M20 complex audit probes,
installed-package lifecycle, public factorization/release-closure tests, and
the compatibility firewall. This is local project evidence and does not change
the external Debian/Launchpad status above.

No ITP, team Salsa repository, mentors upload, PPA upload, RFS, or public
Debian/Ubuntu submission has been made. The Salsa account is approved
(`@maho`, ID 30038); the user confirmed SSH authentication and host-key
verification using Debian's published host-key list. Rafael Laboissière
confirmed that the Debian Octave Group can be Maintainer, the user can be in
Uploaders, and the repository should be created under `octave-team`; he will
create it and grant access. The request has been sent and repository creation
is pending. Per Rafael's advice, do not file an ITP before that repository
exists.

The Octave Packages index contribution is separate from Debian publication:
PR #841 is open and marked ready for review. Its YAML check passes; the package
installation check currently fails because the anticipated
`libmplapack-mpfr-dev` dependency is not yet available in the CI Ubuntu
repositories. This limitation was disclosed and accepted for review; no merge
or maintainer review is recorded yet.

The Debian Science inquiry about gmpfrxx_mkII/MPLAPACK ownership, names,
provider ABI, symbols/Multi-Arch, and Salsa routing was sent with a follow-up;
no response is recorded as of 2026-09-23. The Debian Octave Group has directed
that both Debian source and binary package names be `octave-mplapack`, with
`dh_octave_make` considered. Existing local packaging drafts still use
`octave-mplapack-interop`; reconcile that identity before any Salsa import.
The email templates and contact log are under `release/debian/team-contact/`.

Local packaging remains review-only. The actual Debian `debian/*` files must
be maintained in the team Salsa repository, not the upstream GitHub project.
The next local work remains P02/P03 policy and provider-ABI closure, followed
by clean package lifecycle/autopkgtest and reproducibility review. P04 also
requires the MPC 1.4.1 prerequisite because Ubuntu 26.04's MPC 1.3.1 lacks
`mpc_log2`.

Additional boundary evidence now separates the blockers: the standalone
gmpfrxx provider has an unversioned public SONAME, but the released MPFR-only
MPLAPACK library neither links that provider nor exports its ABI symbols.
Therefore the provider ABI decision affects independent gmpfrxx consumers, not
the `mplapack-interop` runtime dependency closure. The local candidate resolves
the ELF packaging issue with a separate `.so.1` runtime package, but Debian
policy review of the standalone gmpfrxx package remains necessary.
