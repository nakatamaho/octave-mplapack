# COMPLEX C00-C12 status

REAL_V0_1_RC_COMMIT: `0bef79cddd3fdd70abafdf38bc1a4ab492652d33`

COMPLEX_START_COMMIT: `4aed479ef9cb8dff24f0326e1c2ec2a7c1ed83a3`

Current milestone: COMPLETE

Last PASS milestone: C12

octave-mplapack tested implementation: `topic/complex-c00-c12` /
`36cd341a8c14ce2d0a6790b287e5f7a7b0846cd3`

MPLAPACK tested commit: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` (`topic/octave-mplapack-complex-mpfr-scope`)

gmpfrxx_mkII tested commit: `32a7fb797202cdf92312ed9d133f96fdbcda590a` (`main`)

Upstream fixes:

- MPLAPACK `a59e5a0a4`: install the required `mplapack_mpfr_precision.h`
  MPFR scope header and include it from the public MPFR interfaces.

Blockers: none.

Full regression status: C12 PASS. C00 storage/scope/TLS/lifetime/special
value probe PASS at 128, 256, 512, 1024, and 2048 bits under ASan/UBSan/LSan;
C01 scalar construction/conversion, C02 dense complex construction,
inspection/indexing/assignment, C03 real/imag/conj/transpose/ctranspose, C04
complex element-wise arithmetic, C05 complex Cgemm, C06 complex Cgesv, and C07
complex rank-revealing `Cgelsy` tests PASS; C07 native and public walls include
the complete M00-M23 real regression wall. C06 exercised multiple RHS,
installed `mplapackint` pivots, singular behavior, 1024/2^-700 and
2048/2^-1500 real and imaginary tails, ambient precision, input immutability,
and output lifetime. C07 audited `Cgelsy`, `Cgelss`, and `Cgelsd`, and
exercised full-rank, rank-deficient, minimum-norm, precision-sensitive rank,
workspace, mixed-operand, ambient precision, immutability, and lifetime
behavior. C08 exercised selected-triangle Hermitian upper/lower Cholesky,
diagonal imaginary handling, partial non-PD status, one-/two-output behavior,
ambient precision, input immutability, output lifetime, and real `Rpotrf`
parity.
C09 exercised full/economy/wide complex QR, R-only dispatch, exact R zeros,
complex orthogonality and reconstruction, workspace queries, 1024/2^-700 and
2048/2^-1500 canaries, ambient precision, immutability, lifetime, and real QR
parity. C10 exercised full/economy/wide pivoted complex QR, exact JPVT
permutation mapping for matrix/vector outputs, reconstruction, orthogonality,
1024/2048-bit pivot-order canaries, ambient precision, immutability,
lifetime, empty shapes, and real Rgeqp3 parity.

Full regression status: C11 PASS. The full native real+complex sanitizer wall
and complete public M01-M23+C01-C11 wall pass. C11 mixed real/complex
promotion, Cgemm/Cgesv/Cgelsy participation, concat, assignment, structural
reshape, builtin-double mixing, no-demotion, ambient precision, lifetime, and
the full native/public C11 walls pass. C11L complex `Cgetrf` packed/two-output/
matrix-permutation/vector-permutation LU, rectangular and singular factors,
source-precision pivots, ambient precision, immutability, lifetime, and the
full native/public C11L walls pass.

C12 API, documentation, compatibility firewall, complete real/complex
regression, precision, TLS/thread, sanitizer, package lifecycle, and upstream
provenance gates pass. The development archive name and checksum are recorded
in the repository-only root master report `c12-report.md`.

Final state: `COMPLEX GOAL PASS`, `REAL-COMPLEX-API-CLOSED`,
`DEPENDENCY-FREEZE-READY`.

Release policy: MPLAPACK 3.0.1 remains a planned dependency version. No
release commit, archive, or final tags are frozen in C00-C12.
