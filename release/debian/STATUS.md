# RELDEB00 status

## Completed local stages

```text
R00  PASS    released archives, tags/commits, licenses, and SHA256 recorded
P00  PASS    candidate names available in local Debian/BTS audit
P01  PARTIAL packaging boundary and license audit recorded
```

## Pending stages

```text
P02  PARTIAL  local `.so.1` provider split builds cleanly; Debian ABI/metadata review remains
P03  PARTIAL  clean chroot build succeeds; policy, lifecycle, and Debian review remain
P04  PARTIAL  clean chroot build succeeds with MPC 1.4.1; lifecycle/PPA review remain
P05  PARTIAL  clean sbuild/autopkgtest/piuparts/local APT and patched reproducibility pass locally; provider policy, lintian, signing remain
U00  PENDING  staging PPA metadata and credentials
U01  BLOCKED  Launchpad account, PPA, and upload key not configured
U02  PENDING  requires U01
D00  PENDING  ITP filing requires reporter identity and current WNPP recheck
D01  BLOCKED  Salsa/mentors account and signing identity not configured
D02  BLOCKED  sponsor/RFS workflow requires Debian submission identity
```

The local machine is Ubuntu 26.04 amd64 with Octave 11.1.0. It has the Debian
build/QA toolchain and a registered `resolute-amd64-sbuild` schroot. Clean
P02/P03/P04 source builds, copied-rootfs autopkgtest, piuparts, local APT
install/remove/reinstall, and two-build P04 reproducibility with the
packaging-only prefix-map patch have completed there. The new P02 candidate
also cleanly builds a versioned provider runtime split; direct binary Lintian
has only the expected initial-upload warnings. Source-package metadata,
licensing, Debian policy, and installed P03/P04 review remain open. No Debian
identity, upload key, public submission, or Launchpad credential is configured,
and no official lifecycle PASS is claimed.

No ITP, Salsa repository, mentors upload, PPA upload, RFS, or public Debian
submission has been attempted; ready-to-send ITP/team-contact drafts are now
under `release/debian/itp/` and `release/debian/team-contact/`. The next
resumable stage is P02/P03 policy and provider-ABI closure, followed by clean
package lifecycle/autopkgtest and reproducibility runs. P04 requires the PPA
MPC 1.4.1 prerequisite because Ubuntu 26.04's MPC 1.3.1 lacks `mpc_log2`.

Additional boundary evidence now separates the blockers: the standalone
gmpfrxx provider has an unversioned public SONAME, but the released MPFR-only
MPLAPACK library neither links that provider nor exports its ABI symbols.
Therefore the provider ABI decision affects independent gmpfrxx consumers, not
the `mplapack-interop` runtime dependency closure. The local candidate resolves
the ELF packaging issue with a separate `.so.1` runtime package, but Debian
policy review of the standalone gmpfrxx package remains necessary.
