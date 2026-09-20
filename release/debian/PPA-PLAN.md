# Ubuntu PPA handoff plan

This plan is preparatory only. No PPA, upload, Launchpad build, or apt source
has been created.

## Target

```text
Ubuntu suite:  26.04 (initial target)
Octave:        11.1.0 baseline
Architecture:  amd64 deeply validated; other Launchpad architectures pending
```

## Ordered work

```text
PPA0  package GNU MPC 1.4.1 because Ubuntu 26.04 has MPC 1.3.1
PPA1  package and build the required MPLAPACK MPFR dependency first
PPA2  build octave-mplapack-interop against PPA0/PPA1's published dependencies
PPA3  staging PPA build/install/remove/reinstall QA
PPA4  public PPA and final release decision
```

The PPA stack must use the released upstream archives and system dependency
policy recorded in `PROVENANCE.md` and `PACKAGING-AUDIT.md`. Launchpad builders
must not depend on a private source worktree or `/tmp` prefix.

## Proposed package names

```text
libgmpfrxx-mkii-dev
libgmpxx-mkii-default-context-provider1  (local SONAME .so.1 candidate)
libmplapack-mpfr3
libmplapack-mpfr-dev
octave-mplapack-interop
libmpc3 / libmpc-dev 1.4.1 (PPA prerequisite; provides mpc_log2)
```

These are proposals for P02/P03/P04 review, not final Debian names. The local
P02 candidate splits the provider runtime from the development package; the
package name, symbols, and Multi-Arch policy remain subject to Debian review.
The MPC
binary names follow Ubuntu's existing `mpclib3` source package and must be
coordinated with the Ubuntu/Debian maintainers. PPA0/PPA1/PPA2 own the Debian
Policy and package-name decisions.

## External gate

U01 is blocked until a Launchpad account, staging PPA, upload key, and package
upload permission are available. Never claim PPA validation before a published
build and a clean `apt install`/remove/reinstall test.
