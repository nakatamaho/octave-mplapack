Subject: Packaging discussion: octave-mplapack-interop 0.5.0

Hello Debian Octave Group,

I am preparing a proposed `octave-mplapack-interop` package for the released
0.5.0 archive. It requires GNU Octave >= 11.1.0 and builds its native `.oct`
bridge against the packaged MPLAPACK MPFR pkg-config interface. The upstream
release provenance and current QA limitations are recorded in the attached
handoff documents.

Could the group advise on:

* team ownership and Salsa workflow;
* current dh-octave/autopkgtest expectations;
* coordination with Debian Science for the gmpfrxx/MPLAPACK dependency chain?

The current packaging files are review-only drafts. No ITP, Salsa repository,
mentors upload, or sponsor request has been made.

Regards,
Pending maintainer identity
