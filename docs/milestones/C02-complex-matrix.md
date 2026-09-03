# Goal

Make dense complex matrices first-class public `mp` values.

# Scope

Support direct construction from builtin complex double matrices, contiguous
uniform-precision native storage inspection, accepted one/two-dimensional
indexing, value-semantic complex assignment, explicit complex-double matrix
conversion, direct display, and empty matrix shapes.

# Non-goals

Complex arithmetic, transpose/conjugation, and complex LAPACK operations are
deferred to C03-C11L. Exact complex text-cell construction is not introduced.

# Design constraints

Each dense matrix owns one native contiguous column-major payload. Indexing and
assignment copy native MPC values directly at the source/result precision;
they do not round-trip through text or binary64. Destructive mutation is
performed on a new operation-owned matrix.

# Implementation tasks

- Add complex matrix constructors and native metadata.
- Add complex matrix selection and scalar normalization.
- Add complex matrix assignment with scalar/exact-shape/vector RHS rules.
- Add complex matrix display and explicit `double` conversion.

# Required tests

Complex construction, column-major layout, precision preservation and
promotion, scalar/slice/linear indexing, empty 0x0/0xN/Mx0 shapes,
complex-to-complex assignment, deep value semantics, display, and the full
real regression wall.

# Gate

`C02 PASS` requires G-C02-CONSTRUCT, G-C02-STORAGE, G-C02-INDEX,
G-C02-ASSIGN, G-C02-DOUBLE, G-C02-DISP, G-C02-EMPTY, G-C02-LIFETIME, and
G-C02-REAL-REGRESSION.

# Expected commit

`C02: add dense complex matrix inspection and assignment`
