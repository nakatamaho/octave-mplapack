# Complex `mp` API

This is the C00–C12 implementation inventory for package version `0.2.0`.
Release identity and dependency provenance are maintained in
`docs/dependency-release-stack.md`.

## Values and construction

`mp` has one public class with separate real MPFR and complex MPC payload
kinds. Complex scalars and dense two-dimensional matrices are supported.

- `mp (complex_double_scalar_or_matrix)` transfers the already-rounded
  binary64 real and imaginary components into MPFR/MPC storage;
- `mp (real_text, imag_text)` constructs one complex scalar directly from two
  decimal strings, without a binary64 intermediate;
- `mp ("(real,imag)")` accepts the canonical single-string complex scalar
  form;
- `mp (existing_mp)` preserves the existing value and stored precision;
- complex values are immutable at the public boundary and retain their
  two-dimensional shape;
- `char`, `double`, and `disp` are explicit conversions/inspection, with
  `double` being the only intentional binary64 conversion.

Real and complex payloads use the stored precision of their source. Every
complex numerical operation chooses one `p_op`, promotes real MP values to
MPC at that precision when needed, enters one MPFR/MPC scope, and returns
uniform-precision operation-owned storage. Ambient precision does not change
an existing value or override `p_op`.

## Supported forms

| Area | Supported complex forms | Result/backend |
|---|---|---|
| inspection | `size`, `rows`, `columns`, `numel`, `ndims`, `isempty`, scalar `char`, `disp` | native metadata/text |
| structure | `real`, `imag`, `conj`, transpose, ctranspose, 2-D `reshape` | MPC/native MPFR |
| indexing | scalar, row/column, linear, two-dimensional dense indexing | operation-owned MPC |
| assignment | in-bounds dense assignment from complex/real `mp` or double | value-semantic MPC promotion |
| arithmetic | `+`, `-`, `.*`, `./`, unary signs | MPC element-wise path |
| multiplication | `*` for scalar/matrix and mixed real/complex dense operands | MPLAPACK `Cgemm` |
| square solve | `A \ B` | MPLAPACK `Cgesv` |
| rectangular solve | full-rank/rank-revealing `A \ B` | MPLAPACK `Cgelsy` |
| Cholesky | `chol(A)`, `chol(A,"upper"/"lower")`, optional status | MPLAPACK `Cpotrf` |
| QR | one/two-output full/economy `qr` | `Cgeqrf`/`Cungqr` |
| pivoted QR | three-output matrix/vector/deprecated economy forms | `Cgeqp3`/`Cungqr` |
| LU | packed, two-output, matrix/vector permutation forms | MPLAPACK `Cgetrf` |
| mixed structural | horizontal/vertical concat; real/complex assignment | MPC destination at max stored precision |

For LU, one output is the packed factor. Two outputs return `A=L*U`; three
outputs return builtin real `P` with `P*A=L*U`; `lu(A,"vector")` returns a
builtin real column `p` with `A(p,:)=L*U`. Square, rectangular, empty, and
singular factors are supported. Singular `Cgetrf INFO` is retained by the
native result and partial factors are returned, matching real M21 public
behavior; the public wrapper has no separate LU status output.

Permutation matrices, permutation vectors, and other structural outputs are
builtin real values. Real-only operands remain on the real MPFR `R*` paths;
they are never routed through complex kernels.

## Precision and ownership contract

The complex backend accepts `mpc_class` arrays only when both components have
the same operation precision. Destructive `Cgesv`, `Cpotrf`, QR, and `Cgetrf`
calls receive operation-owned copies. There is no silent builtin binary64
complex fallback. Explicit `double(...)` conversion is outside this numerical
contract.
