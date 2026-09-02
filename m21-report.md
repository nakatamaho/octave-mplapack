# M21 RESULT

Repository: nakatamaho/octave-mplapack
Remote: origin https://github.com/nakatamaho/octave-mplapack.git
Branch: topic/m21-lu
Starting commit: ab810c1747c3b558752a296b0017ef76ef7a8d24
Final commit: implementation commit to be recorded after final report commit
PR: to be created after push

## Baseline

- M20 accepted base: actual accepted M20 state at ab810c1
- M20 REAL-PPA decision: REAL-PPA-GO
- MPLAPACK dependency: 1cf03d1a1aa2afecde5f1840fbe9663ecfc31e57 (installed 3.0.1)
- Fresh project default: 512 bits
- Fresh current-thread MPFR default: 512 bits

## MPLAPACK Rgetrf audit

- Installed signature: void Rgetrf(mplapackint const, mplapackint const, mpfr_class*, mplapackint const, mplapackint*, mplapackint&)
- Source call chain: Rgetrf blocked path -> Rgetrf2, Rlaswp, Rtrsm, Rgemm; unblocked path -> Rgetrf2
- Partial pivoting: row partial pivoting
- IPIV type: mplapackint
- IPIV semantics: one-based row-swap sequence; replayed to final row permutation
- INFO semantics: zero success, negative invalid argument, positive zero diagonal in U
- Parallel regions: none found in the selected pinned reference path
- Worker precision: no worker arithmetic path; same-thread scope is sufficient
- Runtime library: controlled libmplapack_mpfr.so.3
- libmplapack_mpfr_opt linked: no
- Scope sufficient: yes

## Native architecture

- Native source: src/mp_lapack.cc, src/mp_lapack.h
- Public method: inst/@mp/lu.m
- p_op: precision(A)
- A_work: operation-owned contiguous m x n MPFR copy
- IPIV: operation-owned mplapackint[min(m,n)]
- INFO: retained in native result; positive status is non-fatal
- Input mutation: none
- Result ownership: packed/L/U deep native values; P/p independent builtin doubles
- TLS restoration: RAII MplapackMpfrPrecisionScope

## Workspace

- Workspace query: none; Rgetrf has no WORK/LWORK interface
- REAL workspace: none supplied by the caller; nested REAL temporaries run under p_op scope
- Integer workspace: operation-owned mplapackint IPIV[min(m,n)]
- Checked dimensions: m, n, lda, and k validated against mplapackint
- Checked allocations: matrix element counts and pivot-vector byte count checked
- Result: pass

## Public API

- lu(A): packed Rgetrf factor, shape-compatible for nonempty input
- [L,U]=lu(A): permutation absorbed into L, A=L*U
- [L,U,P]=lu(A): canonical factors, P*A=L*U
- [L,U,p]=lu(A,"vector"): canonical factors, A(p,:)=L*U
- P public type: builtin double matrix
- p public type: builtin double column vector, 1-based
- p orientation: column
- dense >3 outputs: rejected
- threshold argument: rejected; only "vector" is accepted
- sparse: rejected
- complex: rejected

## Packed one-output

- Shape: verified for square/tall/wide and builtin empty behavior
- Simple fixture: [1 2;3 4] -> packed [[3,4];[1/3,2/3]]
- Packed upper U: preserved
- Packed lower multipliers: preserved
- Unit L diagonal stored: implicit, not encoded
- Permutation encoded: no
- Builtin Octave differential: pass
- Precision: source precision

## Three-output LU

### Square
- A: [1 2;3 4]
- L shape: 2 x 2
- U shape: 2 x 2
- P shape: 2 x 2
- P*A=L*U: pass

### Tall
- L shape: m x n
- U shape: n x n
- P shape: m x m
- Reconstruction: pass

### Wide
- L shape: m x m
- U shape: m x n
- P shape: m x m
- Reconstruction: pass

## Vector LU

- IPIV: audited as swap sequence, not returned directly
- Derived p: final one-based permutation
- p 1-based: pass
- p orientation: column
- Multi-pivot fixture: pass (2 x 2 and 3 x 2 probes)
- A(p,:)=L*U: pass
- P*A=A(p,:): pass

## Two-output LU

- L shape: m x min(m,n)
- U shape: min(m,n) x n
- Permutation absorption: direct inverse-permutation row copy
- Simple pivot fixture: pass
- Multi-pivot fixture: pass
- Square A=L*U: pass
- Tall A=L*U: pass
- Wide A=L*U: pass

## Pivot precision canary

### 512-bit source
- Stored A(2,1): 1 (2^-700 is rounded away)
- Ambient: 128 bits
- Expected first pivot: row 1
- Actual first pivot: row 1
- Final p: verified

### 1024-bit source
- Stored A(2,1): 1+2^-700
- Ambient: 128 bits
- Expected first pivot: row 2
- Actual first pivot: row 2
- Final p: verified

### High ambient
- Source precision: 256 bits
- Ambient: 4096 bits
- Pivot: source-precision result
- Result: pass

## 1024-bit regression

- Source precision: 1024 bits
- Outside default: 128 bits
- Fixture: first multiplier (1+2^-700)/4
- Pivot: identity
- L tail: preserved
- U: correct
- Reconstruction: pass
- Result precision: 1024 bits
- TLS restored: pass

## 2048-bit regression

- Source precision: 2048 bits
- Outside default: 128 bits
- Fixture: first multiplier (1+2^-1500)/4
- L tail: preserved
- Reconstruction: pass
- Result precision: 2048 bits

## Singular behavior

- Fixture: [1 2;2 4]
- Rgetrf info: 2
- lu(A): completed packed factor returned
- [L,U]: completed factors returned
- [L,U,P]: completed factors returned
- [L,U,p]: completed factors returned
- Reconstruction: pass
- Error/warning behavior: no solve-style singular error
- Builtin Octave differential: pass

## Scalar / empty

- Positive scalar: pass
- Negative scalar: pass
- Zero scalar: pass
- 0x0: builtin-compatible 0x0 outputs
- 0xN: builtin-compatible 0x0 outputs
- Mx0: builtin-compatible 0x0 outputs
- P/p empty semantics: 0x0
- Builtin Octave differential: pass

## Immutability

- A unchanged one-output: pass
- A unchanged two-output: pass
- A unchanged matrix-P: pass
- A unchanged vector-p: pass
- A unchanged singular: pass
- Alias unchanged: pass
- Clear A then use outputs: pass

## Interoperability

- Y indexing: pass
- L/U indexing: pass
- double: pass
- disp: pass
- arithmetic: pass
- transpose: pass
- reshape: pass
- concatenation: pass
- assignment: pass
- P*A: pass
- A(p,:): pass
- L*U: pass
- mldivide: pass

## Robustness

- Repeated alternating precision: native/public coverage pass
- Precision-state restoration: pass
- Installed package: pass; isolated install/unload/reinstall LU smoke QA
- Clear/reload: pass; outputs survive parent clear and native module lifecycle
- ASan: native LU pass
- UBSan: native LU pass
- LSan: native LU pass
- Existing M00-M20 regression: pass; full M00-M21 local CI
- git diff --check: pass

## Gates

- G21-UPSTREAM: PASS
- G21-PACKED: PASS
- G21-TWO-OUTPUT: PASS
- G21-THREE-OUTPUT: PASS
- G21-VECTOR: PASS
- G21-PIVOT-PRECISION: PASS
- G21-PRECISION: PASS
- G21-SINGULAR: PASS
- G21-OCTAVE: PASS
- G21-IMMUTABILITY: PASS
- G21-RECONSTRUCT: PASS
- G21-INTEROP: PASS
- G21-ROBUSTNESS: PASS

M21 PASS

## Code changes

Native Rgetrf bridge, public @mp/lu, native and installed probes, public
tests, documentation, and CI/package QA integration.

## Files changed

Native Rgetrf bridge and public LU API are in the implementation commits;
the root report is finalized separately.  Unrelated legacy report deletions
predate M21 and are intentionally not staged.

## Commits

The implementation, public API/QA, and final report commits are listed below
after they are created.

## Push

- Push: pending final push
- Remote tip: pending final push verification
- Local tip: pending final report commit
- GitHub CI: not run; local CI is the available deterministic gate

## Known limitations

- Dense real only
- Sparse LU/UMFPACK unsupported
- Sparse threshold/Q/R outputs unsupported
- Complex LU deferred to complex series
- luupdate unsupported
- det/inv/rank/condition APIs not added
- triangular solve optimizations not added

## Recommended next action

Review and merge M21, then proceed to M22 real API/release closure.
Do not begin M22 automatically.

Branch: topic/m21-lu
Starting commit: ab810c1747c3b558752a296b0017ef76ef7a8d24
Final commit: recorded after the final report commit
Files changed: M21 native bridge, public method, probes, tests, docs, and CI wiring; legacy report deletions excluded
Commands run: git status/log/remote; make -C src check-lu; tools/check-tree.sh; tools/check-format.sh; tools/local-ci.sh; git diff --check
Tests: full tools/local-ci.sh PASS, including ASan/UBSan/LSan, native and installed probes, source and installed package QA, lifecycle, and M00-M21 regression
Gate: M21 PASS
Known limitations: as listed above
