# M14 RESULT

Repository: `nakatamaho/octave-mplapack`
Remote: `https://github.com/nakatamaho/octave-mplapack.git`
Branch: `topic/m14-indexed-assignment`
Starting commit: `10061d81df159b3d53316507874caf68f9a0751d`
Final commit: `702c1e32439b09b830c522bb135eeea73dff8593`
PR: [#15](https://github.com/nakatamaho/octave-mplapack/pull/15)

## Baseline

- M13 accepted base: `10061d81df159b3d53316507874caf68f9a0751d`
- Fresh project default: 512 bits
- Fresh current-thread MPFR default: 512 bits

## Assignment architecture

- Public method: `inst/@mp/subsasgn.m`
- Native source: `src/mp_matrix_assignment.cc`, `src/mp_matrix_assignment.h`, and `src/octave_bridge.cc`
- Value semantics: every successful assignment returns a new value
- LHS mutation: none
- Result ownership: independent native storage
- Deep copy: always used
- Copy-on-write: not implemented
- Matrix storage: contiguous, column-major, uniformly precisioned `MpfrMatrixStorage`
- MPLAPACK used: no
- Precision scope used: no
- Precision-state mutation: none

## Supported indexing assignment

- `A(i,j)=x`: PASS
- `A(:,j)=v`: PASS
- `A(i,:)=v`: PASS
- `A(I,J)=B`: PASS
- `end`: PASS
- ranges: PASS
- reordered indices: PASS
- repeated indices: PASS; later writes win, matching Octave
- `A(k)=x`: PASS for one scalar in-bounds index
- `A(:)=scalar`: PASS
- `A(:)=RHS`: PASS for compatible element counts
- empty selection: PASS as a no-op; empty RHS deletion is rejected
- general vector linear assignment: unsupported and rejected cleanly
- logical assignment: unsupported and rejected cleanly

## Unsupported structural changes

- Matrix growth: rejected as out-of-bounds
- RHS `[]` deletion: rejected cleanly
- N-D: rejected
- Complex: rejected
- Sparse: rejected
- Chained/cell/field assignment: unsupported forms rejected

## Shape semantics

- Scalar expansion: PASS
- Column assignment: PASS
- Row assignment: PASS
- Submatrix assignment: PASS
- RHS orientation: verified for row/column assignments and exact matrix shapes
- Shape mismatch: clean `mplapack:mp:DimensionMismatch` error
- Differential builtin Octave QA: PASS for supported forms

## Precision policy

- lhs `mp` / rhs `mp`: `max(lhs precision, rhs precision)`
- lhs `mp` / rhs `double`: lhs precision
- Assignment can narrow lhs: no
- Current `mpbits` dependency: none
- Current-thread MPFR default dependency: none

## Mixed precision

- lhs256 / rhs1024: result widened to 1024 bits
- lhs1024 / rhs256: result remains 1024 bits
- Result uniform precision: PASS
- Untouched lhs values: preserved exactly
- RHS represented value: embedded exactly without reconstruction

## 1024-bit regression

- LHS precision: 1024 bits
- RHS precision: 1024 bits
- Outside default: 128 bits
- Fixture: 1024-bit `1 + 2^-700`-scale distinguishing tail
- Untouched tail preserved: PASS
- Assigned tail preserved: PASS
- Result precision: 1024 bits
- Default after: 128 bits, unchanged

## 2048-bit regression

- LHS precision: 2048 bits
- RHS precision: 2048 bits
- Outside default: 128 bits
- Fixture: 2048-bit `1 + 2^-1500`-scale distinguishing tail
- Result: PASS
- Result precision: 2048 bits

## High outside default

- LHS precision: 256 bits
- RHS precision: 256 bits
- Outside default: 4096 bits
- Result precision: 256 bits

## Binary64

- `0.1`: incoming binary64 semantics preserved
- `0.125`: exact binary64 case PASS
- `+0`: PASS
- `-0`: PASS
- `Inf`: PASS
- `NaN`: PASS
- Decimal-string conversion: not used

## Value semantics

- `B=A; B(...)=...` leaves `A` unchanged: PASS
- RHS unchanged: PASS
- Result independent: PASS
- Clear lhs then use result: PASS
- RHS derived from lhs: PASS
- Overlap assignment: PASS

## Interoperability

- indexing: PASS
- double: PASS
- disp: PASS
- arithmetic: PASS
- transpose: PASS
- reshape: PASS
- concatenation: PASS
- mtimes: PASS
- mldivide: PASS

## Lifecycle and robustness

- Repeated assignment: PASS
- Alternating precision: PASS
- Failed assignment state: inputs and precision state unchanged
- Installed package: PASS
- Clear/reload: PASS
- ASan: PASS
- UBSan: PASS
- LSan: PASS via leak detection in local CI
- Existing M00-M13 regression: PASS
- `git diff --check`: PASS

## Gates

- G14-VALUE: PASS
- G14-INDEX: PASS
- G14-SHAPE: PASS
- G14-PRECISION: PASS
- G14-BINARY64: PASS
- G14-LIMITS: PASS
- G14-INTEROP: PASS
- G14-ROBUSTNESS: PASS

M14 PASS

## Code changes

Added a native MPFR assignment kernel, public `subsasgn` dispatch, checked
index/RHS validation, precision-preserving widening, binary64 insertion, and
native/lifecycle/package QA. Assignment uses immutable value semantics and
does not call MPLAPACK or alter MPFR TLS precision.

## Files changed

`NEWS.md`, `README.md`, `docs/architecture.md`, `docs/dense-matrix-design.md`,
`docs/matrix-assignment.md`, `docs/matrix-concatenation.md`,
`docs/matrix-inspection.md`, `docs/milestones/M14-indexed-assignment.md`,
`docs/milestones/README.md`, `docs/precision-semantics.md`, `inst/@mp/mp.m`,
`inst/@mp/subsasgn.m`, `src/Makefile`, `src/mp_matrix_assignment.cc`,
`src/mp_matrix_assignment.h`, `src/octave_bridge.cc`, `test/assignment.tst`,
`test/matrix_inspection.tst`, `test/mp_matrix_assignment_test.cc`,
`test/run_tests.m`, `tools/build-package.sh`, `tools/check-format.sh`,
`tools/check-tree.sh`, `tools/local-ci.sh`.

## Commits

- `9b7bae8` M14: add dense mp indexed assignment
- `1e05f05` M14: preserve empty-selection precision
- `dcd237b` M14: keep scalar assignment storage owned
- `702c1e3` M14: cover repeated destination indices

## Push

- Push: PASS
- Remote tip: `702c1e32439b09b830c522bb135eeea73dff8593`
- Local tip: `702c1e32439b09b830c522bb135eeea73dff8593`
- GitHub CI: structural checks PASS

## Known limitations

- Matrix growth remains unsupported
- Deletion assignment remains unsupported
- General vector linear assignment remains deferred
- Logical assignment remains unsupported
- General `cat(dim,...)` remains unsupported
- Comparison/logical operators remain unsupported
- Matrix power remains unsupported
- Complex matrices unsupported
- Sparse matrices unsupported
- N-D arrays unsupported
- Five pre-existing deleted report files remain uncommitted and were not part of M14 commits

## Recommended next action

Review and merge PR #15. Then proceed to M15 for rectangular dense left
division / least-squares after a dedicated numerical and precision-contract
audit.

Branch: `topic/m14-indexed-assignment`
Starting commit: `10061d81df159b3d53316507874caf68f9a0751d`
Final commit: `702c1e32439b09b830c522bb135eeea73dff8593`
Files changed: see the list above
Commands run: `tools/local-ci.sh`, native sanitizer checks, Octave M00-M14 tests, package install/reinstall QA, `tools/check-tree.sh`, `tools/check-format.sh`, `git diff --check`, and GitHub CI checks
Tests: all M00-M14 tests PASS
Gate: M14 PASS
Known limitations: see the list above
