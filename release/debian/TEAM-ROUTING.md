# Debian maintenance routing status

This records team guidance received to date. It is not evidence of package
acceptance, sponsorship, or a completed Salsa import.

| Source package | Candidate route | Contact/policy | Status |
|---|---|---|---|
| `gmpfrxx-mkii` | Debian Science, or individual maintainer with Science co-maintenance | [Debian Science](https://wiki.debian.org/Teams/DebianScience) | PENDING RESPONSE |
| `mplapack` | Debian Science | [Debian Science](https://wiki.debian.org/Teams/DebianScience) | PENDING RESPONSE |
| `octave-mplapack` | Debian Octave Group; Debian Science may advise on dependencies | [Debian Octave Group](https://wiki.debian.org/Teams/DebianOctaveGroup) | CONFIRMED ROUTING / REPO PENDING |

Rafael Laboissière confirmed by email on 2026-09-22 that Debian source and
binary names should both be `octave-mplapack`, Debian Octave Group may be
`Maintainer`, and Maho NAKATA may be listed in `Uploaders`. He will create the
repository under `octave-team` and grant access after the user's request; that
creation/access is still pending. He recommended considering `dh_octave_make`.
This is team workflow/name guidance, not sponsorship or package acceptance.

Do not file the Octave ITP until the Salsa repository is created, per Rafael's
advice. Repeat the WNPP/name check before filing. Local skeletons still use
`octave-mplapack-interop` in places and must be reconciled to the agreed Debian
name before import.

## Current evidence

Debian Science was contacted about gmpfrxx_mkII/MPLAPACK ownership, names,
provider ABI, symbols/Multi-Arch, and Salsa routing; a follow-up was sent and
no answer is recorded as of 2026-09-23. The Debian Octave Group exchange and
current next step are summarized above. No sponsor assignment has been
obtained, and no Debian package has been publicly submitted.
