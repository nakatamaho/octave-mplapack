# COMPLEX C00-C12 status

REAL_V0_1_RC_COMMIT: `0bef79cddd3fdd70abafdf38bc1a4ab492652d33`

COMPLEX_START_COMMIT: `4aed479ef9cb8dff24f0326e1c2ec2a7c1ed83a3`

Current milestone: C05

Last PASS milestone: C04

octave-mplapack branch/tip: `topic/complex-c00-c12` / `0562e2713dcd6a91cd040aee622b6339dc472c46`

MPLAPACK tested commit: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` (`topic/octave-mplapack-complex-mpfr-scope`)

gmpfrxx_mkII tested commit: `32a7fb797202cdf92312ed9d133f96fdbcda590a` (`main`)

Upstream fixes:

- MPLAPACK `a59e5a0a4`: install the required `mplapack_mpfr_precision.h`
  MPFR scope header and include it from the public MPFR interfaces.

Blockers: none.

Full regression status: C04 PASS. C00 storage/scope/TLS/lifetime/special
value probe PASS at 128, 256, 512, 1024, and 2048 bits under ASan/UBSan/LSan;
C01 scalar construction/conversion, C02 dense complex construction,
inspection/indexing/assignment, C03 real/imag/conj/transpose/ctranspose, and
C04 complex element-wise arithmetic tests PASS; full M00-M23 real native and
public regression wall PASS.

Release policy: MPLAPACK 3.0.1 remains a planned dependency version. No
release commit, archive, or final tags are frozen in C00-C12.
