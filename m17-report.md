# M17 RESULT

Repository: `nakatamaho/octave-mplapack`
Remote: `origin https://github.com/nakatamaho/octave-mplapack.git`
Branch: `topic/m17-cholesky`
Starting commit: `b21011e41ec170bfb66c9fd7c92d3149ee5306c8`
Final commit: `dba701dd62878409ffd8e4ffe854c8c95d8154da`
PR: #18 (https://github.com/nakatamaho/octave-mplapack/pull/18)

## Baseline

- M16 accepted base: `b21011e41ec170bfb66c9fd7c92d3149ee5306c8`
- M16 implementation commit: `c22ad4d`
- MPLAPACK dependency: `1cf03d1a1aa2afecde5f1840fbe9663ecfc31e57`
- Fresh project default: 512 bits
- Fresh current-thread MPFR default: 512 bits

## MPLAPACK Rpotrf audit

- Installed signature: `Rpotrf(const char*, mplapackint, mpfrxx::mpfr_class*, mplapackint, mplapackint&)`
- Source commit: `1cf03d1a1aa2afecde5f1840fbe9663ecfc31e57`
- Runtime library: `/tmp/mplapack-m08-shared-prefix.FEIaI6/lib/libmplapack_mpfr.so.3`
- libmplapack_mpfr_opt linked: no
- Reference call chain: `Rpotrf` -> blocked `Rsyrk`/`Rpotrf2`/`Rgemm`/`Rtrsm`; unblocked `Rpotrf2`
- Nested BLAS/LAPACK: `Rsyrk`, `Rpotrf2`, `Rgemm`, `Rtrsm`
- Parallel regions: none found in the audited reference path
- Worker precision propagation: no worker threads in the audited path; same-thread scope is sufficient
- Scope architecture sufficient: yes

## Native architecture

- Native source: `src/mp_lapack.cc`, declaration in `src/mp_lapack.h`, bridge in `src/octave_bridge.cc`
- Public method: `inst/@mp/chol.m`
- p_op: `precision(A)`
- A_work: operation-owned deep copy, `n x n`, uniformly p_op precision
- lda: checked `MpfrMatrixStorage::leading_dimension()` (`max(1,n)`)
- UPLO: `"U"` by default/upper, `"L"` for lower
- MPLAPACK routine: `Rpotrf`
- Input mutation: none; public A is never passed as writable storage
- Result ownership: independent native scalar or dense matrix payload
- Precision scope: `MplapackMpfrPrecisionScope(p_op)` around Rpotrf
- Precision-state restoration: RAII verified on success, one-output error, and two-output status paths

## Public API

- chol(A): passes; default upper
- chol(A,"upper"): passes
- chol(A,"lower"): passes
- [R,p]=chol(A): passes
- [L,p]=chol(A,"lower"): passes
- p public type: builtin `double` scalar
- Invalid option: clean `mplapack:mp:InvalidOption` error
- Non-square: clean `mplapack:mp:NonSquareMatrix` error
- >2 outputs: clean `mplapack:mp:OutputCount` error
- Sparse: rejected
- Complex: rejected

## Upper semantics

- Default == upper: pass
- Ignored lower triangle: ignored, including NaN/Inf
- Exact asymmetric fixture: `[4 2; 999 10]`
- Expected R: `[2 1; 0 3]`
- Result: pass, p = 0
- Strict lower zero: exact +0
- Reconstruction: `R.' * R` matches selected symmetric matrix

## Lower semantics

- Ignored upper triangle: ignored, including NaN/Inf
- Exact asymmetric fixture: `[4 999; 2 10]`
- Expected L: `[2 0; 1 3]`
- Result: pass, p = 0
- Strict upper zero: exact +0
- Reconstruction: `L * L.'` matches selected symmetric matrix

## Positive-definite behavior

- Basic SPD: pass (`[4 2;2 10]`)
- Larger exact SPD: native exact-factor coverage pass
- Semidefinite: p > 0 / one-output error
- Indefinite: p > 0 / one-output error
- Positive scalar: `chol(4) == 2`, scalar payload, p = 0
- Zero scalar: p = 1, two-output partial `0x0`, one-output error
- Negative scalar: p = 1, two-output partial `0x0`, one-output error

## One-output non-PD

- Behavior: deterministic `mplapack:mp:NotPositiveDefinite` error
- Error identifier: `mplapack:mp:NotPositiveDefinite`
- TLS restored: pass
- A unchanged: pass

## Two-output non-PD

- Behavior: no throw solely for non-PD; returns factor and p
- p: Rpotrf info (1, 2, or later pivot)
- p mapping: pass; partial factor contains the leading `p-1` factor
- Result shape: `(p-1) x (p-1)` (0x0 for p=1)
- Partial-factor semantics: matches builtin dense Octave for audited p=1/2/3 fixtures
- Builtin Octave differential QA: pass for status, shape, and exact simple entries
- TLS restored: pass
- A unchanged: pass

## Precision 1024

- Source precision: 1024 bits
- Outside default: 128 bits
- delta: 2^-700
- Expected tail: 2^-350
- Upper: pass
- Lower: pass
- p: 0
- Tail preserved: pass
- Result precision: 1024 bits
- TLS restored: pass

## Precision 2048

- Source precision: 2048 bits
- Outside default: 128 bits
- delta: 2^-1500
- Expected tail: 2^-750
- Upper: pass
- Lower: pass
- Tail preserved: pass
- Result precision: 2048 bits

## Precision-dependent PD canary

### 512-bit source
- Stored A(2,2): rounded to 1 for the 2^-700 construction
- p: 2
- Expected: non-positive-definite
- Result: 1x1 leading partial factor

### 1024-bit source
- Stored A(2,2): 1 + 2^-700
- p: 0
- Expected: positive definite
- Result: full 2x2 factor with 2^-350 tail

## High ambient default

- Source precision: 256 bits
- Ambient: 4096 bits
- Result precision: 256 bits
- Classification: unchanged by ambient default
- TLS after: 4096 bits

## Special values

- NaN selected triangle: deterministic Rpotrf status; no crash
- Inf selected triangle: deterministic Rpotrf behavior; no crash
- Ignored-triangle NaN: valid factorization succeeds
- Ignored-triangle Inf: valid factorization succeeds
- Signed zero cleanup: unused triangle set to exact +0
- Result: special-value movement/copying is precision-preserving; selected NaN follows backend status semantics

## Immutability

- A unchanged on success: pass
- A unchanged on one-output failure: pass
- A unchanged on p>0: pass
- Aliased A unchanged: pass by operation-owned copy design
- Clear A then use factor: pass

## Interoperability

- indexing: pass
- double: pass
- disp: pass
- arithmetic: pass
- transpose: pass
- reshape: pass
- concatenation: pass
- assignment: pass
- R.'*R: pass through existing Rgemm
- L*L.': pass through existing Rgemm
- mldivide: pass through existing square Rgesv where dimensions permit

## Robustness

- Repeated alternating precision: pass in native/public regression
- Installed package: pass, including unload/reinstall and chol.tst
- Clear/reload: pass
- ASan: pass
- UBSan: pass
- LSan: pass via sanitizer targets
- Existing M00-M16 regression: pass via `tools/local-ci.sh`
- git diff --check: pass

## Gates

- G17-UPSTREAM: PASS
- G17-PRECISION: PASS
- G17-TRIANGLE: PASS
- G17-PD: PASS
- G17-PUBLIC: PASS
- G17-PARTIAL: PASS
- G17-IMMUTABILITY: PASS
- G17-RECONSTRUCT: PASS
- G17-INTEROP: PASS
- G17-ROBUSTNESS: PASS

M17 PASS

## Code changes

Added a precision-preserving native `Rpotrf` bridge, selected-triangle upper/
lower public `chol` dispatch, optional status/partial-factor handling, and
operation-owned deep-copy isolation. Added native/public precision, special
value, lifecycle, sanitizer, linkage, and installed-package QA plus
Cholesky documentation and milestone CI integration.

## Files changed

- `src/mp_lapack.h`
- `src/mp_lapack.cc`
- `src/octave_bridge.cc`
- `inst/@mp/chol.m`
- `src/Makefile`
- `test/mp_lapack_cholesky_test.cc`
- `test/m17_rpotrf_probe.cc`
- `test/chol.tst`
- `test/run_tests.m`
- `docs/cholesky.md`
- `docs/milestones/M17-cholesky.md`
- `docs/milestones/README.md`
- `README.md`
- `NEWS.md`
- `tools/check-tree.sh`
- `tools/check-format.sh`
- `tools/build-package.sh`
- `tools/local-ci.sh`

## Commits

- `6968de5` — M17: add dense mp Cholesky factorization via MPLAPACK Rpotrf
- `dba701d` — test: cover ignored-triangle infinity in M17 chol
- `m17-report` — this milestone report

## Push

- Push: pass; `topic/m17-cholesky` pushed to origin
- Remote tip: `51bdc59f00b5f1819b011a2dda78cb6ae85610f9`
- Local tip: `51bdc59f00b5f1819b011a2dda78cb6ae85610f9`
- GitHub CI: pending/observed through PR #18

## Known limitations

- Dense real only
- Sparse Cholesky unsupported
- Complex Hermitian Cholesky unsupported
- Dense three-output permutation form unsupported
- cholupdate/cholinsert/choldelete/cholshift unsupported
- cholinv/chol2inv unsupported
- Automatic SPD mldivide optimization unsupported
- Selected-triangle NaN behavior follows the installed MPFR backend rather than a custom policy

## Recommended next action

Review and merge PR #18. Define M18 independently; do not automatically
change mldivide to use Cholesky merely because `chol(A)` is now available.
