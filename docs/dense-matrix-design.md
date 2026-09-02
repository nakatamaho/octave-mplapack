# Native dense matrix design

## Scope

M07 introduced storage and public construction for real, two-dimensional
MPFR matrices. M10 adds read-only indexing, matrix `double`, and matrix
display formatting without changing the storage representation. M11 extends
the same storage with direct MPFR element-wise arithmetic and two-dimensional
singleton expansion; M12 adds precision-preserving transpose and reshape; M13
adds native horizontal and vertical concatenation.
Ownership and layout remain unchanged.

## Installed MPLAPACK ABI audit

The authoritative installed MPLAPACK 3.0.1 headers are
`mpblas_mpfr.h`, `mplapack_mpfr.h`, and `mplapack_config.h`, discovered
through `pkg-config mplapack_mpfr`.  Their public declarations establish:

- MPFR real dense elements are `mpfr_class`, which is
  `mpfrxx::mpfr_class`;
- `Rgemm` accepts its dense arrays as `mpfr_class *` and dimensions and
  leading dimensions as `mplapackint`;
- `Rgesv` accepts its coefficient and right-hand-side arrays as
  `mpfr_class *`, pivots as `mplapackint *`, and dimensions as
  `mplapackint`; and
- this installation defines `mplapackint` as `int64_t`.

M07 verifies these types at compile time.  It does not call either routine.

## Public representation

One public classdef `mp` object owns one private native payload.  A public
dense matrix is never an Octave object array, a cell array of scalar wrappers,
or a vector of `octave_value` objects.

## Internal native type

The private matrix payload has the registered name
`mplapack_mpfr_matrix_internal`.  It follows the same DLD-aware Octave 11.1
registration and module-retention design as the scalar payload.  The normal
public class remains exactly `mp`.

## Scalar vs matrix payload

All public `1 x 1` values use the established scalar payload.  The matrix
payload represents every supported shape whose element count is not one,
including empty shapes.  This gives public scalars one canonical native
representation.

## Canonical 1x1 representation

Scalar double, scalar text, a `1 x 1` double array, and a `1 x 1` text cell
all normalize to `mplapack_mpfr_scalar_internal`.  A matrix payload is never
used merely because the constructor input was a container.

## Matrix precision

One matrix has one immutable bit precision.  Every native element is created
explicitly with that precision; MPFR's mutable global default is not used.
Changing the project default affects only later construction.

## Element scalar type

`MpfrMatrixStorage::NativeScalar` is `mpfrxx::mpfr_class`, exactly the scalar
type in the installed MPLAPACK MPFR dense-array declarations.

## Column-major storage

Storage is column-major.  Zero-based `(row, column)` maps to
`row + column * leading_dimension`.  A logical matrix

```text
[11 12 13
 21 22 23]
```

therefore has native order `11, 21, 12, 22, 13, 23`.

## Leading dimension

For a positive row count the leading dimension equals the row count.  For a
zero-row matrix it is one, satisfying the Fortran BLAS/LAPACK minimum without
requiring storage for an empty matrix.

## Dimension types

Octave dimensions enter the bridge as `octave_idx_type`, allocations use
`std::size_t`, and MPLAPACK calls use `mplapackint`.  Each boundary is checked.
Element-count multiplication is checked before allocation.

## Contiguous buffer

The project-owned `MpfrMatrixStorage` owns a
`std::vector<mpfrxx::mpfr_class>`.  The vector is reserved and populated once
with explicit-precision elements.  Its `data()` type is directly compatible
with the installed MPLAPACK `mpfr_class *` interface; packing and
`reinterpret_cast` are unnecessary.

## Construction from double matrices

Every real binary64 input is transferred directly with `mpfr_set_d` and
`MPFR_RNDN` at the matrix precision.  Decimal formatting is not involved.

## Construction from decimal text cells

Every text cell is parsed directly with `mpfr_set_str`, base ten, and
`MPFR_RNDN` at the matrix precision.  Construction is transactional through
RAII: invalid text cannot publish a partially built payload.

## Empty matrices

`0 x 0`, `0 x N`, and `N x 0` shapes retain their dimensions, precision, and
leading-dimension metadata.  Their element vector is empty and is never
dereferenced.

## Copy and move semantics

Native copy construction deep-copies the contiguous vector.  Move operations
transfer ownership without copying MPFR limbs.  Standalone sanitizer tests
prove independent buffers and safe copy, move, and destruction.

## Deep-copy work buffers

The pure storage class supplies mutable access only to native operation-owned
code.  A deep copy may be changed by a future destructive LAPACK call without
changing the immutable public input.  No mutable pointer is exposed to Octave.

## Immutability

Public matrix shape, precision, and elements are immutable.  Public indexing
and indexed assignment are rejected in M07.

## Module lifetime

The matrix native value derives from the same DLD-aware base used by the
scalar native value.  Both types register once, and the DLD function lock is
reasserted whenever the module entry point loads.  Live values therefore keep
their vtables, destructors, and type metadata resident across ordinary clear
and package unload/reload behavior.

## Indexing boundary

`size`, `rows`, `columns`, `numel`, `ndims`, and `isempty` query native shape.
M10 parenthesis indexing copies selected native values directly, preserves
source precision, and normalizes `1x1` selections to scalar storage. Brace
indexing and indexed assignment fail explicitly; they must not treat the
one-wrapper representation as an Octave object array.

## M10 inspection

Read-only `A(i,j)`, `A(:,j)`, `A(i,:)`, `A(I,J)`, `A(k)`, `A(:)`, and `end`
forms use checked indices and deep-copy slices. `double(A)` uses direct
MPFR-to-binary64 conversion with `MPFR_RNDN`, while `disp(A)` reuses the
canonical scalar formatter for every entry. Neither operation consults or
mutates the current precision default. Matrix `char` remains deferred.

## M08 Rgemm implementation

The dense buffer is uniform-precision, contiguous, column-major, and directly
typed as the installed `Rgemm` array argument.  Dimensions and leading
dimensions have checked `mplapackint` conversions.  M08 allocates
operation-owned promoted buffers and passes them without packing.  The
operation precision is the maximum precision of the participating `mp`
operands, and `MplapackMpfrPrecisionScope` establishes that precision on the
calling thread for the duration of the reference MPFR `Rgemm` call.  A strict
native checker rejects any mismatch before entering MPLAPACK.  Scalar and
real-double scaling use direct MPFR operations. M11 element-wise arithmetic
likewise operates directly on MPFR values in destination storage; it does not
call MPLAPACK and does not use the current default precision.

## M09 Rgesv implementation

Deep copies provide operation-owned mutable coefficient and right-hand-side
buffers. Native mutation of such work copies leaves public immutable inputs
unchanged. M09 uses the same checked dimensions, column-major layout, and
leading dimensions for `Rgesv`; square solves return the operation-owned
solution buffer and preserve public input values.

## M12 structural operations

Transpose and reshape allocate independent `MpfrMatrixStorage` at the source
matrix precision and copy native MPFR values directly. Transpose swaps the
two-dimensional coordinates; reshape preserves the contiguous column-major
linear order. Scalar results remain the canonical scalar payload, while all
other shapes—including empty matrices—remain matrix payloads. These operations
do not use MPLAPACK or change the current precision default.

## M13 concatenation

M13 assembles arbitrary-arity horizontal and vertical concatenations directly
into one new `MpfrMatrixStorage`. The complete argument list is validated with
Octave's two-dimensional `hvcat` shape rules before allocation. Scalars are
`1x1`; no singleton broadcasting is performed. Empty matrices retain their
shape semantics and empty `mp` operands still contribute their explicit
precision to `p_cat`, the maximum participating `mp` precision. MPFR values
are copied exactly into uniformly `p_cat`-precision storage, while real double
elements are transferred directly from binary64 with `mpfr_set_d`.

The operation is structural: it does not call MPLAPACK, enter a precision
scope, or read or mutate either precision default. Inputs remain immutable and
the result owns independent storage. Public bracket syntax therefore returns
one `mp` value rather than an array of scalar wrapper objects.

## M14 indexed assignment

M14 keeps public matrix values immutable while adding limited in-bounds
parenthesis assignment. `subsasgn` validates indices and RHS shape, determines
`p_assign`, deep-copies the entire lhs into uniformly `p_assign` storage, and
updates only the selected positions. An aliased lhs and an RHS derived from
that lhs therefore remain safe. Matrix growth, deletion, logical assignment,
and general vector linear assignment are rejected.

## Non-goals

Logical indexing, general vector linear indexing, matrix `char`, comparisons,
powers, reductions, and complex storage remain deferred. M08 adds
`mtimes`/`Rgemm`, M09 adds square `mldivide`/`Rgesv`, M10 adds read-only matrix
inspection, M12 adds transpose and reshape, M13 adds horizontal/vertical
concatenation, and M14 adds value-semantic indexed assignment.
