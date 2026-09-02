# M15 RESULT

Repository: `nakatamaho/octave-mplapack`
Remote: `origin` (`https://github.com/nakatamaho/octave-mplapack.git`)
Branch: `topic/m15-rgels`
Starting commit: `44a349f86751fa8a6924251e87251c5b1eb5b5be`
Final commit: `e051111` (implementation; this report is a follow-up documentation commit)
PR: pending creation after push

## Baseline

- M14 accepted base: `44a349f86751fa8a6924251e87251c5b1eb5b5be`
- Fresh project default: 512 bits
- Fresh current-thread MPFR default: 512 bits

## MPLAPACK dependency

- Source repository: `/home/docker/work/mplapack-mpfr-rgemm`
- Branch: `topic/mpfr-uniform-precision-scope`
- Commit: `1cf03d1a1aa2afecde5f1840fbe9663ecfc31e57` (controlled installation)
- Install prefix: `/tmp/mplapack-m08-shared-prefix.FEIaI6`
- Rgels signature: installed `void Rgels(const char *, mplapackint, mplapackint, mplapackint, mpfr_class *, mplapackint, mpfr_class *, mplapackint, mpfr_class *, mplapackint, mplapackint &)`
- Runtime library: controlled `libmplapack_mpfr.so.3`; MPFR/MPC/GMP resolve from `/usr/local/lib`
- libmplapack_mpfr_opt linked: no
- Threading audit: no OpenMP/thread regions in installed-source `Rgels`, `Rgeqrf`, `Rgelqf`, `Rormqr`, or `Rormlq`
- Worker precision propagation: caller scope is sufficient; no downstream worker patch required
- External consumer: `test/mp_lapack_rgels_probe.cc`, compiled with installed headers/libs

## Rgels call-chain audit

### m >= n
- Call chain: `Rgels -> Rgeqrf -> Rormqr/Rtrtrs` (QR path)
- Parallel regions: none found in audited reference path
- Default REAL temporaries: covered by caller `MplapackMpfrPrecisionScope`
- Scope architecture sufficient: yes

### m < n
- Call chain: `Rgels -> Rgelqf -> Rtrtrs/Rormlq` (LQ path)
- Parallel regions: none found in audited reference path
- Default REAL temporaries: covered by caller `MplapackMpfrPrecisionScope`
- Scope architecture sufficient: yes

## Workspace

- Query mechanism: `LWORK = -1` query followed by a fresh actual solve
- Query precision: explicit `p_op`
- Query info: validated; nonzero mapped to deterministic error
- Query mutates A: audited defensively; A/B are recreated before solve
- Query mutates B: audited defensively; A/B are recreated before solve
- LWORK conversion: finite, positive, integral MPFR value; GMP range checks; direct unsigned conversion
- LWORK type: installed `mplapackint` (`int64_t`)
- Allocation checks: checked MPLAPACK dimension, `size_t`, and workspace limits
- WORK precision: every element explicitly `p_op`
- Result: pass

## Native solve architecture

- Native source: `src/mp_lapack.h`, `src/mp_lapack.cc`, `src/octave_bridge.cc`
- Square dispatch: existing M09 `Rgesv`
- Rectangular dispatch: new `Rgels` path
- p_op: max precision of participating `mp` operands; double contributes no precision
- A_work shape: `m x n`
- A_work precision: `p_op`
- B_work shape: `max(m,n) x nrhs`
- B_work precision: `p_op`
- lda: checked leading dimension, at least `max(1,m)`
- ldb: checked leading dimension, at least `max(1,m,n)`
- Result extraction: first `n` rows of padded B buffer, returned as `n x nrhs`
- Public input mutation: none

## External precision POC

### QR 1024
- Outside default: 128 bits
- t: `2^-700`
- Result: exact expected least-squares solution
- Tails preserved: yes
- TLS restored: yes

### LQ 1024
- Outside default: 128 bits
- t: `2^-700`
- Result: exact expected minimum-norm solution
- Tails preserved: yes
- TLS restored: yes

### QR 2048
- t: `2^-1500`
- Result: pass; distinguishing tails preserved

### LQ 2048
- t: `2^-1500`
- Result: pass; distinguishing tails preserved

### High outside default
- Operand precision: 256 bits
- Outside default: 4096 bits
- Scope: 256 bits
- Result: correct 256-bit operation; ambient default restored

## Overdetermined public solve

- Basic single RHS: pass
- Multiple RHS: pass
- Exact least-squares fixture: `[1 0; 0 1; 1 1]` with orthogonal residual
- Result shape: `n x nrhs`
- Residual fixture: expected residual recovered
- 1024-bit: pass, `2^-700` tails preserved
- 2048-bit: pass, `2^-1500` tails preserved

## Underdetermined public solve

- Basic single RHS: pass
- Multiple RHS: pass
- Exact minimum-norm fixture: `[1 0 1; 0 1 1]`
- Result shape: `n x nrhs`
- 1024-bit: pass, `2^-700` tails preserved
- 2048-bit: pass, `2^-1500` tails preserved

## Mixed precision

- A256 \\ B1024: pass
- A1024 \\ B256: pass
- QR: pass
- LQ: pass
- p_op: 1024 bits for mixed cases
- Result precision: 1024 bits

## Binary64

- mp A \\ double B: pass
- double A \\ mp B: pass
- 0.1 semantics: direct incoming binary64 conversion
- 0.125 semantics: exact binary64 case passes
- Decimal-string conversion: none
- Binary64 fallback: none

## Rank behavior

- Supported contract: full column rank for `m >= n`; full row rank for `m < n`
- m>=n rank requirement: full column rank
- m<n rank requirement: full row rank
- info>0 behavior: deterministic `mplapack:mp:RankDeficient` error
- Diagnostic zero-rank fixture: audited/covered where backend reports positive info
- Near-rank-deficient detection claimed: no
- Rank-revealing driver implemented: no

## Empty cases

- Mx0: handled as a zero-row solution with compatible shape
- 0xN: handled as an `N x nrhs` zero minimum-norm result
- nrhs=0: handled without calling zero-size LAPACK
- Differential Octave QA: pass for supported empty shapes
- Precision: `p_op`

## Square/scalar parity

- Square Rgesv path: unchanged and verified
- Square M09 precision regression: pass
- Scalar path: unchanged native MPFR division
- Result: pass

## Immutability

- A unchanged: pass
- B unchanged: pass
- A_work ownership: operation-owned deep copy
- B_work ownership: operation-owned padded copy
- WORK ownership: operation-owned workspace
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
- Failure precision restoration: pass via RAII and error-path QA
- Installed package: pass
- ASan: pass
- UBSan: pass
- LSan: pass
- Existing M00-M14 regression: pass
- git diff --check: pass

## Gates

- G15-UPSTREAM: PASS
- G15-QR: PASS
- G15-LQ: PASS
- G15-WORKSPACE: PASS
- G15-PRECISION: PASS
- G15-PUBLIC: PASS
- G15-LIMITS: PASS
- G15-IMMUTABILITY: PASS
- G15-INTEROP: PASS
- G15-ROBUSTNESS: PASS

M15 PASS

## Code changes

Added a checked native MPFR `Rgels` bridge with workspace query, padded
operation-owned RHS storage, uniform `p_op` precision scopes, QR/LQ dispatch,
and deterministic error mapping. Extended `mldivide` to select `Rgels` only for
non-square dense matrices while retaining scalar and square `Rgesv` behavior.
Added installed-dependency probes, sanitizer/native tests, public rectangular
solve tests, documentation, and local CI/package checks.

## Files changed

- `src/mp_lapack.h`
- `src/mp_lapack.cc`
- `src/octave_bridge.cc`
- `src/Makefile`
- `inst/@mp/mldivide.m`
- `test/mp_lapack_rgels_probe.cc`
- `test/mp_lapack_rgels_test.cc`
- `test/rgels.tst`
- `test/gesv.tst`
- `test/run_tests.m`
- `docs/rectangular-solve.md`
- `docs/linear-solve.md`
- `docs/milestones/M15-rgels.md`
- `docs/milestones/README.md`
- `README.md`
- `NEWS.md`
- `tools/local-ci.sh`
- `tools/build-package.sh`
- `tools/check-tree.sh`
- `tools/check-format.sh`

The five pre-existing deleted legacy report files remain unstaged.

## Commits

- `e051111` — M15: add full-rank rectangular mp solve via MPLAPACK Rgels
- follow-up documentation commit — this report

## Push

- Push: pending
- Remote tip: pending
- Local tip: pending report commit
- GitHub CI: pending PR creation

## Known limitations

- Rank-deficient rectangular solve remains unsupported
- Rank-revealing least-squares driver remains future work
- Condition/rank estimation remains unsupported
- Complex matrices unsupported
- Sparse matrices unsupported
- General vector linear indexing remains deferred
- Matrix growth/deletion assignment remain unsupported
- Other limitations: no direct transpose-aware `Rgels` optimization; only `TRANS = "N"`

## Recommended next action

Review and merge the M15 PR. Then define M16 around rank-deficient rectangular
solving only after comparing `Rgelsy`, `Rgelss`, and `Rgelsd` for MPFR precision
semantics, workspace behavior, and desired Octave compatibility.
