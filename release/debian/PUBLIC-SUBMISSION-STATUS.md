# Public submission status

No public Debian or Ubuntu action has been performed from this worktree.

The upstream preparation branch is available for review as GitHub PR #26:
<https://github.com/nakatamaho/octave-mplapack/pull/26>. This review request
does not constitute a Debian, Launchpad, Salsa, mentors, or Ubuntu archive
submission.

The separate GNU Octave Packages index contribution is PR #841:
<https://github.com/gnu-octave/packages/pull/841>. It is open and marked ready
for review. The YAML check passes; the package-install check is expected to
remain red until the anticipated Ubuntu dependency `libmplapack-mpfr-dev` is
available. The limitation has been disclosed in the PR. This index entry is
not a Debian package submission.

```text
ITP bugs:              NOT FILED (Rafael advised waiting until the team repo exists)
octave-team Salsa repo: NOT CREATED (requested; awaiting Rafael)
Salsa account/SSH:      APPROVED / AUTHENTICATED as @maho; host key verified
mentors uploads:       NOT PUBLISHED
RFS bugs:              NOT FILED
Launchpad PPA:         NOT CREATED
PPA uploads:           NOT PERFORMED
Ubuntu archive sync:   NOT APPLICABLE
```

This is intentional: clean Debian testbed/policy gates remain incomplete, the
gmpfrxx provider ABI is not yet packageable without an explicit decision, GNU
MPC 1.4.1 is required as a PPA prerequisite, and Debian upload/Launchpad
credentials and sponsor access are not recorded as configured. Rafael
confirmed the Debian Octave Group can maintain the package and that the
repository belongs under `octave-team`; he will create it and grant access.
The request is pending. He advised deferring ITP filing until then. Debian
Science has been contacted and followed up; a response is pending. The artifacts
under `release/debian/` are the resumable local handoff, not public submission
evidence.

ITP drafts remain unfiled under `release/debian/itp/`; the Octave draft's
package name must be changed from `octave-mplapack-interop` to the team-directed
`octave-mplapack` before filing. Team-contact files include historical draft
templates and a status log; the actual emails have been sent as summarized in
`release/debian/team-contact/README.md`. Recheck WNPP and package availability
immediately before any public filing.
