Subject: Packaging discussion: gmpfrxx-mkii and MPLAPACK 3.0.1

Hello Debian Science team,

I am preparing proposed packages for the released gmpfrxx_mkII 1.4.1 and
MPLAPACK 3.0.1 stack. The upstream archives, commits, and SHA256 values are
listed in the attached provenance record. The intended first backend is
MPLAPACK MPFR using system GMP/MPFR/MPC and the packaged gmpfrxx headers.

Could the team advise on:

* ownership/team-maintenance routing;
* the final source/binary names;
* the unversioned gmpfrxx default-context provider SONAME;
* symbols/shlibs and Multi-Arch policy for the MPLAPACK C++ libraries?

The current worktree contains review-only Debian skeletons, not upload-ready
packages. Full Debian QA and public submission will follow team guidance.

Regards,
Pending maintainer identity
