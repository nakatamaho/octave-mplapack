# octave-mplapack

**Status: real-only v0.1 release closure.** M00 through M21 pass; M20 is a design-only
complex architecture freeze and the public `mp` surface remains real-only.
The package provides a public real `mp` scalar and dense matrix with
native MPFR storage, public default-precision control, canonical scalar text,
explicit binary64 conversion, scalar display, and native scalar/dense
element-wise `+`, `-`, `.*`, and `./`. Dense matrices use one private
column-major contiguous native payload;
`mtimes` uses MPLAPACK MPFR `Rgemm` under a uniform operation-precision
calling scope. Dense matrix inspection is read-only and preserves stored MPFR
precision. M12 adds precision-preserving transpose and two-dimensional
reshape. M13 adds native horizontal and vertical concatenation that returns
one dense `mp` value. M14 adds value-semantic, in-bounds indexed assignment
with precision-preserving native copies. M18 adds non-pivoted dense real QR
through MPLAPACK MPFR `Rgeqrf`/`Rorgqr`; one-output `qr(A)` returns `R` and
two-output forms return `Q,R` with full or economy shapes. M19 adds
three-output column-pivoted QR through `Rgeqp3`, with builtin-double
permutation matrix/vector outputs.
M20 audits the installed MPLAPACK MPFR complex backend and freezes a future
four-payload architecture without implementing public complex values. See
[`docs/complex-architecture.md`](docs/complex-architecture.md).
M21 adds dense real LU through MPLAPACK MPFR `Rgetrf`, including packed,
two-output, row-permutation-matrix, and 1-based permutation-vector forms for
square, rectangular, and singular matrices. See [`docs/lu.md`](docs/lu.md).

M22 closes the provisional real-only API and prepares the v0.1 package/PPA
handoff. See the [v0.1 API inventory](docs/v0.1-api.md),
[Octave compatibility notes](docs/octave-compatibility.md), and
[release checklist](docs/release-checklist.md).

## Goal

`octave-mplapack` will provide GNU Octave access to MPLAPACK
multiple-precision linear algebra through an Octave-native multiprecision
numeric type named `mp`. MPLAPACK is the numerical backend rather than the
user-facing programming model.

## Quick start

Install a locally built archive with Octave's package manager (the public PPA
is planned after M23):

```text
octave:1> pkg install mplapack-0.1.0-dev.tar.gz
octave:2> pkg load mplapack
```

For a checkout, `tools/dev-octave.sh` verifies the `pkg-config` dependency,
builds the native module, and starts a configured development session. It does
not replace clean package/install QA.

The v0.1 surface is dense real `mp` only. It includes precision-controlled
construction, arithmetic, `*`, square and rectangular `\`, indexing and
in-bounds assignment, `chol`, full/economy and pivoted `qr`, and `lu`.
Complex, sparse, N-D, reductions, `det`, `inv`, `rank`, `cond`, `norm`, `eig`,
and `svd` remain explicitly unsupported; see the [complete limitations](docs/v0.1-api.md#unsupported-v01-surface).

The required MPLAPACK MPFR dependency is discovered through `pkg-config` and
must provide the uniform-precision scope interface. The package never vendors
or searches a developer-specific MPLAPACK path.

## Initial backend

The initial backend is **MPFR real arithmetic**. MPLAPACK remains a separately
installed dependency discovered with `pkg-config`; it is not vendored here.

## Working diagnostic

With the current source package installed:

```octave
pkg load mplapack
info = mplapack_version()

a = mp("0.1");
b = mp(0.1);

mpbits()
% 512

mpdigits(100);
mpbits()
% 333

c = mp("0.1");

s = char(c)
d = double(c)
disp(c)

sum_value = a + b
difference = a - b
product = a .* b
quotient = a ./ b

A = mp ({"1", "2";
         "3", "4"});
B = mp ([1, 2;
         3, 4]);
size (A)
% 2 2
C = A * A
x = A \ b
R = mp ({"1", "0"; "0", "1"; "1", "1"});
r = mp ({"0"; "1"; "4"});
least_squares = R \ r
element = A(2, 1)
column = A(:, 2)
double_A = double(A)
disp(A)
R = chol (mp ({"4", "2"; "2", "10"}));
[Q, R] = qr (mp ([1, 2; 3, 4; 5, 7]));
% native MPLAPACK MPFR Rgemm/Rgesv/Rgelss/Rpotrf/Rgeqrf/Rorgqr/Rgeqp3 results
```

This loads the private native module, reports the Octave, MPLAPACK, and MPFR
versions, and executes the MPLAPACK MPFR `Rlamch_mpfr` probe. The constructor
creates immutable public `1 x 1` scalar values. A fresh process starts at 512
bits. `mpbits` controls the canonical bit precision and `mpdigits(n)` selects
`ceil(n * log2(10))` bits without hidden guard bits. In the example, `a` and
`b` remain 512-bit values while `c` uses 333 bits. `char(c)` returns canonical
decimal text that reconstructs the same MPFR value when parsed at `c`'s
precision. `double(c)` is an explicit, potentially lossy binary64 conversion;
`disp(c)` prints the canonical multiprecision text.

Scalar arithmetic uses MPFR round-to-nearest.  For two `mp` operands the
result precision is the greater stored operand precision; with one real
scalar `double`, the `mp` operand precision is used.  The current default does
not affect an arithmetic result.  For example, `a + 0.1` converts the
already-rounded binary64 operand directly at `a`'s precision and generally
differs from `a + mp("0.1")`.

M07 matrix constructors preserve the same source distinction element by
element.  A real double matrix transfers each existing binary64 value
directly, while a text-cell matrix parses each decimal directly.  Each matrix
has one immutable precision, contiguous column-major MPFR storage, and normal
two-dimensional shape metadata.  M08 implements dense real `A * B` through
MPLAPACK MPFR `Rgemm`, and M09 implements square `A \ B` through `Rgesv`;
M15 extends full-rank rectangular `A \ B` through `Rgels`,
with result precision equal to the maximum operand precision and a temporary
current-thread precision scope. M16 upgrades rectangular `A \ B` to the
rank-revealing MPLAPACK MPFR `Rgelss` path for minimum-norm least-squares
solutions, while square systems remain on `Rgesv`. M10 adds read-only indexing, `double(A)`, and
canonical matrix display. M11 adds native MPFR matrix `+`, `-`, `.*`, and `./`,
unary signs, and two-dimensional singleton expansion. M12 adds read-only
transpose, conjugate transpose for real values, and column-major reshape;
these structural operations preserve source precision and do not consult the
ambient precision default. M17 adds dense real `chol` through MPLAPACK MPFR
`Rpotrf`, including selected-triangle semantics and optional status output,
while preserving immutable source values and stored precision. M18 adds
non-pivoted dense real `qr` through MPLAPACK MPFR `Rgeqrf` and `Rorgqr`;
one-output `qr(A)` returns `R` and two-output forms return `Q,R`. M19 adds
column-pivoted three-output `qr` through `Rgeqp3`, reusing `Rorgqr` for `Q`.
M21 adds dense real `lu` through `Rgetrf`; packed one-output factors,
permutation-aware two/three-output factors, and vector row pivots preserve the
stored operand precision.

## v0.1 feature status

| Feature | Scalar | Dense matrix | Backend | Status |
|---|---:|---:|---|---|
| `+ - .* ./` | yes | yes | MPFR | supported |
| `*` | yes | yes | `Rgemm` | supported |
| `\` | yes | yes | `Rgesv`/`Rgelss` | supported |
| `chol` | yes | yes | `Rpotrf` | supported |
| `qr` / pivoted `qr` | yes | yes | `Rgeqrf`/`Rgeqp3`/`Rorgqr` | supported |
| `lu` | yes | yes | `Rgetrf` | supported |
| complex / sparse | no | no | future | deferred |

## Intended future API

The following workflow is available through M19:

```octave
pkg load mplapack

mpdigits(100);

A = mp({"1", "2"; "3", "4"});
b = mp({"1"; "2"});

C = A * A;
x = A \ b;
```

The completed baseline uses normal Octave matrix operations such as indexing,
`\`, and read-only conversion/display. Native backend entry points stay
private.

## Precision warning

These constructors intentionally have different input semantics:

```octave
mp("0.1")
mp(0.1)
```

The string form parses decimal text directly at the target MPFR precision.
The numeric form receives an already-rounded IEEE binary64 value and preserves
that exact value when converting to MPFR. Thus the two `0.1` values above are
intentionally different. See
[`docs/precision-semantics.md`](docs/precision-semantics.md).

## Non-goals for 0.1.0

- Wrapping every MPLAPACK routine
- Supporting every MPLAPACK backend
- Complex multiprecision arithmetic
- Replacing Octave BLAS/LAPACK
- Transparent conversion of all Octave code to multiprecision
- Complete MATLAB compatibility

## Development roadmap

```text
M00  Bootstrap
M01  Native build probe
M02  Native mp storage
M03  Public scalar constructor
M04  Precision
M05  Conversion/display
M06  Element-wise arithmetic
M07  Matrix storage
M08  Matrix multiplication
M09  Linear solve
M10  Dense matrix inspection
M11  Dense element-wise arithmetic
M12  Dense transpose and reshape
M13  Dense horizontal and vertical concatenation
M14  Dense indexed assignment with value semantics
M15  Full-rank rectangular dense solve
M16  Rank-deficient rectangular minimum-norm solve
M17  Dense real Cholesky factorization
M18  Dense real non-pivoted QR factorization
M19  Dense real pivoted QR factorization
M20  Complex architecture audit and design freeze (no public complex support)

P00-P06  Debian/Ubuntu/PPA packaging
```

M00 through M22 are complete (M20 is design-only and M22 is release closure).
M23 is the feature freeze; no tag or PPA upload exists yet. Consult
[`docs/milestones/README.md`](docs/milestones/README.md) for gate definitions
and status.
