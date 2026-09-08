# T05 report — gamma/erf dependency audit

## Result

`T05 PASS — REAL GAMMA/ERF FAMILY CLOSED`

The frozen gmpfrxx_mkII 1.4.1 tree at `32a7fb797202cdf92312ed9d133f96fdbcda590a`
(tag `v1.4.1`) provides released MPFR wrappers for `erf`, `erfc`, `gamma`,
and `lngamma`.  The exact public surface is in
`include/gmpfrxx_mkII/detail/mpfr_impl.hpp`; its tests compile and compare the
wrappers against the corresponding MPFR C APIs and verify operand-precision
preservation.

## Controller metadata

| Field | Value |
|---|---|
| Repository | `octave-mplapack` plus frozen gmpfrxx audit |
| Branch | `topic/t00-t14-continuation` |
| Starting commit | `9e8bba0c40448ac76b727bfbf0a92090d198d5a7` |
| Implementation commit / tip | `f518ab973f023b4c89109cc95fd9a61ea9f961d1` |
| D03 baseline | `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31`, tag `v0.4.0` |
| Dependencies | gmpfrxx_mkII `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1`; MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` |
| Octave | GNU Octave 11.1.0 |
| API scope | `gamma`, `gammaln`, `lgamma`, `erf`, `erfc` real MP functions |
| Backend / algorithm | Released gmpfrxx MPFR wrappers through the native precision-scoped elementary bridge |
| Precision policy | Operand/source precision with MPFR operation scope and no hidden guard precision |
| Real/complex behavior | Real family is closed; complex inputs are explicitly rejected |
| Octave differential QA | Pole/domain mapping, aliases, special values, and wrapper-vs-MPFR checks |
| 1024/2048 QA | High-precision special-function canaries PASS in the controller wall |
| Sanitizers | Native ASan, UBSan, and LSan walls PASS in final controller run |
| Previous regression | T00–T04 and D03 M00–M23/C00–C12/S00–S08 walls passed |
| Status / TODO | PASS; remaining families: `docs/todo/T06-special-functions.md` |

## Implementation

The `mp` methods `gamma`, `gammaln`, `lgamma`, `erf`, and `erfc` dispatch through
the existing native elementary bridge.  The bridge calls the released
gmpfrxx wrappers under an operation-precision scope.  `gammaln` and `lgamma`
both implement Octave's logarithmic-gamma alias.  The complex policy is
explicitly real-only; complex inputs are rejected rather than routed through
an unrequested complex fallback.

gmpfrxx intentionally reports non-positive integer Gamma poles as domain
errors.  The Octave bridge maps those real poles to Octave-compatible signed
infinity (`gamma(+0)=+Inf`, `gamma(-0)=-Inf`, other poles `+Inf`) while
preserving `gammaln` pole infinity and NaN behavior.

## Focused evidence

The focused wall passed integer gamma, logarithmic-gamma aliasing, erf/erfc
complementarity, large-tail erfc, poles, signed zero, Inf/NaN, matrix
evaluation, complex rejection, and 1024/2048-bit `2^-700`/`2^-1500` canaries.

## Required real regression wall

`test/run_tests.m` passed M00–M23, C00–C12 including C11L, N00–N08, S00–S08,
and T00–T05.
