# NEIGT00 report

Task and milestone: NEIGT — Tier S/A nonsymmetric eigenproblems and Tier V-S/V-A verification; repository, source, and public-API audit.

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `760ec415a6f2b634f5cb80ee53758925cd32b83d`

Tested commit/state: the starting tree plus this report and the copied NEIGT
instruction bundle; no numerical implementation was changed in NEIGT00.

## Repository and dependency audit

- Repository: `/tmp/neigt-work2`, based on the existing `main` NEIG08 line.
- Worktree: dedicated clean worktree; the user's dirty
  `/home/docker/work/octave-mplapack` C12 checkout was not switched or modified.
- Octave: GNU Octave 11.1.0, `/usr/bin/octave`.
- MPLAPACK: `mplapack_mpfr` 3.0.1 through `pkg-config`.
- Dependency prefix: `/home/docker/opt/octave-mplapack-stack`.
- Backend: installed MPFR/MPC MPLAPACK interface; no dependency source or header
  was modified.
- Current implementation includes the existing public `@mp/eig.m` wrapper and
  native general/generalized eig support from NEIG08. No new NEIGT API was added.

The source checkout's `tools/dev-octave.sh` builds the native module against
`pkg-config`, and its compile path selected
`/home/docker/opt/octave-mplapack-stack/include/mplapack` and the corresponding
installed library directory. The generated native module was
`/tmp/neigt-work2/src/__mplapack_core__.oct` and the source-tree audit loaded
`/tmp/neigt-work2/inst/@mp/mp.m` plus the class method
`/tmp/neigt-work2/inst/@mp/eig.m`.

## Public API audit

The following existing interfaces are available and were exercised:

- `mp`, `mpbits`, real and complex arithmetic, `real`, `imag`, `conj`, `abs`,
  comparisons, `norm`, and matrix construction/indexing.
- `[V,D,W] = eig(A,"nobalance")` and `[V,D,W] = eig(A,"balance")` for real and
  complex MP matrices.
- `qr`, `mldivide`/linear solves, and one-/three-output SVD.
- Existing generalized eig and structured eig tests remain available; public
  generalized eig is treated as optional by NEIGT verification as required.

The left-vector convention was checked as:

```text
A*V = V*D
W'*A = D*W'
```

with complex conjugating transpose. The audit also confirmed that a public
`@mp/eig` method exists in this baseline, while ordinary builtin `eig` remains
the dispatch target for non-`mp` values. NEIGT will use only the class's public
MP operations and will keep native controls explicitly separate.

## Commands and results

```text
make -C src check-dependency
    PASS: mplapack_mpfr 3.0.1

make -C src -j$(nproc)
    PASS: __mplapack_core__.oct built

tools/dev-octave.sh --eval '<real/complex eig, balance, QR, solve audit>'
    PASS: NEIGT00 API AUDIT PASS

tools/dev-octave.sh --eval 'test("test/precision.tst",...);
  test("test/eig_general.tst",...);
  test("test/eig_structured.tst",...);
  test("test/eig_generalized.tst",...)'
    PASS: 12/12 precision tests
    PASS: 7/7 general eig tests
    PASS: 6/6 structured eig tests
    PASS: 5/5 generalized eig tests
```

The first hand-written audit invocation contained a command-line parenthesis
typo and was discarded; the corrected invocation passed. This was a harness
command issue, not a product result.

## NEIGT implementation plan fixed by this audit

- Preserve the existing NEIG examples, reports, public `@mp/eig` wrapper, and
  native backend unchanged.
- Add four new numbered example entry points and an example-local `neig_tiers`
  facade, using the two JSON manifests without lossy numeric parsing.
- Keep model construction, frozen solver input, raw eig output, candidate
  preparation, references, and certificates as distinct data and hashes.
- Implement the audited outward MP real-scalar/complex-rectangle layer inside
  the example tree only; no installed interval API or dependency change.
- Treat public generalized eig and Schur as optional candidate paths; implement
  mandatory finite-pencil and block-Schur verification through the specified
  solve/QR baselines.

## Gate

NEIGT00: **PASS** — required local tools, installed dependency, public MP
arithmetic/eig/QR/solve/SVD interfaces, and relevant existing eig regressions
are available. No unauthorized dependency/API change was made.

Known limitations: NEIGT S/A/V implementation and its proof arithmetic have not
started; no NEIGT coverage claim is made by this report.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `760ec415a6f2b634f5cb80ee53758925cd32b83d`
Final commit: pending NEIGT00 report commit
Files changed: `neigt00-report.md`
Commands run: dependency check, native module build, public API audit, and four focused existing eig/precision regressions listed above
Tests: all listed focused tests PASS
Gate: NEIGT00 PASS
Known limitations: NEIGT implementation not yet present
