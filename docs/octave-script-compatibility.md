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
| comparisons, logicals, logical indexing, `find` | SUPPORTED | S03 native MPFR/MPC comparison, truth, indexing, and find tests |
| matrix utilities and constructors | SUPPORTED | S04 native MPFR/MPC `diag`, `triu`/`tril`, `repmat`, flips, `rot90`, `cat(1/2)`, and `like` constructors |
| ranges, rounding, utility arithmetic | SUPPORTED | S05 native MPFR/MPC range, spacing, rounding, and utility tests |
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

## S03 semantics

Real `==`, `~=`, `<`, `<=`, `>`, and `>=` use direct MPFR comparisons with
Octave-compatible scalar and two-dimensional singleton expansion. Complex
`==` and `~=` compare the native MPFR real and imaginary components; NaN is
unequal. Complex ordered comparisons remain a deliberate firewall because no
numeric ordering is defined for MPC values.

`logical`, `&`, `|`, `xor`, and `~` classify native MPFR/MPC values directly;
NaN is true and a complex value is true when either component is nonzero.
`any` and `all` support the default or explicit dimension and `"all"`. `find`
supports linear, row/column, and three-output forms, including a count and
`"first"`/`"last"` direction. Dense numeric vector and logical-mask indexing
and value-semantic assignment follow column-major order.

## S04 semantics

`diag` constructs or extracts two-dimensional diagonals with an optional
offset. `triu` and `tril` preserve the dense matrix shape and support an
optional diagonal offset; the sparse-style `"pack"` form is intentionally
rejected because the package's dense two-dimensional contract has no packed
output type. `repmat` accepts scalar repetition counts or a two-element
dimension vector.

`flip`, `fliplr`, and `flipud` copy rows or columns natively, and `rot90`
supports arbitrary integer quarter-turn counts. `cat(1, ...)` and
`cat(2, ...)` use the existing native vertical and horizontal concatenation
paths; dimensions above two remain rejected. `zeros`, `ones`, `eye`, `NaN`,
and `Inf` support the explicit `"like"` form when the template is an `mp`
value. These constructors preserve template precision and real/complex
storage kind, and all special values are written through MPFR/MPC directly.

## S05 semantics

The two- and three-argument colon forms construct real MPFR row vectors by
repeated native MPFR addition at the operation precision. Increasing,
decreasing, empty, negative-step, high-precision decimal-step, and zero-step
cases are covered; a step that rounds away at the selected precision is
rejected instead of silently looping. Complex colon ranges are an explicit
unsupported boundary.

`linspace` uses native MPFR for real endpoints and MPC for complex endpoints,
with exact first and last values, Octave-compatible default counts, and the
`n == 0`/`n == 1` cases. `logspace` uses native MPFR powers of ten and retains
the supplied final endpoint for Octave's `pi` special case. Complex logspace
is intentionally rejected.

`floor`, `ceil`, `fix`, and `round` operate element-wise through MPFR and
retain the source precision. `rem`, `mod`, `hypot`, and `atan2` use native
MPFR with two-dimensional singleton expansion; remainder/modulus signs follow
their respective Octave conventions. `signbit` exposes native MPFR sign bits
as logical values, including signed zero. `eps` returns the local MPFR spacing
above each stored value, so it is neither binary64-derived nor a constant.
Complex rounding, remainder/modulus, utility forms, `signbit`, and `eps` are
rejected explicitly where the dense mp contract is real-only.

All S05 numerical paths avoid binary64 generation and preserve the operation's
MPFR/MPC precision scope. The dedicated S05 tests include 1024-bit `2^-700`
and 2048-bit `2^-1500` canaries and ambient-precision restoration.

## Known intentional stops

The compatibility firewall still rejects APIs that are outside the current
surface. Graphics conversion is not enabled by S00; when S07 adds it, the
conversion will be confined to the final plotting boundary and never reused
by numerical functions.
