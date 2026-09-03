# C02 RESULT

Repository: `octave-mplapack`
Branch: `topic/complex-c00-c12`
Starting commit: `66436ef`
Final implementation commit: `ca0c30a326598bbc846d06a49f2544addb0ea20a`
Branch tip at implementation gate: `ca0c30a326598bbc846d06a49f2544addb0ea20a`
PR: not opened; repository workflow uses the pushed topic branch.

## Dependency identity

- gmpfrxx_mkII: `32a7fb797202cdf92312ed9d133f96fdbcda590a` (`main`)
- MPLAPACK: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` (`topic/octave-mplapack-complex-mpfr-scope`)
- pkg-config: `mplapack_mpfr 3.0.1`
- runtime SONAME: `libmplapack_mpfr.so.3`

## Scope

- implemented: builtin complex-double dense construction, direct component conversion, uniform native complex matrix storage, scalar/slice/linear indexing, value-semantic complex assignment, precision promotion, explicit `double` conversion, direct display, and empty matrix shapes;
- deferred: complex arithmetic, structural complex operations, mixed real/complex closure, and complex BLAS/LAPACK dispatch.

## Architecture

Complex matrices own one contiguous column-major `mpc_class` payload. Selection and
assignment copy native MPC values directly; 1x1 selections normalize to a complex
scalar. Destructive assignment works on an operation-owned result, preserving the
public value semantics of `mp` copies.

## Precision

Construction uses the active `mpbits` precision for both real and imaginary
components. Matrix precision is uniform; assigning a higher-precision `mp` RHS
promotes the result to the maximum operand precision. No conversion through text
or binary64 is used except for the explicit public `double` operation.

## Public semantics

Builtin complex double matrices are accepted by `mp`. Supported indexing mirrors
the real dense API (`A(i,j)`, slices, indexed selections, linear indexing, and
`A(:)`). Complex scalar extraction returns a scalar; non-scalar selections return
matrices. Complex-to-complex assignment is deep and supports scalar, exact-shape,
and vector RHS forms without growth, deletion, or logical-assignment expansion.

## Native/backend audit

The C02 bridge dispatches complex matrices to the complex storage and inspection
paths. Component conversion is direct at the destination precision. The native
MPLAPACK MPFR scope header and shared `libmplapack_mpfr.so.3` are taken from the
controlled prefix; no builtin binary64 complex fallback is present.

## QA

- native: all real M02-M22 sanitizer/native gates PASS; complex storage scope,
  TLS, lifetime, special-value, and 128/256/512/1024/2048-bit probe PASS;
- public: M01-M23, C01, and C02 test suites PASS;
- 1024: complex matrix construction, promotion, deep-copy assignment, and
  conversion PASS;
- 2048: complex matrix construction, metadata, conversion, and display smoke
  PASS;
- ambient low/high: repeated public operations after `mpbits(1024)` and
  `mpbits(2048)` PASS with expected matrix precision;
- ASan: all native sanitizer gates PASS;
- UBSan: all native sanitizer gates PASS;
- LSan: all native sanitizer gates PASS (`detect_leaks=1`);
- full real regression: native M02-M22 wall and public M01-M23 wall PASS.

## Upstream fixes

MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` adds and installs the required
`mplapack_mpfr_precision.h` scope header and includes it from the public MPFR
interfaces. No gmpfrxx_mkII fix was required.

## Gates

`G-C02-CONSTRUCT`, `G-C02-STORAGE`, `G-C02-INDEX`, `G-C02-ASSIGN`,
`G-C02-DOUBLE`, `G-C02-DISP`, `G-C02-EMPTY`, `G-C02-LIFETIME`, and
`G-C02-REAL-REGRESSION`: PASS.

`C02 PASS`

## Known limitations

Complex structural operations, arithmetic, mixed-kind closure, and complex
BLAS/LAPACK are deferred to the following milestones.

## Recommended next action

Proceed to C03: implement `real`, `imag`, `conj`, transpose, and ctranspose for
complex `mp` values while preserving the one-operation/one-precision contract.
