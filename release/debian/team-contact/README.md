# Debian team-contact log and draft templates

The messages in this directory are historical draft templates, not exact
copies of the emails sent. Current contact status is:

| Team | Sent / reply | Current state |
|---|---|---|
| Debian Science | Initial inquiry sent 2026-09-20; follow-up sent 2026-09-23 | Awaiting response on gmpfrxx_mkII/MPLAPACK ownership, package names, provider ABI, symbols/Multi-Arch, and Salsa routing |
| Debian Octave Group | Inquiry sent with the Octave Packages PR #841 context; Rafael replied 2026-09-22. User subsequently requested Salsa repository creation/access. | Rafael confirmed Debian source and binary names `octave-mplapack`, Debian Octave Group as `Maintainer`, Maho NAKATA in `Uploaders`, and `octave-team` namespace. Rafael will create the repo and grant access; awaiting completion. ITP should wait until the repo exists. |

The Octave exchange also recommended considering `dh_octave_make`. The
confirmation is workflow/name guidance only; it is not package acceptance,
sponsorship, or permission to claim a Debian upload.

Historical draft order (do not resend without updating):

1. Debian Science: gmpfrxx-mkii and mplapack
2. Debian Octave Group: octave-mplapack-interop

The Octave template still uses the earlier candidate name
`octave-mplapack-interop`; update it to `octave-mplapack` before any future
reuse. Attach or link signed source packages, Salsa repositories, ITP numbers,
and actual lintian/sbuild/autopkgtest results only after those exist.
