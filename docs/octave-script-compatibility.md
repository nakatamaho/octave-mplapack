# Ordinary Octave script compatibility

This document records the compatibility audit for `mplapack-interop`. The
tested runtime is GNU Octave 11.1.0 with the native MPFR/MPC `mp` type. A
function is marked `SUPPORTED` only after an actual public call and a native
precision/value test have passed.

## Classification

| Area | Classification | Evidence / current boundary |
|---|---|---|
| dense arithmetic, solve, factorization, eig, SVD, norm | SUPPORTED | Existing M00-M23, C00-C12/C11L, N00-N08 walls |
| `abs`, `arg`, `angle`, `sign` | SUPPORTED | S00 public scalar/matrix and complex tests |
| `isnan`, `isinf`, `isfinite`, `isreal` | SUPPORTED | S00 real/complex special-value tests |
| `isequal`, `isequaln` | SUPPORTED | S00 exact-value, shape, and NaN tests |
| `isscalar`, `isvector`, `ismatrix`, `isempty`, `isnumeric` | SUPPORTED | S00 generic predicate audit on mp values |
| `power`, elementary functions | SUPPORTED | S01 native MPFR/MPC power and elementary-function tests |
| reductions and extrema | SUPPORTED | S02 native MPFR/MPC reductions, NaN flags, dimensions, and min/max |
| comparisons, logicals, logical indexing, `find` | PLANNED-S03 | Not yet implemented in the S-series |
| matrix utilities and constructors | PLANNED-S04 | Existing structural API is narrower than this target |
| ranges, rounding, utility arithmetic | PLANNED-S05 | Not yet implemented in the S-series |
| descriptive statistics | PLANNED-S06 | Not yet implemented in the S-series |
| graphics boundary wrappers | PLANNED-S07 | No automatic graphics conversion is present yet |
| ordinary script corpus closure | PLANNED-S08 | Corpus is added after S00-S07 |
| sparse, symbolic, signal/image-specialized, ODE/PDE, optimization APIs | INTENTIONALLY-DEFERRED | Outside the dense ordinary-script target |
| general N-D support | INTENTIONALLY-DEFERRED | Current public mp contract is two-dimensional |

## S00 semantics

`abs` returns real MPFR magnitudes. `angle` and `arg` return real MPFR
arguments; complex inputs use MPC argument semantics and real signed-zero
inputs use the same quadrant behavior as Octave. `sign` uses native MPFR
signs for real values and native MPC `x/abs(x)` for nonzero complex values;
complex zero returns positive complex zero as in Octave.

The predicate methods return builtin logical scalars or matrices. A complex
value is NaN or infinite when either component has that property, and finite
only when both components are finite. `isequal` compares exact native values
and shape while treating NaNs as unequal; `isequaln` treats corresponding
NaNs as equal. No S00 mathematical path converts through binary64.

Generic structural predicates were audited rather than duplicated where
Octave already handles the `mp` class. `isnumeric` required the small public
`@mp/isnumeric` wrapper because Octave otherwise reports a classdef `mp`
object as nonnumeric.

## S01 semantics

Element-wise `.^` and `power` support real/complex `mp` operands, mixed
builtin real/complex operands, and existing 2-D singleton expansion. Scalar
`^` uses the same native principal-power path. Integer powers of square
matrices use exponentiation by squaring; negative powers use the existing
native inverse path before multiplication. Noninteger matrix powers remain
outside the supported surface.

The elementary wrappers use MPFR for real-domain values and MPC for complex
values. When a real input crosses a complex domain boundary, the complete
result is promoted to MPC at the stored operation precision. The positive
real-axis asin/acos branch fixtures are adjusted to match Octave's signed-zero
principal-branch convention. `expm1` and `log1p` use guarded MPC working
precision and never call builtin binary64 arithmetic.

## S02 semantics

`sum`, `prod`, `sumsq`, `cumsum`, and `cumprod` retain native MPFR/MPC
accumulators and default to the first non-singleton dimension. Explicit
dimensions, `"all"` reductions, `omitnan`/`includenan`, `native`/`default`,
and explicit `double` output are supported. Cumulative operations also accept
`forward` and `reverse`; `"all"` is rejected for cumulative forms. Complex
`sumsq` returns a real MPFR result formed from native MPC magnitudes.

`min` and `max` support dimension/all reductions, first-value indices,
pairwise scalar/matrix operands with two-dimensional singleton expansion, and
the practical NaN flags. Complex ordering uses the native magnitude/phase
comparison path by default; `ComparisonMethod` accepts `auto`, `real`, and
`abs` for the supported dense forms. Pairwise extrema do not return a second
index output.

## Known intentional stops

The compatibility firewall still rejects APIs that are outside the current
surface. Graphics conversion is not enabled by S00; when S07 adds it, the
conversion will be confined to the final plotting boundary and never reused
by numerical functions.
