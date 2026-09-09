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
| descriptive statistics | SUPPORTED | S06 native MPFR/MPC mean, median, variance, standard deviation, range, and bounds |
| graphics boundary wrappers | SUPPORTED | S07 private final-boundary conversion for common line graphics |
| ordinary script corpus closure | SUPPORTED | S08 six-script corpus, structural audit, and intentional-stop firewall |
| T00–T14 advanced dense numerics | SUPPORTED | T00–T14 focused walls and final controller wall; see `docs/advanced-numerics-compatibility.md` |
| `fminbnd`, `fminsearch` | SUPPORTED | T14 MPFR bounded/simplex optimization tests |
| `fminunc` | INTENTIONALLY-DEFERRED | `docs/todo/T14-fminunc.md` |
| scalar `integral`, `quadgk` | SUPPORTED | T13 MPFR/MPC adaptive quadrature tests |
| `ArrayValued` quadrature | INTENTIONALLY-DEFERRED | `docs/todo/T13-array-valued-quadrature.md` |
| 1-D/2-D interpolation | SUPPORTED | T10/T11 native MPFR/MPC interpolation tests |
| N-D interpolation | INTENTIONALLY-DEFERRED | `docs/todo/T11-ND-interpolation.md` |
| `meshgrid` with MP arguments and volume graphics | INTENTIONALLY-DEFERRED | `docs/todo/T08-meshgrid.md`, `docs/todo/T08-volume-graphics-after-ND.md` |
| sparse, symbolic, signal/image-specialized, ODE/PDE APIs | INTENTIONALLY-DEFERRED | Outside the dense ordinary-script and advanced-numerics targets |
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

## S06 semantics

`mean` supports the default and explicit two-dimensional dimensions, `"all"`,
`omitnan`/`includenan`, and an explicit `"double"` output boundary. Real
means use MPFR accumulators; complex means use MPC accumulators and retain
their complex result. `median` sorts with native MPFR ordering for real data
and native magnitude/phase ordering for complex data, then averages the two
middle native values for even-sized slices.

`var` and `std` support the common normalization forms `0` (N-1) and `1` (N),
the default and explicit dimensions, `"all"`, NaN flags, and the optional
second output containing the mean. Complex variance and standard deviation
are real MPFR values computed from native squared magnitudes, while their
second output is the native complex mean. The implementation first computes
the mean and then accumulates squared deviations, avoiding the
catastrophically cancelling sum-of-squares formula.

`range` and `bounds` use native minimum/maximum ordering and default to
`omitnan`, matching Octave's statistics functions. Their complex ordering is
the same native magnitude/phase ordering used by the existing dense extrema
surface; complex `range` subtracts the selected native lower bound from the
selected upper bound. Empty/all-NaN slices produce native NaN results.

S06 accepts only the dense two-dimensional statistics surface. Weighted
statistics, multi-dimensional vector-dimension forms, and unrelated
statistics families remain outside this milestone. No statistics path routes
through builtin binary64 arithmetic or through a complex kernel for a
real-only input.

## S07 graphics semantics

The `plot`, `semilogx`, `semilogy`, `loglog`, `scatter`, `stem`, and `stairs`
class wrappers convert only `mp` data to builtin double immediately before
calling the host graphics routine. The private graphics helper leaves axes
handles, line-style strings, property/value pairs, and other non-`mp`
arguments unchanged. It therefore supports single-series, multiple-series,
axes-handle-first, and mixed builtin-double/`mp` calls. A complex `mp` vector
is passed as a builtin complex vector at this boundary, matching Octave's
single-complex-vector plotting behavior (real component on x, imaginary on y).

This conversion is intentionally confined to visualization. It is not used by
any numerical operation, and very small or very large arbitrary-precision
values can become zero or infinity when represented as graphics doubles.
Transform data in `mp` first when that range matters, for example:

```octave
plot (bits, double (log10 (residual_mp)))
```

The documented Grcar example is:

```octave
A = mp (gallery ("grcar", 32));
e = eig (A);

plot (real (e), imag (e), "o");
axis equal;
grid on;
```

Balance/nobalance overlays use the same final-boundary wrappers:

```octave
eb = eig (A, "balance");
en = eig (A, "nobalance");
plot (real (eb), imag (eb), "o");
hold on;
plot (real (en), imag (en), "x");
```

Surface and matrix graphics beyond this line-graphics bridge remain S08
closure candidates. No S07 numerical path uses a binary64 fallback.

## S08 ordinary script corpus

S08 closes the ordinary dense-script corpus with six executable scripts. The
scripts cover the following complete flows:

* Script A: `linspace`, power, `sqrt`, `exp`/`log`, trigonometric functions,
  reductions, and plotting.
* Script B: comparisons, `isfinite`, logical indexing, extrema, `mean`, and
  `std`.
* Script C: `like` constructors, `diag`, triangular extraction, replication,
  flips, and concatenation.
* Script D: norm, right division, eigenvalues, SVD, rank, and condition.
* Script E: the Grcar eigenvalue workflow, residual plotting, and
  balance/no-balance comparison.
* Script F: negative-domain promotion, complex elementary functions,
  magnitude/phase operations, complex statistics, and complex plotting.

The sequence methods used by the corpus are also native. `sort` supports
dimensions one and two, ascending/descending order, stable ties, one-based
indices within the sorted dimension, and MPFR comparison. Complex `sort`
orders by native MPC magnitude and then phase; ascending NaNs are last and
descending NaNs are first. `diff` supports order and dimension forms and
performs repeated MPFR/MPC subtraction at the source precision. Order-zero
`diff` returns a value-semantic copy, while the scalar default positive-order
case produces the same empty result shape as Octave.

The S08 structural audit covers `length`, `size`, `rows`, `columns`,
`numel`, `ndims`, and `isempty`, including empty matrices. The 1024-bit
`2^-700` and 2048-bit `2^-1500` tails verify that sequence results retain the
operation precision and that changing the ambient default afterward does not
rewrite stored values. Native sequence tests run under ASan and UBSan.

Surface graphics such as `mesh` remain intentionally rejected. The common
line-graphics bridge from S07 remains the supported visualization boundary.
Unsupported calls are tested as explicit stops, and builtin non-`mp` calls
remain available to Octave. No ordinary-script numerical path falls back to
builtin binary64 complex arithmetic.

## Known intentional stops

The compatibility firewall still rejects APIs that are outside the current
dense two-dimensional surface, including surface/matrix graphics such as
`mesh`, sparse and symbolic workflows, and general N-D storage. The accepted
line-graphics conversion remains confined to the final plotting boundary and
is never reused by numerical functions.
