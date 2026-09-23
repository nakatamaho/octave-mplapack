# Debian submission status

```text
ITP bugs:              NOT FILED
octave-team Salsa repo: NOT CREATED (requested from Rafael; awaiting creation/access)
Salsa account/SSH:      APPROVED / AUTHENTICATED as @maho; host key verified
mentors uploads:       NOT PUBLISHED
RFS bugs:              NOT FILED
Debian NEW:            NOT SUBMITTED
sid acceptance:        NOT APPLICABLE
```

The Debian Octave Group confirmed that the source and binary package names
should both be `octave-mplapack`, with Debian Octave Group as `Maintainer`
and Maho NAKATA in `Uploaders`. Rafael Laboissière will create the repository
under `octave-team` and grant access; the request is pending. He advised
waiting to file an ITP until that repository exists. The existing local ITP
draft for `octave-mplapack-interop` is therefore stale with respect to the
team's chosen Debian package name and must be reconciled before filing.

The Octave Packages index PR #841 is a separate registry contribution, not a
Debian submission. It is open and ready for review; the YAML check passes,
while the package-install check awaits availability of
`libmplapack-mpfr-dev` in the CI Ubuntu repositories.

Debian Science has been contacted about gmpfrxx_mkII/MPLAPACK ownership,
package names, provider ABI, symbols/Multi-Arch, and Salsa routing. A follow-up
was sent; no response is recorded as of 2026-09-23.

Ready-to-send ITP and team-contact drafts are under:

```text
release/debian/itp/
release/debian/team-contact/
```

No bug number, sponsor, or Debian package submission URL is fabricated. The
Octave team's maintenance/name guidance is recorded above, but does not imply
package acceptance or sponsorship. Before filing, repeat the WNPP/name audit,
update the Octave ITP draft to `octave-mplapack`, confirm identity/changelog
metadata, and complete the required package QA gates.

Dependency order for eventual publication (with the required MPC prerequisite):

```text
mpclib3 -> gmpfrxx-mkii -> mplapack -> octave-mplapack
```
