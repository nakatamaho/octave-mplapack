# M19 RESULT

Repository: https://github.com/nakatamaho/octave-mplapack
Remote: origin (https://github.com/nakatamaho/octave-mplapack.git)
Branch: topic/m19-pivoted-qr
Starting commit: b5f7e9237925dbf0d8fe2ecaa6139c7c80c2f4fe
Final commit: 36cb203d6acea6f151be2632374f878d284c06e4
PR: #20 — https://github.com/nakatamaho/octave-mplapack/pull/20

## Baseline

- M18 accepted base: b5f7e9237925dbf0d8fe2ecaa6139c7c80c2f4fe
- M18 implementation commit: e91f2f71d58ae5ed1cae318c499528ab3294be6d
- MPLAPACK dependency: 1cf03d1a1aa2afecde5f1840fbe9663ecfc31e57
- Fresh project default: 512 bits
- Fresh current-thread MPFR default: 512 bits

## MPLAPACK Rgeqp3 audit

- Installed signature: `Rgeqp3(mplapackint m, mplapackint n, mpfr_class *a, mplapackint lda, mplapackint *jpvt, mpfr_class *tau, mpfr_class *work, mplapackint lwork, mplapackint &info)`
- Source call chain: `Rgeqp3` uses fixed/free-column handling, `Rgeqrf`, `Rormqr`, and blocked/unblocked `Rlaqps`/`Rlaqp2` paths in the pinned source.
- JPVT input semantics: all-zero JPVT marks every column free for pivoting.
- JPVT output semantics: returned entries are 1-based source-column positions in permuted order; the [1,4,2] fixture returns `[2 3 1]`.
- Workspace query: `LWORK=-1`, query result stored in p_op-precision `WORK(1)`.
- Parallel regions: none found in Rgeqp3/Rlaqps/Rlaqp2 or the selected reference path.
- Worker precision: same-thread MPLAPACK scope is sufficient; no unscoped arithmetic worker was found.
- Runtime library: `/tmp/mplapack-m08-shared-prefix.FEIaI6/lib/libmplapack_mpfr.so.3`
- libmplapack_mpfr_opt linked: no
- Scope sufficient: yes; external 1024/2048-bit probes pass and restore TLS.

## Native architecture

- Native source: `src/mp_lapack.h`, `src/mp_lapack.cc`, `src/octave_bridge.cc`
- Public method: `inst/@mp/qr.m`
- Pivot trigger: three outputs; one/two-output forms remain M18 non-pivoted QR.
- p_op: stored precision of A.
- A_work: operation-owned deep copy, uniformly p_op precision.
- JPVT: operation-owned `mplapackint[n]`, initialized to zero and validated.
- TAU: operation-owned uniformly p_op-precision reflector vector.
- Rgeqp3 WORK: queried, checked, and allocated uniformly at p_op.
- Q generation: shared M18 `Rorgqr` extraction/generation helper.
- Rorgqr WORK: independently queried and checked at p_op.
- Input mutation: public A is never passed to destructive routines.
- Result ownership: Q/R are independent native dense values; P/p are independent builtin values.
- TLS restoration: RAII `MplapackMpfrPrecisionScope` restores the prior default on all tested paths.

## Public pivoted API

- [Q,R,P]=qr(A): supported, full matrix-permutation form.
- [Q,R,P]=qr(A,"matrix"): supported and equivalent matrix form.
- [Q,R,p]=qr(A,"vector"): supported, full 1-based vector form.
- [Q,R,P]=qr(A,"econ"): supported with audited economy shapes.
- [Q,R,p]=qr(A,0): supported deprecated economy/vector compatibility form.
- Other audited option combinations: one/two-output `"matrix"`/`"vector"` retain non-pivoted M18 behavior; multiple option arguments and undocumented combinations are rejected.
- qr(A,B): rejected as unsupported.
- Sparse: rejected.
- Complex: rejected.

## Permutation outputs

### Matrix P

- Public type: builtin `double`.
- Shape: `n x n`.
- 0/1 structure: validated by deterministic fixtures.
- Row sums: one.
- Column sums: one.
- Q*R=A*P: passes MPFR-native reconstruction and public mixed `mp`/double multiplication.

### Vector p

- Public type: builtin `double`.
- Shape: `1 x n`.
- 1-based: yes.
- Permutation validity: range, uniqueness, and ordering validated.
- Q*R=A(:,p): passes native and public indexing reconstruction.

### Matrix/vector consistency

- A*P=A(:,p): passes.
- PASS: yes.

## Deterministic pivot fixture

- A: diagonal columns with norms `1, 4, 2`.
- Column norm ordering: second, third, first.
- Expected p: `[2 3 1]`.
- Actual p: `[2 3 1]`.
- P: corresponding source-row/position-column permutation matrix.
- Q*R relation: passes.
- abs(diag(R)) ordering: passes for separated magnitudes.
- PASS: yes.

## Rectangular pivot fixture

- Shape: tall `4x3` and wide `2x4`.
- Expected p: tall separated fixture `[2 3 1]`; wide is a validated permutation.
- Actual p: matches expected/validity checks.
- Full: passes.
- Economy: passes.
- Reconstruction: passes.
- Orthogonality: passes.

## Pivot precision canary

### 512-bit source

- Stored values: second `1+2^-700` rounds to `1`.
- Ambient: 512/4096 in the public audit.
- Expected pivot: `[1 2]`.
- Actual pivot: `[1 2]`.

### 1024-bit source

- Stored values: second column retains `1+2^-700`.
- Ambient: 128/4096 in the public audit.
- Expected pivot: `[2 1]`.
- Actual pivot: `[2 1]`.

### High ambient

- Source precision: 1024-bit canary.
- Ambient: 4096 bits.
- Expected pivot: `[2 1]`.
- Actual pivot: `[2 1]`.

## 1024-bit regression

- Source precision: 1024 bits.
- Outside default: 128 bits.
- Fixture: separated-norm pivot fixture containing a `2^-700` tail.
- Pivot: correct and stable.
- Q precision: 1024 bits.
- R precision: 1024 bits.
- Tail preserved: yes (native reconstruction).
- Reconstruction: passes.
- Orthogonality: passes.
- TLS restored: yes.

## 2048-bit regression

- Source precision: 2048 bits.
- Outside default: 128 bits.
- Fixture: separated-norm fixture containing a `2^-1500` tail.
- Pivot: correct.
- Tail preserved: yes (native exact-tail check).
- Reconstruction: passes.
- Orthogonality: passes.

## Full/economy

- Tall full Q/R/P: `Q=4x4`, `R=4x3`, `P=3x3`, passes.
- Tall econ Q/R/P: `Q=4x3`, `R=3x3`, `P=3x3`, passes.
- Wide full: `Q=2x2`, `R=2x4`, passes.
- Wide econ: same shapes as full, passes.
- Full/econ permutation parity: passes on deterministic fixtures.
- Numeric 0 behavior: three outputs use economy/vector semantics; M18 one/two-output alias remains unchanged.

## M18 parity

- qr(A): remains non-pivoted one-output R.
- [Q,R]=qr(A): remains non-pivoted.
- qr(A,"econ"): remains non-pivoted economy R.
- [Q,R]=qr(A,"econ"): remains non-pivoted economy Q/R.
- qr(A,0) one output: unchanged.
- qr(A,0) two outputs: unchanged.
- Rgeqrf still used: yes for all one/two-output forms.
- Result: PASS.

## Scalar / empty

- Scalar matrix P: audited and returns builtin structural output.
- Scalar vector p: audited and returns 1-based builtin vector.
- 0x0: audited.
- 0xN: audited with identity permutation outputs.
- Mx0: audited with empty permutation outputs.
- Economy: audited for all empty shapes.
- Builtin Octave differential QA: passes shape/type/options for supported forms.

## Rank-deficient

- Fixture: dependent-column dense matrix.
- Pivot: valid Rgeqp3 permutation.
- Reconstruction: passes.
- Orthogonality: passes.
- Public rank exposed: no.
- Result: ordinary pivoted QR only; rank inference remains deferred.

## Immutability

- A unchanged matrix-P path: yes.
- A unchanged vector-p path: yes.
- A unchanged economy: yes.
- Alias unchanged: yes.
- Clear A then use Q/R/P/p: passes.

## Interoperability

- indexing: passes, including `A(:,p)`.
- A(:,p): passes.
- A*P: passes through mixed `mp`/double `mtimes`.
- Q*R: passes through Rgemm.
- Q.'*Q: passes through transpose/Rgemm.
- double: passes.
- disp: passes.
- arithmetic: passes.
- transpose: passes.
- reshape: passes.
- concatenation: outputs remain ordinary dense `mp` values.
- assignment: outputs retain M14 value semantics.
- mldivide: no dispatch change; interoperability retained.

## Robustness

- Repeated alternating precision: passes in existing and M19 precision tests.
- Installed package: build/install/reinstall QA passes, including pivoted smoke and `pivoted_qr.tst`.
- Clear/reload: passes.
- ASan: passes.
- UBSan: passes.
- LSan: passes where enabled by local CI.
- Existing M00-M18 regression: passes.
- git diff --check: passes.

## Gates

- G19-UPSTREAM: PASS
- G19-PERMUTATION: PASS
- G19-PIVOT: PASS
- G19-ECON: PASS
- G19-PRECISION: PASS
- G19-WORKSPACE: PASS
- G19-PUBLIC: PASS
- G19-M18-PARITY: PASS
- G19-IMMUTABILITY: PASS
- G19-INTEROP: PASS
- G19-ROBUSTNESS: PASS

M19 PASS

## Code changes

Added the native `Rgeqp3` bridge with checked workspace handling, JPVT
validation, shared `Rorgqr` Q generation, and immutable operation-owned
buffers. Added public three-output QR parsing for matrix/vector permutations,
M19 native/public tests and installed probes, CI/linkage/archive checks, and
pivoted-QR documentation. M18 non-pivoted dispatch remains intact.

## Files changed

- `src/mp_lapack.h`, `src/mp_lapack.cc`, `src/octave_bridge.cc`, `src/Makefile`
- `inst/@mp/qr.m`
- `test/m19_qr_probe.cc`, `test/mp_lapack_pivoted_qr_test.cc`, `test/pivoted_qr.tst`, `test/qr.tst`, `test/run_tests.m`
- `tools/local-ci.sh`, `tools/check-tree.sh`, `tools/check-format.sh`
- `docs/pivoted-qr.md`, `docs/qr.md`, `docs/milestones/M19-pivoted-qr.md`, `docs/milestones/README.md`
- `README.md`, `NEWS.md`

## Commits

- `36cb203` — M19: add dense mp pivoted QR via MPLAPACK Rgeqp3

## Push

- Push: `git push -u origin topic/m19-pivoted-qr` succeeded.
- Remote tip: `bc0a3cbd72dfc8abb81370a805b3786cb0e1656f` before this report update
- Local tip: `36cb203d6acea6f151be2632374f878d284c06e4`
- GitHub CI: running on PR #20

## Known limitations

- qr(A,B) remains unsupported
- fixed-column JPVT public control unsupported
- qrupdate/insert/delete/shift unsupported
- public rank unsupported
- complex QR unsupported
- sparse QR unsupported
- Special-value pivot ordering is backend-defined; safety/immutability are required.

## Recommended next action

If M19 PASS:
Review and merge the M19 PR.

Define M20 independently. Do not automatically derive rank or condition
estimation from pivoted R merely because column-pivoted QR is available.

Otherwise:
State the exact blocker and stop.

## Milestone handoff

Branch: topic/m19-pivoted-qr
Starting commit: b5f7e9237925dbf0d8fe2ecaa6139c7c80c2f4fe
Final commit: 36cb203d6acea6f151be2632374f878d284c06e4
Files changed: M19 native bridge, public dispatch, tests, CI, and documentation listed above; five legacy report deletions remain pre-existing and unstaged.
Commands run: `tools/check-tree.sh`; `tools/check-format.sh`; `make -C src check-qr`; `make -C src check-pivoted-qr`; `make -C src`; direct Octave QR tests; `tools/local-ci.sh`; `git diff --check`.
Tests: M19 native ASan/UBSan tests, installed Rgeqp3/Rorgqr probe, public pivoted QR tests, installed package QA, and complete M00–M18 regression.
Gate: G19-UPSTREAM, G19-PERMUTATION, G19-PIVOT, G19-ECON, G19-PRECISION, G19-WORKSPACE, G19-PUBLIC, G19-M18-PARITY, G19-IMMUTABILITY, G19-INTEROP, G19-ROBUSTNESS — all PASS; M19 PASS.
Known limitations: no qr(A,B), fixed-column JPVT API, QR updates, public rank/condition APIs, complex or sparse QR; special-value pivot ordering remains backend-defined.
