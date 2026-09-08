# T00 report — Schur / QZ core

## Result

`T00 PASS — SCHUR/QZ CORE CLOSED`

T00 was implemented on the dedicated continuation branch from the immutable
D03 baseline.  The D03 tag and archive were not modified.

## Controller metadata

| Field | Value |
|---|---|
| Repository | `octave-mplapack` |
| Branch | `topic/t00-t14-continuation` |
| Starting commit | `ca78481559e00f80534aa4c89dedaa838fdf3953` |
| Implementation commit / tip | `f0a5103143914b813f4c94fe1a567886d8222c2b` |
| D03 baseline | `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31`, tag `v0.4.0` |
| Dependencies | gmpfrxx_mkII `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1`; MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` |
| Octave | GNU Octave 11.1.0 |
| API scope | `hess`, `balance`, `schur`, `qz` real/complex dense forms |
| Backend / algorithm | MPLAPACK MPFR `Rgehrd/Rorghr/Rgees/Rgges`; MPC `Cgehrd/Cunghr/Cgees/Cgges` |
| Precision policy | One-operation/one-precision MPFR/MPC scopes and operation-owned destructive-call copies |
| Real/complex behavior | Real calls stay on real drivers; complex calls use MPC; no builtin binary64 fallback |
| Octave differential QA | Reconstruction/orientation and public real/complex form checks |
| 1024/2048 QA | `2^-700` / `2^-1500`, source and ambient precision canaries PASS |
| Sanitizers | Native ASan, UBSan, and LSan walls PASS in final controller run |
| Previous regression | D03 S00–S08 and M00–M23 baseline retained and passed |
| Status / TODO | PASS; optional ordering helpers: `docs/todo/T00-schur-optional-ordering.md` |

## Implemented APIs

* `hess(A)` and `[P,H] = hess(A)` use MPFR `Rgehrd`/`Rorghr` and MPC
  `Cgehrd`/`Cunghr`.
* `balance(A)` and its scale/permutation options use MPFR/MPC `GEBAL`.
  The current public bridge intentionally exposes the one-output ordinary
  matrix form; generalized pair balancing is not faked by independently
  balancing two matrices.
* `schur(A)` and `[U,S] = schur(A,"real"|"complex")` use `Rgees` or
  `Cgees`, with Octave's `S = U' * A * U` orientation.
* `qz(A,B)` and the explicit real/complex forms use `Rgges` or `Cgges`.
  The returned orientation is Octave's `AA = Q*A*Z` and `BB = Q*B*Z`.
  Optional fifth/sixth outputs reuse the existing arbitrary-precision
  generalized eigensolver for right/left eigenvectors.

## Backend and precision audit

The frozen installed MPLAPACK 3.0.1 interface exports all routines required
by this core: `R/Cgebal`, `R/Cgehrd`, `Rorghr`/`Cunghr`, `R/Cgees`, and
`R/Cgges`.  The Cgges implementation requires an 8N MPFR real workspace;
the bridge now allocates that exact LAPACK-compatible area.

Every destructive backend call receives an operation-owned matrix copy.  Real
calls enter `MplapackMpfrPrecisionScope`; complex calls enter the composed
`MpfrMpcPrecisionScope`.  The implementation contains no builtin binary64
complex numerical fallback.

## Focused evidence

`test/t00_schur_qz.tst` passed with:

* real and complex Hessenberg decomposition and unitary checks;
* real and complex Schur reconstruction;
* complex and real QZ reconstruction, including singular `B`;
* 1024-bit `2^-700` and 2048-bit `2^-1500` precision canaries;
* source-value precision preservation;
* ordinary balancing smoke coverage.

The independent command-line focused smoke also passed at 256 bits.

## Required real regression wall

`test/run_tests.m` passed all existing M00–M23-compatible tests, C00–C12
including C11L, N00–N08, S00–S08, and the new T00 test.  The existing N07
firewall was updated only to remove the now-obsolete assertions that T00 and
T02 APIs must remain unsupported.

## Files

Implementation:

* `src/mp_schur_qz.cc`
* `src/mp_schur_qz.h`
* `src/octave_bridge.cc`
* `src/Makefile`

Public wrappers and focused tests:

* `inst/@mp/hess.m`
* `inst/@mp/balance.m`
* `inst/@mp/schur.m`
* `inst/@mp/qz.m`
* `test/t00_schur_qz.tst`

T-series development metadata is `0.5.0-dev`; D04 remains responsible for
the final release freeze.
