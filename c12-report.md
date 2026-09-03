# COMPLEX C00-C12 RESULT

REAL_V0_1_RC_COMMIT: `0bef79cddd3fdd70abafdf38bc1a4ab492652d33`

COMPLEX_START_COMMIT: `4aed479ef9cb8dff24f0326e1c2ec2a7c1ed83a3`

COMPLEX_FINAL_COMMIT: `36cd341a8c14ce2d0a6790b287e5f7a7b0846cd3`

C12 report/status commit: `f3439178f6ca68615849d209b17d3db5917c698b`

The final tested implementation commit is the C12 commit above. The
subsequent report/status commit contains documentation only and does not
change the tested implementation.

## Milestones

- C00 PASS — complex storage/scope scaffold; implementation
  `20815013b1bd90d97451f3773028f0b557d95926`.
- C01 PASS — complex scalar construction/conversion; implementation
  `c9ad222c77be742ecfb30bc39e16548b68bdbb47`.
- C02 PASS — complex dense matrices; implementation
  `ca0c30a326598bbc846d06a49f2544addb0ea20a`.
- C03 PASS — complex structure; implementation
  `370887ec22b673c40c685268202757480e9c1ea3`.
- C04 PASS — complex element-wise arithmetic; implementation
  `0562e2713dcd6a91cd040aee622b6339dc472c46`.
- C05 PASS — complex `Cgemm`; implementation
  `6a485b0825d5b550b30f17c0b875e8e85ef59971`.
- C06 PASS — complex `Cgesv`; implementation
  `d70bc873fdb012579b326688cee79254547c9de7`.
- C07 PASS — complex rank-revealing solve; implementation
  `bc5b8b301e3fff23b5427599763b01a57cf9d2fb`.
- C08 PASS — complex `Cpotrf`; implementation
  `abf2c836b6b54b0bde1a87ecb2524369960a895a`.
- C09 PASS — complex `Cgeqrf`/`Cungqr`; implementation
  `ff2a86418ec90b53042bce8cae8d0312715a8950`.
- C10 PASS — complex `Cgeqp3`/`Cungqr`; implementation
  `570fa1b6a5047c133825183f4a3337bf81de4641`.
- C11 PASS — mixed real/complex API closure; implementation
  `64d8b1d296299afccfd1e77d459969f7a52221e2`.
- C11L PASS — mandatory complex `Cgetrf` LU; implementation
  `3bad050af108a6ca8739c97b91120e3053800ecc`.
- C12 PASS — real+complex release closure; implementation
  `36cd341a8c14ce2d0a6790b287e5f7a7b0846cd3`.

## Final API

Supported: complex scalar and dense two-dimensional matrix construction;
direct two-text scalar construction; scalar `char`, `double`, `disp`, and
inspection; indexing and in-bounds value-semantic assignment; `real`, `imag`,
`conj`, transpose, ctranspose, and 2-D reshape; `+`, `-`, `.*`, `./`, unary
signs, and `*`; square `\` through `Cgesv`; rectangular `\` through `Cgelsy`;
upper/lower `chol` through `Cpotrf`; full/economy QR through
`Cgeqrf`/`Cungqr`; pivoted QR through `Cgeqp3`/`Cungqr`; mixed real/complex
arithmetic, multiplication, solve, concatenation, and assignment; and LU
through `Cgetrf`.

Complex LU supports packed one-output, two-output `A=L*U`, three-output
`P*A=L*U`, and vector `A(p,:)=L*U` forms for square, rectangular, empty, and
singular matrices. Native `INFO` is checked and singular partial factors are
retained; the public wrapper follows real M21 and has no separate LU status
output. Structural permutation outputs are builtin real values.

All complex numerical paths use one operation precision and MPC/MPFR storage.
Destructive LAPACK calls receive operation-owned copies. Existing real-only
operations remain on their real MPFR kernels. There is no silent builtin
binary64 complex fallback; `double` is an explicit conversion only.

## Unsupported complex API

The C12 firewall cleanly rejects `eig`, `svd`, `det`, `inv`, `rank`, `cond`,
`norm`, unimplemented transcendentals (`sin`, `exp`, `sqrt`), power (`^`,
`.^`), ordered/equality/logical operations, sparse conversion, right
division, sparse/N-D forms, growth/deletion assignment, and unsupported
matrix text/cell forms. The audited rejection path has no crash, recursion,
or binary64 fallback.

## Final dependency development heads

### gmpfrxx_mkII

- final tested commit: `32a7fb797202cdf92312ed9d133f96fdbcda590a` on `main`;
- fixes required: none through C12.

### MPLAPACK

- final tested commit: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` on
  `topic/octave-mplapack-complex-mpfr-scope`;
- pkg-config: `mplapack_mpfr 3.0.1`;
- runtime: `libmplapack_mpfr.so.3`;
- required fix: installs `mplapack_mpfr_precision.h` and includes it from the
  public MPFR headers, supplying the uniform MPFR scope needed at complex
  LAPACK boundaries;
- no later C11L/C12 upstream fix was required.

### octave-mplapack

- final tested implementation commit:
  `36cd341a8c14ce2d0a6790b287e5f7a7b0846cd3`;
- branch: `topic/complex-c00-c12`;
- version: `0.2.0-dev`.

## Regression and gate evidence

- native real M01–M23 sanitizer/dependency wall: PASS;
- native complex C00–C11L ASan/UBSan/LSan wall: PASS;
- public M01–M23+C01–C11L+C12-firewall wall: PASS;
- all milestone gates C00, C01, C02, C03, C04, C05, C06, C07, C08, C09,
  C10, C11, mandatory C11L, and C12: PASS;
- 1024-bit/`2^-700` and 2048-bit/`2^-1500` precision tails: PASS across
  scalar, element-wise, `Cgemm`, `Cgesv`, `Cgelsy`, `Cpotrf`, QR, pivoted QR,
  mixed paths, and `Cgetrf`, with existing real canaries also passing;
- source-precision pivot-order canaries at 512/1024 bits: PASS;
- ambient low/high precision restoration, thread-local scope, output lifetime,
  and public-input immutability: PASS;
- controlled reference-backend dependency/provenance and shared-library
  linkage checks: PASS;
- reproducible development archive:
  `mplapack-0.2.0-dev.tar.gz`, SHA256
  `e81ecd3c427bf25a394af352b6d3e8e8b4d1b13d2854babbed279ef6fede9d6e`,
  size `227922` bytes;
- isolated package install/load/unload/uninstall/reinstall/reload and
  real+complex smoke: PASS;
- no Debian package was created, no Launchpad upload was made, no PPA work
  was started, and `octave-mplapack-ppa` was not modified.

## Release handoff

MPLAPACK 3.0.1 remains a planned dependency version. No final dependency
release commit, tag, archive, or package release is frozen by C00–C12. The
next separate goal is D00 — Dependency Release Freeze.

## Result

`COMPLEX GOAL PASS`

`REAL-COMPLEX-API-CLOSED`

`DEPENDENCY-FREEZE-READY`
