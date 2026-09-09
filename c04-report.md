# C04 RESULT

Repository: `octave-mplapack`
Branch: `topic/complex-c00-c12`
Starting commit: `b7ad799`
Final implementation commit: `0562e2713dcd6a91cd040aee622b6339dc472c46`
Branch tip at implementation gate: `0562e2713dcd6a91cd040aee622b6339dc472c46`
PR: not opened; repository workflow uses the pushed topic branch.

## Dependency identity

- gmpfrxx_mkII: `32a7fb797202cdf92312ed9d133f96fdbcda590a` (`main`)
- MPLAPACK: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` (`topic/octave-mplapack-complex-mpfr-scope`)
- pkg-config: `mplapack_mpfr 3.0.1`
- runtime SONAME: `libmplapack_mpfr.so.3`

## Scope

- implemented: complex scalar and matrix `+`, `-`, `.*`, `./`, unary `-`,
  mixed real/complex `mp` operands, builtin real/complex double operands,
  precision promotion, singleton expansion, empty shapes, and special values;
- deferred: complex matrix multiplication, solves, factorizations, mixed-kind
  concatenation/assignment closure, and complex LU.

## Architecture

The C04 kernel uses `MpcElementwiseOperand` views for real MPFR and complex MPC
payloads, plus operation-owned MPC storage for builtin doubles. It allocates a
uniform result at the maximum participating `mp` precision and copies operands
directly into operation-precision temporaries before native MPC arithmetic.

## Precision

`p_op = max(all participating mp precisions)`. Builtin binary64 values are
converted directly at `p_op` and cannot raise it. Native and public tests pass
at 128/512/1024/2048 bits, including ambient-precision checks.

## Public semantics

Real/real operations retain real result kind and the existing MPFR path. Any
complex operand produces complex `mp`, including real/complex mixed operands;
complex results are never demoted when the imaginary component is zero. The
accepted real M11 singleton expansion model applies to complex matrices.

## Native/backend audit

Real-only operations are dispatched before the complex branch and continue to
use the existing MPFR kernels. Complex operations use explicit MPC add,
subtract, multiply, divide, and negate calls under `MpfrMpcPrecisionScope`.
No builtin binary64 complex arithmetic is used as a fallback.

## QA

- native: real M02-M22 gates plus C00 storage, C03 structural, and C04
  arithmetic sanitizer probes PASS;
- public: M01-M23 and C01-C04 suites PASS;
- 1024: mixed-precision complex arithmetic and ambient-precision PASS;
- 2048: mixed-precision/ambient precision canary PASS;
- ambient low/high: result precision remains operand-derived after 128, 1024,
  and 2048-bit default changes PASS;
- ASan: all native gates PASS;
- UBSan: all native gates PASS;
- LSan: all native gates PASS (`detect_leaks=1`);
- full real regression: native M02-M22 and public M01-M23 walls PASS.

## Upstream fixes

MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` adds and installs the
required `mplapack_mpfr_precision.h` scope header and includes it from the
public MPFR interfaces. No gmpfrxx_mkII fix was required.

## Gates

`G-C04-SCALAR`, `G-C04-MATRIX`, `G-C04-MIXED-KIND`, `G-C04-MIXED-PRECISION`,
`G-C04-BROADCAST`, `G-C04-SPECIAL`, and `G-C04-REAL-REGRESSION`: PASS.

`C04 PASS`

## Known limitations

Complex matrix multiplication, solves, factorizations, mixed concatenation and
assignment closure, and complex LU remain deferred.

## Recommended next action

Proceed to C05: add complex matrix multiplication through the native `Cgemm`
backend with operation-precision and operation-owned output guarantees.
