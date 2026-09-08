# T06 report — special-function backend audit

## Result

`T06 PASS — SPECIAL-FUNCTION BACKEND AUDIT CLOSED`

The complete family matrix is in
`docs/special-functions-backend-matrix.md`.  T06 is an audit/defer milestone;
it adds no speculative numerical implementation and does not change the
frozen dependency stack.

## Controller metadata

| Field | Value |
|---|---|
| Repository | `octave-mplapack` plus frozen gmpfrxx audit |
| Branch | `topic/t00-t14-continuation` |
| Starting commit | `f518ab973f023b4c89109cc95fd9a61ea9f961d1` |
| Implementation commit / tip | `e6a4daba2f47bdfc85eae08473db418d6348b729` |
| D03 baseline | `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31`, tag `v0.4.0` |
| Dependencies | gmpfrxx_mkII `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1`; MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` |
| Octave | GNU Octave 11.1.0 |
| API scope | Backend inventory and firewall decisions for T06 special-function families |
| Backend / algorithm | Released gmpfrxx/MPFR wrapper inventory; no new numerical algorithm |
| Precision policy | Any future wrapper must use one-operation/one-precision MPFR/MPC; current audit uses native APIs |
| Real/complex behavior | T05 real family remains real-only; unimplemented complex families are rejected |
| Octave differential QA | Signature/domain/tail/output-contract audit recorded in the family matrix |
| 1024/2048 QA | Existing precision wall PASS; deferred families have no canary claim |
| Sanitizers | Native ASan, UBSan, and LSan walls PASS in final controller run |
| Previous regression | T00–T05 and D03 M00–M23/C00–C12/S00–S08 walls passed |
| Status / TODO | PASS; all family TODOs: `docs/todo/T06-special-functions.md` |

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
