# M18 RESULT

Repository: nakatamaho/octave-mplapack
Remote: https://github.com/nakatamaho/octave-mplapack.git
Branch: topic/m18-qr
Starting commit: 77d667a26c4a46aafc73034786d3adb47d3ebfa9
Final commit: e91f2f7 (implementation; report/metadata commits follow)
PR: pending (to be created after push)

## Baseline

- M17 accepted base: 77d667a26c4a46aafc73034786d3adb47d3ebfa9 (M17 implementation series included dba701dd62878409ffd8e4ffe854c8c95d8154da; PR #18)
- Fresh project default: 512 bits
- Fresh current-thread MPFR default: 512 bits

## MPLAPACK QR audit

### Rgeqrf
- Installed signature: void Rgeqrf(mplapackint const m, mplapackint const n, mpfr_class *a, mplapackint const lda, mpfr_class *tau, mpfr_class *work, mplapackint const lwork, mplapackint &info)
- Source call chain: blocked Rgeqr2/Rlarft/Rlarfb path with final Rgeqr2 cleanup; workspace query writes WORK(1)
- Parallel regions: none found in the pinned path
- Worker precision: same-thread MplapackMpfrPrecisionScope(p_op) is sufficient
- Workspace query: LWORK=-1 under the operation precision scope, followed by fresh factor/work buffers
- Scope sufficient: yes

### Rorgqr
- Installed signature: void Rorgqr(mplapackint const m, mplapackint const n, mplapackint const k, mpfr_class *a, mplapackint const lda, mpfr_class *tau, mpfr_class *work, mplapackint const lwork, mplapackint &info)
- Source call chain: blocked Rlarft/Rlarfb/Rorg2r path or unblocked Rorg2r; workspace query writes WORK(1)
- Parallel regions: none found in the pinned path
- Worker precision: same-thread MplapackMpfrPrecisionScope(p_op) is sufficient
- Workspace query: independent LWORK=-1 query under the operation precision scope, with fresh Q/work buffers
- Scope sufficient: yes

- Runtime library: controlled /tmp/mplapack-m08-shared-prefix.FEIaI6/lib/libmplapack_mpfr.so.3
- libmplapack_mpfr_opt linked: no

## Native architecture

- Native source: src/mp_lapack.cc, src/mp_lapack.h, src/octave_bridge.cc
- Public method: inst/@mp/qr.m
- p_op: stored precision of input A
- A_work: operation-owned contiguous column-major deep copy at p_op; overwritten by Rgeqrf
- TAU: operation-owned min(m,n)-element p_op MPFR storage
- Rgeqrf WORK: queried, checked, operation-owned p_op storage
- Q_work: independent m x nq p_op storage populated from Householder data
- Rorgqr WORK: independently queried, checked, operation-owned p_op storage
- Input mutation: none; public A is never passed to destructive MPLAPACK calls
- Result ownership: Q and R own independent native storage; one-output returns R without Q generation
- TLS restoration: RAII scope restores the prior current-thread MPFR default on all tested paths

## Public semantics

- qr(A) single output: returns R, not Q
- [Q,R]=qr(A): full non-pivoted QR
- qr(A,"econ"): economy R
- [Q,R]=qr(A,"econ"): economy Q,R
- qr(A,0): accepted as deprecated economy alias
- [Q,R]=qr(A,0): accepted as deprecated economy alias
- Three outputs: rejected cleanly; pivoted QR is deferred
- qr(A,B): rejected cleanly
- Pivot options: rejected cleanly
- Sparse: rejected
- Complex: rejected

## Full QR shapes

### Tall
- A: 4 x 2
- Q shape: 4 x 4
- R shape: 4 x 2
- Reconstruction: PASS with MPFR-native residual checks
- Orthogonality: PASS with MPFR-native checks

### Square
- Q shape: m x m
- R shape: m x n (m = n)
- Reconstruction: PASS
- Orthogonality: PASS

### Wide
- Q shape: 2 x 2
- R shape: 2 x 4
- Reconstruction: PASS
- Orthogonality: PASS

## Economy QR

### Tall
- Q shape: 4 x 2
- R shape: 2 x 2
- Reconstruction: PASS
- Orthogonality: PASS (Q.'*Q = I)

### m <= n
- Full/econ parity: PASS
- Shapes: both use Q m x m and R m x n
- Result: PASS

## One-output behavior

- Full R: correct full R shape and values
- Economy R: correct economy R shape and values
- Rorgqr called: no; one-output path stops after Rgeqrf/R extraction
- R parity with two-output path: PASS

## Workspace

### Rgeqrf
- Query precision: p_op
- Query conversion: checked MPFR integer conversion; no double cast
- Query mutation: audited defensively; A/TAU/work are recreated before the real call
- LWORK: validated against mplapackint and allocation limits
- WORK precision: uniformly p_op

### Rorgqr
- Query precision: p_op
- Query conversion: checked MPFR integer conversion; no double cast
- Query mutation: audited defensively; Q/TAU/work are recreated before the real call
- LWORK: validated against mplapackint and allocation limits
- WORK precision: uniformly p_op

## Numerical QA

- Dense reconstruction bound: MPFR-native precision-scaled bound; PASS
- Full orthogonality bound: MPFR-native precision-scaled bound; PASS
- Economy orthogonality bound: MPFR-native precision-scaled bound; PASS
- R structural zeros: exact +0 below the upper trapezoid; PASS
- Sign ambiguity handled correctly: invariant-based QA for generic matrices; PASS

## 1024-bit regression

- Source precision: 1024 bits
- Outside default: 128 bits
- Fixture: upper-trapezoidal matrix containing 1 + 2^-700
- Q precision: 1024 bits
- R precision: 1024 bits
- Tail preserved: PASS
- Reconstruction: PASS
- Orthogonality: PASS
- TLS restored: PASS (128 bits)

## 2048-bit regression

- Source precision: 2048 bits
- Outside default: 128 bits
- Fixture: upper-trapezoidal matrix containing 1 + 2^-1500
- Tail preserved: PASS
- Reconstruction: PASS
- Orthogonality: PASS

## High ambient default

- Source precision: 256 bits
- Ambient: 4096 bits
- Q precision: 256 bits
- R precision: 256 bits
- Numerical result: PASS
- TLS after: 4096 bits

## Source-precision canary

- 512-bit stored value: source precision controls the stored value; tails below that precision are not recovered
- 1024-bit stored value: distinguishing high-precision tail remains present
- QR results: reflect stored source values at source precision
- Ambient independence: PASS

## Scalar / empty

- Positive scalar: QR-compatible scalar result with Q=1 and R=scalar; PASS
- Negative scalar: audited against Octave scalar shape/value semantics; PASS
- 0x0: full/economy 0x0 results; PASS
- 0xN: Q 0x0 and R 0xN; PASS
- Mx0: full Q MxM/R Mx0 and economy Q Mx0/R 0x0; PASS
- Economy: empty and scalar forms follow the documented shape rules
- Builtin Octave differential QA: PASS

## Special values

- NaN: deterministic/no crash behavior; PASS
- Inf: deterministic/no crash behavior; PASS
- Signed zero: structural R cleanup uses deterministic +0; PASS
- Error/status behavior: invalid inputs/options fail cleanly and restore precision state
- TLS restoration: PASS

## Immutability

- A unchanged one-output: PASS
- A unchanged two-output: PASS
- A unchanged full: PASS
- A unchanged econ: PASS
- Alias unchanged: PASS
- Clear A then use Q/R: PASS

## Interoperability

- indexing: PASS
- double: PASS
- disp: PASS
- arithmetic: PASS
- transpose: PASS
- reshape: PASS
- concatenation: PASS
- assignment: PASS
- Q*R: PASS through existing Rgemm
- mldivide: PASS where dimensions permit

## Robustness

- Repeated alternating precision: PASS
- Installed package: PASS (isolated build/install/unload/reinstall)
- Clear/reload: PASS
- ASan: PASS
- UBSan: PASS
- LSan: PASS through sanitized local CI
- Existing M00-M17 regression: PASS
- git diff --check: PASS

## Gates

- G18-UPSTREAM: PASS
- G18-FULL: PASS
- G18-ECON: PASS
- G18-PRECISION: PASS
- G18-WORKSPACE: PASS
- G18-PUBLIC: PASS
- G18-IMMUTABILITY: PASS
- G18-NUMERICAL: PASS
- G18-INTEROP: PASS
- G18-ROBUSTNESS: PASS

M18 PASS

## Code changes

Added native precision-preserving QR using installed MPLAPACK MPFR Rgeqrf and
Rorgqr, checked workspace queries/conversions, operation-owned destructive
buffers, full/economy extraction, scalar/empty handling, public qr dispatch,
numerical and precision QA, documentation, and installed package/local-CI
coverage. One-output QR returns R without generating Q.

## Files changed

- src/mp_lapack.cc
- src/mp_lapack.h
- src/octave_bridge.cc
- inst/@mp/qr.m
- src/Makefile
- test/mp_lapack_qr_test.cc
- test/m18_qr_probe.cc
- test/qr.tst
- test/run_tests.m
- docs/qr.md
- docs/milestones/M18-qr.md
- docs/milestones/README.md
- README.md
- NEWS.md
- tools/local-ci.sh
- tools/check-tree.sh
- tools/check-format.sh
- tools/build-package.sh

## Commits

- e91f2f7 — M18: add dense mp QR factorization via MPLAPACK Rgeqrf/Rorgqr
- report metadata commit: pending

## Push

- Push: pending
- Remote tip: pending
- Local tip: pending
- GitHub CI: pending

## Known limitations

- Pivoted QR / third output P remains unsupported
- qr(A,B) remains unsupported
- qrupdate/insert/delete/shift remain unsupported
- Public rank remains unsupported
- Complex QR unsupported
- Sparse QR unsupported
- Other limitations: N-D QR and additional QR option forms remain deferred

## Recommended next action

If M18 PASS:
Review and merge the M18 PR.

Define M19 separately. A natural M19 is pivoted dense QR using
Rgeqp3 and Octave-compatible [Q,R,P] / permutation-vector semantics, but do
not begin it automatically.

Otherwise:
State the exact blocker and stop.

