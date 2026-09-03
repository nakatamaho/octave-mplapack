# COMPLEX C00-C12 status

REAL_V0_1_RC_COMMIT: `0bef79cddd3fdd70abafdf38bc1a4ab492652d33`

COMPLEX_START_COMMIT: `4aed479ef9cb8dff24f0326e1c2ec2a7c1ed83a3`

Current milestone: C00

Last PASS milestone: none

octave-mplapack branch/tip: `topic/complex-c00-c12` / pending C00 commit

MPLAPACK tested commit: `a59e5a0a4` (`topic/octave-mplapack-complex-mpfr-scope`)

gmpfrxx_mkII tested commit: `32a7fb797202cdf92312ed9d133f96fdbcda590a` (`main`)

Upstream fixes:

- MPLAPACK `a59e5a0a4`: install the required `mplapack_mpfr_precision.h`
  MPFR scope header and include it from the public MPFR interfaces.

Blockers: none.

Full regression status: C00 complex storage/scope sanitizer probe PASS;
real regression wall pending.

Release policy: MPLAPACK 3.0.1 remains a planned dependency version. No
release commit, archive, or final tags are frozen in C00-C12.
