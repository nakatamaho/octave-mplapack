# T06 report — special-function backend audit

## Result

`T06 PASS — SPECIAL-FUNCTION BACKEND AUDIT CLOSED`

The complete family matrix is in
`docs/special-functions-backend-matrix.md`.  T06 is an audit/defer milestone;
it adds no speculative numerical implementation and does not change the
frozen dependency stack.

## Backend findings

The audit used gmpfrxx_mkII 1.4.1 at
`32a7fb797202cdf92312ed9d133f96fdbcda590a` (`v1.4.1`), specifically
`include/gmpfrxx_mkII/detail/mpfr_impl.hpp`.  The released wrapper inventory
contains `digamma`, `gamma_inc`, `beta`, `eint`, `zeta`, `zeta_ui`, `j0`,
`j1`, `y0`, `y1`, and `ai`, in addition to the T05 `gamma`/`erf` family.

These primitives were recorded as direct-backend capabilities only.  They
were not exposed as package functions because their Octave contracts still
need independent treatment: `gamma_inc` is not equivalent to Octave's
normalized `gammainc`, the incomplete-beta and inverse-error families have no
frozen arbitrary-precision backend, and the Bessel/Airy primitives cover only
partial order/output surfaces.

## Implemented and deferred surface

T05 remains the only newly implemented special-function family: `gamma`,
`gammaln`, `lgamma`, `erf`, and `erfc`.  The matrix gives every other audited
family a precise classification and TODO.  Deferred APIs are explicitly
firewalled; no builtin binary64 conversion is used.

## Focused evidence

`test/t06_special_function_firewall.tst` passed the rejection checks for
`gammainc`, `betainc`, inverse/scaled error functions, `expint`, Bessel
families, `airy`, and `psi`, plus a 1024-bit T05 precision canary.

## Required real regression wall

`test/run_tests.m` passed M00–M23, C00–C12 including C11L, N00–N08,
S00–S08, and T00–T06.

## Contract audit

No raw MPFR call, builtin binary64 fallback, real-only-to-complex rerouting,
or gmpfrxx source change was introduced.  Existing T05 calls retain their
one-operation/one-precision MPFR scope.
