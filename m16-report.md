# M16 RESULT

Repository: `nakatamaho/octave-mplapack`
Remote: `origin` (`https://github.com/nakatamaho/octave-mplapack.git`)
Branch: `topic/m16-rank-deficient-lstsq`
Starting commit: `8d5cbc022a1776e94bbbebbb0442513e94d172c4`
Final commit: `c22ad4d` (implementation; report commit follows)
PR: pending push/creation

## Baseline

- M15 accepted base: `8d5cbc022a1776e94bbbebbb0442513e94d172c4` (M15 topic tip; PR #16 remains the stacked base)
- M15 implementation commit: `e051111`
- MPLAPACK dependency: `1cf03d1a1aa2afecde5f1840fbe9663ecfc31e57`
- Fresh project default: 512 bits
- Fresh current-thread MPFR default: 512 bits

## Driver audit

### Rgelsy

- Installed signature: `Rgelsy(m,n,nrhs,a,lda,b,ldb,jpvt,rcond,rank,work,lwork,info)` using `mplapackint` and MPFR `REAL`
- Mathematical method: pivoted QR with complete orthogonal factorization
- Rank semantics: effective rank from incremental condition estimates
- RCOND semantics: explicit threshold argument
- Workspace: REAL workspace query (`LWORK=-1`)
- JPVT: initialized to zero (all columns free) in the probe
- Nested call chain: `Rgeqp3 -> Rlaic1`, then `Rtzrzf`, `Rormqr`, `Rtrsm`, `Rormrz`, and `Rcopy`
- Threading: no OpenMP, pthread, or worker regions found in the audited pinned reference path
- 1024-bit POC: exact rank-one fixtures pass
- 2048-bit POC: exact rank-one fixtures pass
- Rank-threshold POC: 512-bit canary rank 1; 1024-bit canary rank 2
- Decision: not selected; the exact rank-one overdetermined fixture was misclassified as rank 2 at 512 bits

### Rgelss

- Installed signature: `Rgelss(m,n,nrhs,a,lda,b,ldb,s,rcond,rank,work,lwork,info)` using `mplapackint` and MPFR `REAL`
- Mathematical method: SVD-based least-squares with minimum-norm solution
- Rank semantics: effective rank determined from singular values and `RCOND`
- RCOND semantics: explicit threshold; M16 supplies `Rlamch_mpfr("E")`
- Workspace: REAL workspace query (`LWORK=-1`)
- S: `min(m,n)` operation-owned MPFR values at `p_op`
- Nested call chain: QR/LQ preprocessing, `Rgeqrf`/`Rgelqf`, `Rgebrd`, `Rormbr`, `Rorgbr`, `Rbdsqr`, and MPFR BLAS helpers as selected by the source path
- Threading: no OpenMP, pthread, or worker regions found in the audited pinned reference path
- 1024-bit POC: rank-zero, rank-one, full-rank, QR, and LQ fixtures pass
- 2048-bit POC: rank-one QR/LQ and distinguishing-tail fixtures pass
- Decision: selected production driver

### Rgelsd

- Installed signature: `Rgelsd(m,n,nrhs,a,lda,b,ldb,s,rcond,rank,work,lwork,iwork,info)` using `mplapackint`, MPFR `REAL`, and integer `IWORK`
- Mathematical method: SVD divide-and-conquer least-squares
- Rank semantics: SVD effective rank
- RCOND semantics: explicit threshold
- WORK: REAL workspace query plus divide-and-conquer work
- IWORK: operation-owned integer workspace
- S: `min(m,n)` operation-owned MPFR values
- Nested call chain: QR/LQ reduction, `Rormbr`/`Rormlq`, and bidiagonal divide-and-conquer `Rlalsd`
- Threading: no OpenMP, pthread, or worker regions found in the audited pinned reference path
- Precision POC: all comparison fixtures pass at 512, 1024, and 2048 bits
- Decision: not selected; additional divide-and-conquer and integer-workspace complexity is unnecessary after `Rgelss` passed

## Selected driver

- Driver: MPLAPACK MPFR `Rgelss`
- Why selected: first decision-order candidate that passed exact rank, minimum-norm, precision, workspace, and TLS checks
- Why alternatives rejected/not selected: `Rgelsy` misclassified the 512-bit exact rank-one fixture; `Rgelsd` passed but is more complex
- Public rectangular path: all non-square dense real `mldivide` calls use `Rgelss`, for both full-rank and rank-deficient matrices
- M15 Rgels retained internally: yes, for regression/reference tests

## Rank threshold

- Policy: `RCOND = Rlamch_mpfr("E")` evaluated at `p_op`
- RCOND precision: explicitly `p_op`
- RCOND source: installed MPLAPACK MPFR `Rlamch_mpfr("E")`
- Uses p_op: yes
- Uses ambient mpbits: no
- Uses binary64 epsilon: no
- Hard-coded decimal tolerance: no
- Public tolerance API: none

## Native architecture

- Native source: `src/mp_lapack.h`, `src/mp_lapack.cc`, `src/octave_bridge.cc`
- p_op: `max(p_A,p_B)` for mp/mp; the participating mp precision for mp/double and double/mp
- A_work: operation-owned `m x n` deep copy at `p_op`
- B_work: operation-owned `max(m,n) x nrhs` padded copy at `p_op`, zero-filled before source rows
- RCOND: explicit MPFR value at `p_op`
- JPVT if applicable: not used by selected `Rgelss`
- S if applicable: `min(m,n) x 1` operation-owned storage at `p_op`
- WORK: query and actual REAL work at `p_op`
- IWORK if applicable: not used by selected `Rgelss`
- RANK: internal `mplapackint`, validated in `[0,min(m,n)]`
- Result extraction: first `n` rows of solved `B_work`, returned as `n x nrhs`
- Public input mutation: none

## Workspace

- Query: `LWORK=-1` inside the precision scope
- Query precision: `p_op`
- Query mutation: A/B are defensively recreated before the actual call
- Query conversion: finite, positive, integral MPFR value with GMP/range checks
- REAL workspace precision: uniformly `p_op`
- Integer workspace type: installed `mplapackint` (`int64_t`)
- Checked allocations: dimensions, padded RHS, workspace, and result sizes are checked
- Result: pass

## Rank-zero fixture

- Dimensions: `A 3x2` all zero, `B 3x2`
- Reported rank: 0
- Result: `2x2` zero minimum-norm solution
- Expected: zero solution
- PASS: yes

## Rank-1 overdetermined consistent

- A: `[[1,2]; [2,4]; [3,6]]`
- B: `[1;2;3]`
- Reported rank: 1
- Expected minimum-norm X: `[1/5;2/5]`
- Result: pass
- PASS: yes

## Rank-1 overdetermined inconsistent

- A: `[[1,2]; [2,4]; [3,6]]`
- B: `[1;2;4]`
- Reported rank: 1
- Expected least-squares/minimum-norm X: `[17/70;17/35]`
- Residual: analytical fixture verified by native MPFR expected values
- Result: pass
- PASS: yes

## Rank-1 underdetermined

- A: `[[1,2,3]; [2,4,6]]`
- B: `[1;2]`
- Reported rank: 1
- Expected minimum-norm X: `[1/14;2/14;3/14]`
- Result: pass
- PASS: yes

## Multiple RHS

- Overdetermined: full-rank `3x2` fixture with two distinct RHS columns
- Underdetermined: rank-one `2x3` fixture with two distinct RHS columns
- Reported rank: validated for each fixture
- Result: pass
- PASS: yes

## Precision-dependent rank canary

### p_op 512

- Ambient: 128 bits
- delta: `2^-700`
- RCOND: 512-bit `Rlamch_mpfr("E")`
- Reported rank: 1
- Expected rank: 1
- Result: zero/minimum-norm treatment of the unresolved direction

### p_op 1024

- Ambient: 128 bits
- delta: `2^-700`
- RCOND: 1024-bit `Rlamch_mpfr("E")`
- Reported rank: 2
- Expected rank: 2
- Result: second solution component resolves to 1

### High ambient default

- p_op: 256 bits
- Ambient: 4096 bits
- Reported rank: operation-precision result, independent of ambient default
- Result: correct 256-bit full/rank-deficient solve and ambient restoration

## 1024-bit regression

- Outside default: 128 bits
- Fixture: rank-deficient QR/LQ systems with `2^-700` distinguishing terms
- Reported rank: correct rank for each fixture
- Tail preserved: yes
- Result precision: 1024 bits
- TLS restored: yes

## 2048-bit regression

- Outside default: 128 bits
- Fixture: rank-deficient QR/LQ systems with `2^-1500` distinguishing terms
- Reported rank: correct rank for each fixture
- Tail preserved: yes
- Result precision: 2048 bits
- TLS restored: yes

## Mixed precision

- A256 \\ B1024: pass
- A1024 \\ B256: pass
- p_op: 1024 bits
- RCOND precision: 1024 bits
- Result precision: 1024 bits
- Rank: correct full/rank-deficient classifications
- PASS: yes

## Binary64

- mp A \\ double B: pass
- double A \\ mp B: pass
- 0.1 semantics: direct incoming binary64 conversion
- 0.125: exact binary64 control passes
- Decimal-string conversion: none
- Binary64 fallback: none

## M15 full-rank parity

- QR single RHS: pass
- QR multiple RHS: pass
- LQ single RHS: pass
- LQ multiple RHS: pass
- 1024-bit: pass
- 2048-bit: pass
- Mixed precision: pass
- Binary64: pass
- Empty cases: pass through pre-LAPACK zero-size handling
- Result: rank-revealing public path agrees with M15 full-rank semantics

## Square/scalar parity

- Scalar path: unchanged native MPFR division
- Square Rgesv path: unchanged
- Square singular behavior: unchanged M09 deterministic singular error
- M09 regressions: pass

## Immutability

- A unchanged: pass
- B unchanged: pass
- Operation-owned buffers: A, padded B, S, WORK, and query state
- Clear inputs then use result: pass

## Interoperability

- indexing: pass
- double: pass
- disp: pass
- arithmetic: pass
- transpose: pass
- reshape: pass
- concatenation: pass
- assignment: pass
- mtimes: pass
- subsequent mldivide: pass

## Robustness

- Repeated alternating precision: pass
- Failure precision restoration: RAII scope and error mapping verified
- Installed package: pass
- Clear/reload: pass
- ASan: pass
- UBSan: pass
- LSan: pass
- Existing M00-M15 regression: pass (`tools/local-ci.sh`)
- git diff --check: pass

## Gates

- G16-DRIVER-AUDIT: PASS
- G16-UPSTREAM: PASS
- G16-RANK: PASS
- G16-MINNORM: PASS
- G16-PRECISION: PASS
- G16-WORKSPACE: PASS
- G16-M15-PARITY: PASS
- G16-PUBLIC: PASS
- G16-IMMUTABILITY: PASS
- G16-BINARY64: PASS
- G16-INTEROP: PASS
- G16-ROBUSTNESS: PASS

M16 PASS

## Code changes

Added the checked MPLAPACK MPFR `Rgelss` rank-revealing bridge with explicit
`p_op` `RCOND`, padded operation-owned RHS storage, workspace query and safe
conversion, rank validation, and deterministic error mapping.  Rectangular
public `mldivide` now uses this path while scalar and square `Rgesv` dispatch
remain unchanged.  Added candidate comparison probes, native/public rank and
minimum-norm QA, package/lifecycle checks, documentation, and the milestone
completion-report rule in `AGENTS.md`.

## Files changed

- `AGENTS.md`
- `src/mp_lapack.h`
- `src/mp_lapack.cc`
- `src/octave_bridge.cc`
- `src/Makefile`
- `inst/@mp/mldivide.m`
- `test/m16_driver_probe.cc`
- `test/mp_lapack_rank_test.cc`
- `test/rank.tst`
- `test/run_tests.m`
- `tools/local-ci.sh`
- `tools/check-tree.sh`
- `tools/check-format.sh`
- `tools/build-package.sh`
- `docs/rank-deficient-solve.md`
- `docs/linear-solve.md`
- `docs/milestones/M16-rank-deficient-lstsq.md`
- `docs/milestones/README.md`
- `README.md`
- `NEWS.md`

The five pre-existing deleted legacy report files remain unstaged.

## Commits

- `c22ad4d` — M16: add rank-deficient rectangular mp least-squares solve
- report commit follows

## Push

- Push: pending
- Remote tip: pending
- Local tip: pending report commit
- GitHub CI: pending PR creation

## Known limitations

- Rank tolerance is internal and not user-configurable
- Square singular systems retain M09 behavior
- Public `rank()` remains unsupported
- Public singular values/SVD remain unsupported
- Condition-number estimation remains unsupported
- Complex matrices unsupported
- Sparse matrices unsupported
- Other limitations: general N-D and broader Octave matrix APIs remain outside the accepted milestones

## Recommended next action

Review and merge the M16 PR.  Define M17 independently; do not automatically
add SVD, `rank()`, or condition-number APIs merely because `Rgelss` computes
internal singular values and rank.
