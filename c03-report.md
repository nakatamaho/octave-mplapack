# C03 RESULT

Repository: `octave-mplapack`
Branch: `topic/complex-c00-c12`
Starting commit: `1938aa9`
Final implementation commit: `370887ec22b673c40c685268202757480e9c1ea3`
Branch tip at implementation gate: `370887ec22b673c40c685268202757480e9c1ea3`
PR: not opened; repository workflow uses the pushed topic branch.

## Dependency identity

- gmpfrxx_mkII: `32a7fb797202cdf92312ed9d133f96fdbcda590a` (`main`)
- MPLAPACK: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` (`topic/octave-mplapack-complex-mpfr-scope`)
- pkg-config: `mplapack_mpfr 3.0.1`
- runtime SONAME: `libmplapack_mpfr.so.3`

## Scope

- implemented: native and public `real`, `imag`, `conj`, non-conjugating
  transpose, and conjugate transpose for complex scalars and dense matrices;
- deferred: complex element-wise arithmetic, mixed real/complex closure, and
  complex BLAS/LAPACK dispatch.

## Architecture

Complex component extraction writes directly from MPC real/imag limbs into
uniform MPFR payloads. Conjugation and both transpose forms use direct MPC
operations and preserve matrix column-major ordering. Scalar results remain
scalar payloads; matrix results preserve shape with the existing 1x1
normalization convention.

## Precision

Every structural operation establishes an operation-local MPFR/MPC scope at the
source precision and uses explicit round-to-nearest native copies. Native and
public probes pass at 128, 512, 1024, and 2048 bits. No binary64 complex
arithmetic is used by these paths.

## Public semantics

`real(Z)` and `imag(Z)` return real `mp` values with the source shape and
precision. `conj(Z)` returns complex `mp`. `Z.'` performs transpose only and
`Z'` performs transpose plus conjugation. Existing real transpose and component
behavior remains on the real-only path.

## Native/backend audit

The bridge dispatches only complex payloads to the new MPC structural helpers;
real payloads continue to use the existing MPFR implementation. The helpers
operate on operation-owned result storage and use the controlled shared
`libmplapack_mpfr.so.3`; no builtin binary64 fallback is present.

## QA

- native: real M02-M22 gates plus C00 storage and C03 structural sanitizer
  probes PASS;
- public: M01-M23, C01, C02, and C03 suites PASS;
- 1024: complex component extraction, conjugation, transpose, and ctranspose
  precision PASS;
- 2048: complex component extraction, conjugation, transpose, and ctranspose
  precision PASS;
- ambient low/high: public operations after 1024-bit and 2048-bit ambient
  precision changes PASS;
- ASan: all native gates PASS;
- UBSan: all native gates PASS;
- LSan: all native gates PASS (`detect_leaks=1`);
- full real regression: native M02-M22 and public M01-M23 walls PASS.

## Upstream fixes

MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` adds and installs the
required `mplapack_mpfr_precision.h` scope header and includes it from the
public MPFR interfaces. No gmpfrxx_mkII fix was required.

## Gates

`G-C03-REAL`, `G-C03-IMAG`, `G-C03-CONJ`, `G-C03-TRANSPOSE`,
`G-C03-CTRANSPOSE`, `G-C03-SIGNED-ZERO`, and `G-C03-REAL-PARITY`: PASS.

`C03 PASS`

## Known limitations

Complex element-wise arithmetic, mixed-kind operations, and complex
BLAS/LAPACK are deferred to C04 and later.

## Recommended next action

Proceed to C04: implement complex element-wise arithmetic with explicit MPC
operation scopes, precision promotion, broadcasting, and special-value tests.
