# octave-mplapack

**Status: under development.** M00 through M03 pass. M04 precision control is
planned. M03 provides a public real `mp` scalar with native MPFR storage, but
dense matrices, conversion, arithmetic, and other numerical operations are
not implemented yet.

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
```

This loads the private native module, reports the Octave, MPLAPACK, and MPFR
versions, and executes the MPLAPACK MPFR `Rlamch_mpfr` probe. The constructor
creates immutable public `1 x 1` scalar values at the current internal default
of 128 bits. Public precision configuration arrives in M04.

## Intended future API

The following is the target workflow through M10 and is not implemented yet:

```octave
pkg load mplapack

mpdigits(100);

A = mp({"1", "2"; "3", "4"});
b = mp({"1"; "2"});

C = A * A;
x = A \ b;
```

The API will use normal Octave operations such as `+`, `-`, `.*`, `./`, `*`,
`\`, transpose, conversion, and display. Native backend entry points will stay
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
M10  First functional baseline

P00-P06  Debian/Ubuntu/PPA packaging
```

M00 through M03 are complete. M04 remains planned. Consult
[`docs/milestones/README.md`](docs/milestones/README.md) for gate definitions
and status.
