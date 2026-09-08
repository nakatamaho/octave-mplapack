# T00-T14 CONTROLLER RESULT

## Result

`T00-T14 CONTROLLER PASS`

Acceptance: `T00-T14: ACCEPT`

All required T00 through T14 milestones passed in order. T05R1 was executed
as the required late checkpoint and was recorded as not needed because T05
was already closed. The final tested controller commit is
`8ba6d849fa188765b372d9aa9f899d9de98a78cf` on
`topic/t00-t14-continuation`. The current branch tip may be a later
documentation-only report update.

The T00–T14 development milestone history referenced gmpfrxx_mkII
`32a7fb797202cdf92312ed9d133f96fdbcda590a` (`v1.4.1`) and the
historical MPLAPACK development/interface commit
`a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`.

Neither dependency repository was modified during T00–T14.

For D04 release-candidate QA, the authoritative MPLAPACK dependency is
instead the MPLAPACK 3.0.1 release candidate identified in the following
section by commit, tarball, and SHA256.

## D04 release-candidate provenance

`T00-T14: ACCEPT` and `D04-READY: YES` are the accepted handoff state. The
authoritative MPLAPACK dependency for the current D04 candidate is MPLAPACK
3.0.1 commit `c21a9f56224308afda9e7424ca9928d4cf840f7a`, represented by the
local release-candidate archive `~/src/mplapack-3.0.1.tar.xz` and the archived
QA copy `release/logs/20260907_143628/source/mplapack-3.0.1.tar.xz`. The
expected SHA256 for both artifacts is
`f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1`; the QA
evidence directory is `release/logs/20260907_143628/`.

The local candidate archive used by the installer was verified in the current
environment to have this hash. D04 must verify that the archived QA copy has
the same hash before the source freeze. Until its release process completes,
MPLAPACK must be described as the `3.0.1 release candidate`, not as finally
released MPLAPACK 3.0.1.

Historical T-series identities such as `a59e5a0...` and earlier release-
preparation commits such as `fa3ccb...` remain historical milestone
provenance. They are not D04 release-QA provenance and require no
reconciliation. D04 must preserve and verify the exact release-candidate
identity above, or use an installed build demonstrably derived from it; no
rebuild is required solely to reconcile those historical Git SHAs.

## D03 baseline

Name: `mplapack-interop`

Version: `0.4.0`

Freeze commit: `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31`

Tag: `v0.4.0`

Archive: `/home/docker/src/mplapack-interop-0.4.0.tar.gz`

SHA256: `6bc87d42fbda49fa72830db34fbede7b8b9f46b7614b14dc53e7619c7781536c`

The D03 tag, archive, and freeze commit remain immutable.

## Development identity

Name: `mplapack-interop`

Version: `0.5.0-dev`

Final tested controller HEAD: `8ba6d849fa188765b372d9aa9f899d9de98a78cf`

## T00 Schur/QZ

State: `PASS — SCHUR/QZ CORE CLOSED`

Implemented: `hess`, `balance`, `schur`, and `qz` for real and complex MP
values, including correct Octave reconstruction orientations.

Deferred helpers: generalized pair balancing and unsupported optional helper
surfaces remain explicitly unimplemented.

Backend: MPFR `Rgehrd/Rorghr/Rgees/Rgges` and MPC
`Cgehrd/Cunghr/Cgees/Cgges`, with the required Cgges real workspace.

Precision QA: 1024-bit `2^-700`, 2048-bit `2^-1500`, source precision,
ambient precision, and full real/complex regression passed.

## T01 advanced dense utilities

pinv: `PASS`, MPFR/MPC SVD and Moore–Penrose identities

null: `PASS`, arbitrary-precision SVD null space

orth: `PASS`, arbitrary-precision SVD range basis

rref: `PASS`, scale-aware MPFR/MPC pivoting and tolerance

kron: `PASS`, native real/complex element construction

State: `PASS — ADVANCED DENSE UTILITIES CLOSED`

## T02 matrix functions

expm: `PASS`, precision-adaptive Taylor scaling/squaring

logm: `PASS`, Schur inverse scaling and MP Mercator series

sqrtm: `PASS`, Schur triangular recurrence with complex promotion where needed

Algorithm references: published Schur-function and scaling/series methods;
all stopping tests are p-aware MP values.

State: `PASS — MATRIX FUNCTIONS CLOSED`

## T03 polynomial

polyval: `PASS`, element-wise MP Horner evaluation

polyvalm: `PASS`, matrix Horner evaluation

roots: `PASS`, MP companion/eigensolver path

poly: `PASS`, roots and characteristic polynomial forms

conv/deconv: `PASS`, MPFR/MPC arithmetic

polyder/polyint: `PASS`, audited derivative/product/quotient and integral forms

compan: `PASS`, MP companion construction

Deferred: `polyfit` and `polyeig`

State: `PASS — POLYNOMIAL CORE CLOSED`

## T04 sets

unique: `PASS`

union: `PASS`

intersect: `PASS`

setdiff: `PASS`

setxor: `PASS`

ismember: `PASS`

State: `PASS — EXACT SET OPERATIONS CLOSED`, with native exact equality/order,
rows/index forms, NaN, Inf, and signed-zero tests.

## T05 gamma/erf

Initial state: dependency wrapper audit required

gmpfrxx identity: gmpfrxx_mkII `32a7fb797202cdf92312ed9d133f96fdbcda590a`,
tag `v1.4.1`

Wrappers: `gamma`, `gammaln`, `lgamma`, `erf`, `erfc`

TODO: remaining special-function families are handled by T06's family matrix

State: `PASS — REAL GAMMA/ERF FAMILY CLOSED`

## T06 special functions

Backend matrix: `docs/special-functions-backend-matrix.md`

Implemented families: T05 gamma/log-gamma and erf/erfc

Deferred families: incomplete gamma/beta, inverse/scaled error functions,
Bessel, Airy, polygamma, and other APIs without a complete approved contract

TODOs: family-specific entries in the backend matrix

State: `PASS — SPECIAL-FUNCTION BACKEND AUDIT CLOSED`; every deferred public
surface has an explicit firewall and no binary64 fallback.

## T07 serialization

Hook/API: legacy `@mp` `saveobj`/`loadobj` hooks plus native bridge validation

Schema: `octave-mplapack-mp`

Schema version: `1`

Exact value encoding: canonical MPFR/MPC element text in column-major order

Precision preservation: stored per-value uniform precision, retained on load

Complex: independent canonical real/imaginary component encoding

Special values: signed zero, Inf, and NaN retained

Cross-process: 2048-bit binary save/load passed in an independent Octave
process

Save formats: Octave binary and text, with direct hook tests

State: `PASS — EXACT MP SERIALIZATION CLOSED`

## T08 3-D graphics

plot3: `PASS`

scatter3: `PASS`

mesh: `PASS`

surf: `PASS`

contour3: `PASS`

Additional: `meshc`, `surfc`, and `waterfall` pass; complex-derived real/imag
data and graphics property forwarding pass.

Boundary conversion: explicit final conversion of MP data to builtin double at
the graphics boundary only.

Volume graphics deferred: `slice`, `isosurface`, and general volume/N-D field
graphics

State: `PASS — 3-D GRAPHICS CORE CLOSED`

## T09 RNG

Public API: `mprand`, `mprandn`, `mprandi`, `mprng`

Algorithm: fixed `xorshift128plus-v1` with two uint64 state words and
SplitMix64 seed expansion

Seed/state API: deterministic seed, get/set state, reset, and validated state

State schema: versioned state with `algorithm`, `version = uint64(1)`, and
`state = uint64([s0,s1])`

Uniform endpoint convention: p-bit direct MPFR bits on `[0,1)`

Normal algorithm: MPFR-only Box–Muller with zero-`u1` rejection

Integer rejection: inclusive unbiased rejection sampling, including signed
bounds

Cross-platform deterministic QA: fixed-width unsigned sequence specified and
Linux implementation passed; independent macOS/Windows execution was not
available in this container and is not claimed.

State: `PASS — ARBITRARY-PRECISION RNG CORE CLOSED`

## T10 1-D interpolation

interp1: `PASS`, nearest/previous/next/linear/pchip/spline, extrapolation,
descending grids, and pp form

pchip: `PASS`, real Fritsch–Carlson and complex weighted Hermite slopes

spline: `PASS`, MP not-a-knot coefficients

ppval: `PASS`, scalar-output MP Horner evaluation

pp helpers: `mkpp`, `unmkpp`, `ppder`, and `ppint` `PASS`

State: `PASS — 1-D INTERPOLATION CLOSED`; matrix-valued/N-D PP output remains
outside this scalar-output milestone.

## T11 2-D interpolation

interp2: `PASS`, vector/matrix grids, descending axes, nearest/linear/tensor
pchip/tensor spline, complex values, extrapolation, and MP queries

N-D deferred: `interp3`, `interpn`, and general N-D interpolation; see
`docs/todo/T11-ND-interpolation.md`

State: `PASS — 2-D INTERPOLATION CORE CLOSED`

## T12 nonlinear equations

fzero: `PASS`, MP bracket expansion and safeguarded secant/bisection

fsolve: `PASS`, MP Newton, finite-difference Jacobian, user Jacobian callback,
and MP backtracking

callback precision: callbacks receive MP inputs and must return finite real MP
values; double/complex callbacks are rejected

State: `PASS — NONLINEAR EQUATION CORE CLOSED`; complex nonlinear callback
semantics are intentionally outside T12.

## T13 quadrature

Public APIs: `integral` and `quadgk`

Algorithm: adaptive tanh-sinh/double-exponential quadrature using the
Takahasi–Mori map and MP derivative weights

Infinite intervals: finite, semi-infinite, and two-sided infinite transforms

Complex integrands: finite scalar complex MP callback results supported

Precision: all nodes, weights, transformations, tolerances, and error
estimates are MPFR/MPC; 512-bit 80-decimal-scale QA passed

State: `PASS — ARBITRARY-PRECISION QUADRATURE CORE CLOSED`; finite waypoints,
endpoint singularity, and MP AbsTol/RelTol pass. ArrayValued is explicitly
unsupported.

## T14 optimization

fminbnd: `PASS`, bounded MP golden-section search with MP objective/coordinate
values and p-aware TolX

fminsearch: `PASS`, MPFR Nelder–Mead simplex with common Octave options/output

fminunc: `DEFERRED`, documented in `docs/todo/T14-fminunc.md`

State: `PASS — OPTIMIZATION CORE CLOSED`

## T05R1

Rechecked: yes, once, at the current T14 HEAD

Dependency available: yes; T05 was already closed

Closure: `T05R1 NOT NEEDED — T05 ALREADY CLOSED`

Final T05 state: `PASS`

## High precision

1024: `PASS`, including `2^-700` source-precision canaries

2048: `PASS`, including `2^-1500` source-precision canaries

ambient independence: `PASS`, explicit precision changes and restoration are
covered across real/complex APIs and lifecycle tests

source precision: `PASS`, operation-owned stored precision is retained and no
binary64 numerical fallback is used

## Regression

M: `PASS`, M00–M23

C: `PASS`, C00–C12 including mandatory C11L

N: `PASS`, N00–N08

S: `PASS`, S00–S08

T: `PASS`, T00–T14

Grcar: `PASS`

serialization: `PASS`, exact binary/text and cross-process tests

graphics: `PASS`, 3-D headless graphics boundary suite

RNG: `PASS`, deterministic state/seed and precision suite

ASan: `PASS`, native real and complex targets

UBSan: `PASS`, native real and complex targets

LSan: `PASS`, leak detection enabled in native sanitizer targets

package lifecycle: `PASS`, clean archive install/load/unload/uninstall/reinstall,
help, examples, and smoke coverage

deferred firewall: `PASS`, unsupported T06/T08/T11/T14 surfaces reject cleanly

The final evidence was run with GNU Octave 11.1.0, the installed MPLAPACK
MPFR 3.0.1 interface, gmpfrxx_mkII 1.4.1, and the Linux container's native
compiler/toolchain. The final `tools/local-ci.sh` run passed after the
development-version allow-list repair in commit
`246f9dafe3a1576172315c7b6667aeb44a3a1e4e`.

## Deferred inventory

The complete public-surface and handoff index is
`docs/advanced-numerics-compatibility.md`.

T00: optional Schur/QZ ordering helpers; see
`docs/todo/T00-schur-optional-ordering.md`.

T02: `funm`; see `docs/todo/T02-funm.md`.

T03: `polyfit` and `polyeig`; see `docs/todo/T03-polyfit-polyeig.md`.

T04: `ismembertol`; see `docs/todo/T04-ismembertol.md`.

T05/T06: remaining special functions are classified by the backend matrix and
fully indexed in `docs/todo/T06-special-functions.md`.

T08: `meshgrid` with MP arguments and volume/N-D graphics such as `slice` and
`isosurface`; see `docs/todo/T08-meshgrid.md` and
`docs/todo/T08-volume-graphics-after-ND.md`.

T10: matrix-valued PP output; see `docs/todo/T10-matrix-valued-pp.md`.

T11: `interp3`, `interpn`, and general N-D interpolation; see
`docs/todo/T11-ND-interpolation.md`.

T12: complex nonlinear callbacks; see
`docs/todo/T12-complex-nonlinear-solvers.md`.

T13: `ArrayValued` quadrature; see
`docs/todo/T13-array-valued-quadrature.md`.

T14: `fminunc`; see `docs/todo/T14-fminunc.md`.

## Compatibility conclusion

Ordinary script: `SUPPORTED`, S00–S08 pass.

Advanced dense math: `SUPPORTED` for the closed T00–T04/N00–N08 surface.

Persistence: `SUPPORTED`, versioned exact MPFR/MPC serialization schema 1.

Graphics: `PARTIAL`, required 3-D APIs supported; volume graphics deferred.

Random: `SUPPORTED`, deterministic arbitrary-precision state API.

Interpolation: `PARTIAL`, required 1-D/2-D scalar-output APIs supported; N-D
interpolation deferred.

Nonlinear solving: `SUPPORTED` for the real fzero/fsolve contract.

Quadrature: `PARTIAL`, scalar `integral`/`quadgk` supported; ArrayValued
deferred.

Optimization: `PARTIAL`, fminbnd/fminsearch supported; fminunc deferred.

Special functions: `PARTIAL`, gamma/erf family supported; other families
remain explicitly deferred or direct-backend-only.

## Implementation commit chain

| Milestone | Commit |
|---|---|
| T00 | `f0a5103143914b813f4c94fe1a567886d8222c2b` |
| T01 | `7dc79f2d4c4fb7aa91a45822566bd0abc5ae533c` |
| T02 | `be8733167bfc7d78c28c60bd2af213b02769417a` |
| T03 | `f5bcf792c07f8e1171546937cdf022c89c04c88a` |
| T04 | `9e8bba0c40448ac76b727bfbf0a92090d198d5a7` |
| T05 | `f518ab973f023b4c89109cc95fd9a61ea9f961d1` |
| T06 | `e6a4daba2f47bdfc85eae08473db418d6348b729` |
| T07 implementation/evidence | `26041b49f599fa47c0c69d134b653d62b3468c05`, `9c2aead6cca454a654a288786fb1b0a3f10fcabb` |
| T08 | `89a25a7a8362ccc9d49ffa0dc2ad92e8b677f981` |
| T09 | `1697666a537d67662653d8fd25aec706dc2a315c` |
| T10 | `ecb497b93b586427d135f38c51244c6ccdea5fab` |
| T11 | `216f78305a2df0e3c2da0bc0cf55500fd0498d96` |
| T12 | `dced45c3f977252d74ed3da7cb3389c8395ead8a` |
| T13 | `3f878016dea4d7de372c83d0f5554f6c64a48c93` |
| T14 implementation | `ec3275a305dbc1c25cc8041d887a95d8e9f2e5e7` |
| T14 report/CI closure | `11bb012a285884ecd90cd9dbe32f400d5d34d703`, `246f9dafe3a1576172315c7b6667aeb44a3a1e4e` |
| T00-T14 documentation audit | `8ba6d849fa188765b372d9aa9f899d9de98a78cf` |

## Next

D04-READY: `YES`

T15-T20-READY-FOR-PLANNING: `YES`

No D04, T15–T20, B01–B05, F00, or PPA work was started automatically.

The T00–T14 controller is complete. Stop here.
