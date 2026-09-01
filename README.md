# octave-mplapack

**Status: under development.** M00 through M08 pass. M09 linear solve is next.
The package provides a public real `mp` scalar and dense matrix with
native MPFR storage, public default-precision control, canonical scalar text,
explicit binary64 conversion, scalar display, and scalar `+`, `-`, `.*`, and
`./`. Dense matrices use one private column-major contiguous native payload;
`mtimes` uses MPLAPACK MPFR `Rgemm` under a uniform operation-precision
calling scope. Matrix indexing, element-wise arithmetic, and matrix conversion
remain deferred.

## Goal

`octave-mplapack` will provide GNU Octave access to MPLAPACK
multiple-precision linear algebra through an Octave-native multiprecision
numeric type named `mp`. MPLAPACK is the numerical backend rather than the
user-facing programming model.

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
% native MPLAPACK MPFR Rgemm result
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
MPLAPACK MPFR `Rgemm`, with result precision equal to the maximum operand
precision and a temporary current-thread precision scope.  `A \ B`, matrix
element-wise arithmetic, indexing, and matrix conversion/display remain
unimplemented.

## Intended future API

The following workflow is available through M08; the linear solve remains
deferred to M09:

```octave
pkg load mplapack

mpdigits(100);

A = mp({"1", "2"; "3", "4"});
b = mp({"1"; "2"});

C = A * A;
x = A \ b;
```

The completed baseline will additionally use normal Octave matrix operations
such as `\` and transpose. Native backend entry points stay private.

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
M10  First functional baseline

P00-P06  Debian/Ubuntu/PPA packaging
```

M00 through M08 are complete. M09 is next. Consult
[`docs/milestones/README.md`](docs/milestones/README.md) for gate definitions
and status.
