# T05 report — gamma/erf dependency audit

## Result

`T05 PASS — REAL GAMMA/ERF FAMILY CLOSED`

The frozen gmpfrxx_mkII 1.4.1 tree at `32a7fb797202cdf92312ed9d133f96fdbcda590a`
(tag `v1.4.1`) provides released MPFR wrappers for `erf`, `erfc`, `gamma`,
and `lngamma`.  The exact public surface is in
`include/gmpfrxx_mkII/detail/mpfr_impl.hpp`; its tests compile and compare the
wrappers against the corresponding MPFR C APIs and verify operand-precision
preservation.

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
