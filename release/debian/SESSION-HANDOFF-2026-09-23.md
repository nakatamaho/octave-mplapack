# Session handoff — 2026-09-23

## Purpose and scope

Resume the downstream Debian/Ubuntu release work for the already-published
`mplapack-interop` 0.5.0 release. The active controller is
[`RELDEB00`](../../docs/goals/RELDEB00-mplapack-interop-debian-ppa-official-submission.md).
Do not add numerical features or modify the frozen upstream release. This
handoff records user-reported email/account events and repository evidence as
of 2026-09-23; recheck live external state before acting.

## Frozen upstream release

| Component | Version | Identity |
|---|---:|---|
| `gmpfrxx_mkII` | 1.4.1 | tag `v1.4.1`, commit `32a7fb797202cdf92312ed9d133f96fdbcda590a` |
| MPLAPACK | 3.0.1 | tag `v3.0.1`, commit `953d7a4916554546937a753a30b0619691072841` |
| Octave package | 0.5.0 | DESCRIPTION name `mplapack-interop`; repository `nakatamaho/octave-mplapack`; tag `v0.5.0`, freeze commit `7187a0f6c5a40a4d5774f4f913b166ccb6a5dffa` |

The Octave release asset is `mplapack-interop-0.5.0.tar.gz`, 817,463 bytes,
SHA256 `3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04`.
See [`dependency-release-stack-r1.md`](../../docs/dependency-release-stack-r1.md)
and [`D04 status`](../../docs/goals/D04-0.5.0-release-freeze-status.md).
D04 is complete; no Debian package or PPA has been published.

Keep these names distinct:

- Upstream Octave package/index name: `mplapack-interop`.
- GitHub upstream repository: `octave-mplapack`.
- Debian Octave Group's requested Debian source and binary package name:
  `octave-mplapack`.

## External coordination

### GNU Octave Packages index

[PR #841](https://github.com/gnu-octave/packages/pull/841), “Add
mplapack-interop 0.5.0”, is open and marked ready for review. At the last check
on 2026-09-23, `check-yaml` passed, `check-package` failed because the
anticipated `libmplapack-mpfr-dev` dependency is not yet available in the CI
Ubuntu repositories, and no maintainer review was recorded. Markus Mützel said
there is precedent for an unavailable external dependency and left the choice
to the package maintainer. Maho replied that the PR should proceed with that
dependency name and accepted the current CI limitation. Do not treat the red
package-install check as a new, undisclosed failure; update/rerun it when the
dependency is packaged.

### Debian Octave Group

Rafael Laboissière replied on 2026-09-22:

- Wait to file an ITP until the Salsa repository exists.
- Use `octave-mplapack` for both Debian source and binary package names.
- The repository should be under `octave-team`.
- Debian Octave Group may be `Maintainer`; Maho NAKATA may be in `Uploaders`.
- Rafael will create the repository and grant access when asked.
- Consider `dh_octave_make`.
- Debian `debian/*` files belong in Salsa, not the upstream GitHub repository.

Maho's reply/request for repository creation and access has been sent. As of
this handoff, creation and membership are pending. This is workflow/name
guidance, not package sponsorship, acceptance, or an ITP.

### Debian Science

Maho sent an inquiry on 2026-09-20 about ownership, package names, the gmpfrxx
provider SONAME/ABI, MPLAPACK symbols/Multi-Arch, and Salsa placement. A
follow-up was sent on 2026-09-23 asking whether to file ITPs, wait, or
coordinate elsewhere. No reply is recorded as of this handoff. Do not send a
duplicate follow-up immediately.

### Salsa access

The Salsa account was manually approved. The user's SSH test returned
`Welcome to GitLab, @maho!`; the host key was subsequently checked using the
Debian-published `debian_known_hosts` list. SSH authentication and server
identity verification are complete. The attempted `scp` from
`master.debian.org` failed with `Permission denied (publickey)`; this is
expected without an account on that Debian host and is unrelated to Salsa
access. Do not repeat that `scp` command. 2FA was not confirmed and was not
required for the successful SSH test.

## Local Debian/PPA preparation

The current [`STATUS.md`](STATUS.md) and [`QA.md`](QA.md) are authoritative for
the detailed local QA state. Summary:

- R00 and P00 local evidence: PASS.
- P01: PARTIAL.
- P02–P05: local builds and substantial smoke/lifecycle/reproducibility
  evidence exist, but package metadata, licensing, ABI/symbols/Multi-Arch,
  Debian policy, Lintian, and/or review gates remain open. These are not
  official Debian QA passes.
- U00/U01/U02: no Launchpad PPA has been created or uploaded to; upload
  credentials/PPA preflight is still pending or blocked.
- No ITP, team Salsa repository, mentors upload, RFS, Debian NEW submission,
  or Ubuntu archive publication has occurred.
- Local skeletons remain under `release/debian/repos/`, including an
  `octave-mplapack-interop` draft. These are review-only working files, not the
  authorized Debian team repository. Reconcile naming and transfer the real
  Debian packaging into Salsa after Rafael creates the team repo. Do not
  publish `debian/*` in the upstream GitHub repository.
- The PPA draft manifest still uses the earlier Octave package name. Reconcile
  it with `octave-mplapack` and rerun the affected package QA before upload.
- P04's Ubuntu 26.04 stack requires an MPC 1.4.1 prerequisite because the
  Ubuntu-provided MPC 1.3.1 lacks `mpc_log2`.

The project's full local CI was previously recorded PASS on 2026-09-20; this
session made documentation/status changes only and did not rerun numerical CI.

## Next actions

1. Wait for Rafael to create `octave-team/octave-mplapack` and grant Maho
   access. Then verify access and clone the team repository; do not create a
   duplicate repository or file the Octave ITP beforehand.
2. Once the repository exists, reconcile the current Debian package drafts to
   the agreed `octave-mplapack` source/binary name and the team's workflow,
   considering `dh_octave_make`. Keep Debian packaging commits in Salsa.
3. Wait for Debian Science's reply before deciding dependency-team ownership,
   names, and ABI policy. Do not file duplicate inquiries or ITPs.
4. Recheck current WNPP/package availability and required identities before
   any ITP or upload. Continue local package-policy/QA work without claiming
   official acceptance.
5. Keep PR #841 open and ready for review; rerun package-index CI after the
   Ubuntu dependency becomes available or if maintainers request a change.

## Worktree snapshot

At handoff creation:

```text
branch: topic/reldeb00-debian-ppa
HEAD:   28c460800f311580f0bcb8da48ecd2b36a70eff9
remote: origin/topic/reldeb00-debian-ppa pointed to the same HEAD before the
        current status-document edits
```

Status updates from this session are **not committed or pushed**. Changed
tracked files before adding this handoff:

```text
release/debian/DEBIAN-STATUS.md
release/debian/PACKAGE-NAME-AUDIT.md
release/debian/PPA-SUBMISSION-MANIFEST.md
release/debian/PUBLIC-SUBMISSION-STATUS.md
release/debian/QA.md
release/debian/STATUS.md
release/debian/TEAM-ROUTING.md
release/debian/itp/README.md
release/debian/itp/octave-mplapack-interop.md
release/debian/team-contact/README.md
release/debian/team-contact/debian-octave.md
release/debian/team-contact/debian-science.md
```

Validation after those status edits:

```text
tools/check-format.sh: PASS
tools/check-tree.sh:   PASS
git diff --check:      PASS
```

This handoff is also uncommitted. No source/numerical code was changed and no
external action was taken from the repository.
