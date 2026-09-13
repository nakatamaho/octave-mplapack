# EXDOC01R2 RESULT

## Result

```text
DOCUMENTATION RENDERING PASS — EMPIRICAL QA DEFERRED
EXDOC01R2 full milestone: NOT COMPLETE
D04-READY: NOT CLAIMED
```

The GitHub-Markdown rendering scope is complete. The explicit user
instruction for this continuation was that measured/empirical QA is not
required, so no unexecuted numerical or package test is reported as PASS.
The final `EXDOC01R2 PASS — GITHUB MATH RENDERING CLOSED` and `D04-READY`
conclusions remain intentionally unclaimed until that deferred wall is run.

## Baseline

```text
EXDOC01R1:
  implementation commit: f6188394095cc30394239a75c06ccf2fbeb14400
  prior report: exdoc01r1-report.md

DOC00:
  implementation freeze: 8f8bbdc0d75ccf4bc572ba843ad6b1ebf4ae0f75
  report: reports/DOC00-report.md
  status: DOC00 PASS — USER/DEVELOPER DOCUMENTATION CLOSED

Working repository: octave-mplapack
Working branch: main
Starting commit: 04647345895cf7c260157ca49532dbf748febb35
Development version: mplapack-interop 0.5.0-dev
Permanent documentation rule: AGENTS.md, "Documentation is part of Definition of Done"

Numerical source changes: none
Dependency changes: none
Public API changes: none
Test matrices/tolerances/accepted semantics: unchanged
```

The 44 EXDOC01R1 detailed pages, four family indexes, master index, glossary,
and migration table remain intact. Only Markdown embedding syntax, the
related static checks, the permanent contributor rule, and this report were
changed. The unrelated user-owned untracked files
`docs/NEIG-LUNA-XHIGH.md`, `octave-workspace`, and `test/octave-workspace`
were preserved and were not staged.

## Official syntax and project policy

The official GitHub guidance was read before editing:

<https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/writing-mathematical-expressions>

The project policy now recorded in `AGENTS.md` is:

```text
inline expressions: GitHub-supported $...$ syntax
nontrivial displays: fenced math blocks
raw \[...\] and \(...\): forbidden as project-standard Markdown delimiters
display math in tables, HTML tables, blockquotes, and <details>: forbidden
custom preamble macros: forbidden
```

## GitHub source of truth

```text
Official GitHub math documentation:
  https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/writing-mathematical-expressions
GitHub MathJax support: YES — official GitHub Markdown math syntax
Live GitHub preview available: NO — this branch was not published for preview
Preview method: official syntax audit, source-level representative inspection,
  and tools/check-github-math.sh
```

GitHub's `math` fences are used as the default robust form for matrices,
multiline formulas, aligned expressions, complex displays, fractions, and
piecewise/condition expressions. Existing standalone `$$` blocks remain
accepted by the checker for compatibility, but all 128 in-scope displays are
now fenced `math` blocks.

## Conversion and audit totals

```text
Tiered Markdown files audited: 51
Detailed case pages: 44
Family/master/index/glossary/migration pages: 7
Fenced math blocks: 128 opening / 128 closing
Standalone $$ blocks remaining: 0
Raw \[...\] delimiters: 0
Raw \(...\) delimiters: 0
Custom project macros: 0
Obvious doubled LaTeX command backslashes: 0
Unclosed math blocks: 0
Math environments outside a display block: 0
Display blocks inside Markdown tables/HTML tables/blockquote/details: 0
```

The table audit explicitly covered:

```text
docs/examples/tiered/README.md
docs/examples/tiered/neig-tier-s/README.md
docs/examples/tiered/neig-tier-a/README.md
docs/examples/tiered/svd-tier-s/README.md
docs/examples/tiered/svd-tier-a/README.md
docs/examples/tiered/MIGRATION.md
```

The tables contain only links, short descriptions, and short inline
expressions where useful. No multiline or display math was put in a table
cell; matrix descriptions were shortened rather than embedding a matrix in a
cell. `GLOSSARY.md` was also audited and its equations are ordinary isolated
fenced blocks.

## Files audited

```text
Master index: docs/examples/tiered/README.md
Family READMEs: docs/examples/tiered/neig-tier-s/README.md,
  neig-tier-a/README.md, svd-tier-s/README.md, svd-tier-a/README.md
Detailed case docs: 44 pages under docs/examples/tiered/{neig-tier-*,svd-tier-*}
Glossary: docs/examples/tiered/GLOSSARY.md
Migration map: docs/examples/tiered/MIGRATION.md
```

## Syntax normalization

```text
Complex/multiline displays converted to fenced math: 128
Simple $$ displays retained: 0 in the current Tiered pages
Raw \[...\] removed: 0 remaining
Raw \(...\) removed: 0 remaining
Malformed delimiters fixed: 0 remaining
Custom macros removed/fixed: 0 remaining
Accidental doubled escaping fixed: 0 remaining
```

## Table/list fixes

```text
Tables with display math before: 0
Tables with display math after: 0
Fragile table inline math fixed: short expressions normalized in the six
  audited index/migration tables
List-nested displays fixed: no list-nested display blocks remain
HTML/blockquotes fixed: no display math occurred in those containers
```

## Matrix rendering

```text
Matrix-heavy docs checked:
  docs/examples/tiered/neig-tier-s/sim_jordan.md
  docs/examples/tiered/neig-tier-s/sim_two_jordan.md
  docs/examples/tiered/svd-tier-a/lauchli_tall.md
GitHub rendering result: PASS under the official fenced-math syntax policy
```

## NEIG formula rendering

```text
Eigenproblem: fenced AV=VD displays preserved across 21 NEIG pages
Left eigenproblem: fenced adjoint relation preserved where applicable
Residual: explicit r_eig displays preserved across 21 NEIG pages
Conditioning: prose and formulas distinguish forward/backward sensitivity
Nonnormality: relevant Tier S/A explanations retained
Result: PASS for static GitHub rendering
```

## SVD formula rendering

```text
SVD equation: fenced A=U Sigma V^H displays preserved across 23 SVD pages
Reconstruction residual: explicit r_svd displays preserved
Orthogonality: r_U/r_V displays preserved where applicable
Rank threshold where applicable: retained in the relevant case explanations
Result: PASS for static GitHub rendering
```

## Visual audit

Direct authenticated GitHub UI preview was unavailable for this unpushed
worktree. The official GitHub syntax, source-level visual inspection, and the
static checker were used as the near-live gate.

```text
matrix-heavy NEIG: docs/examples/tiered/neig-tier-s/sim_jordan.md — PASS
  bmatrix and diagonal-block display is isolated in a fenced math block

multiline/aligned NEIG: docs/examples/tiered/neig-tier-s/oo53_real.md — PASS
  multiline generator equations use separate isolated math fences

SVD reconstruction/orthogonality:
  docs/examples/tiered/svd-tier-a/hadamard_close.md — PASS
  reconstruction and factor equations are fenced and use explicit norms

precision/results/index audit:
  docs/examples/tiered/README.md and docs/examples/tiered/MIGRATION.md — PASS
  all table rows remain single-line Markdown with no display block

master tier index: docs/examples/tiered/README.md — PASS
glossary: docs/examples/tiered/GLOSSARY.md — PASS
```

Literal norm bars in the remaining displayed residuals were changed to
`\lVert`/`\rVert` (and scalar bars to `\lvert`/`\rvert`) where they were
being used as mathematical notation. No literal pipe was introduced into a
table-cell expression.

## Pedagogy preserved

```text
Mathematical definitions: 44/44
MP-specific explanations: 44/44
External literature links: retained on all 44 detailed pages
Project provenance separation: PASS
Numerical semantics and accepted case depth: preserved
```

The rendering conversion did not replace mathematical definitions with raw
code, remove conditioning explanations, or collapse source precision,
work/operation precision, and mathematical conditioning into one concept.
The external references and project-provenance links remain separate, and
the pages continue to distinguish measured solver output from independent
model facts.

## Static checker

`tools/check-github-math.sh` now checks, without attempting to parse TeX:

```text
raw delimiter policy
custom preamble macros
doubled command backslashes
balanced fenced math blocks and legacy $$ blocks
blank-line isolation
display math in table/HTML/blockquote/details contexts
matrix/multiline environments outside display blocks
inline dollar balance
```

`tools/check-tiered-math.sh` now accepts either legacy `$$` or fenced `math`
displays and no longer rejects the selected GitHub-safe form. Its display
equation test was also corrected to recognize either form. The new checker is
required and executed by `tools/check-docs.sh`.

```text
Violations remaining in scoped Tier Markdown: 0
```

## Documentation builds and gates

```text
tools/check-github-math.sh: PASS — 51 documents
tools/check-tiered-math.sh: PASS — 44 detailed pages
tools/check-docs.sh: PASS
tools/build-docs.sh: PASS — user HTML, Info/plaintext, Markdown, and Doxygen HTML
git diff --check: PASS
bash -n on changed shell checkers: PASS
```

`tools/build-docs.sh` generated under ignored `docs/.build/`; it did not
modify the tracked Texinfo or generated Markdown manual. No TeX PDF toolchain
was available, but the required Info/plaintext manual artifact, HTML manual,
generated Markdown comparison, and Doxygen HTML all built successfully.

## CI

Static documentation gates were run. The following measured/empirical checks
were deliberately not run in this continuation, per the explicit user
instruction that measured QA is unnecessary here. They are `NOT RUN`, not
PASS:

```text
Tier standalone examples: NOT RUN
tools/test-doc-examples.sh: NOT RUN
44 standalone Tier example scripts: NOT RUN
120 smoke eig rows: NOT RUN
168 demo eig rows: NOT RUN
NEIG/SVD V-S/V-A verification jobs: NOT RUN
focused eig/SVD regression: NOT RUN
Grcar regression: NOT RUN
package lifecycle smoke: NOT RUN
manual build: PASS — tools/build-docs.sh
package lifecycle: NOT RUN
sanitizer rerun: NOT REQUIRED for this docs-only change
```

No numerical result, prior QA result, or inherited C12/DOC00 result is
relabelled as fresh EXDOC01R2 empirical evidence.

## Actual changed paths

```text
AGENTS.md
tools/check-docs.sh
tools/check-tiered-math.sh
tools/check-github-math.sh
exdoc01r2-report.md
docs/examples/tiered/README.md
docs/examples/tiered/MIGRATION.md
docs/examples/tiered/GLOSSARY.md
docs/examples/tiered/neig-tier-s/README.md
docs/examples/tiered/neig-tier-s/{forsythe.md,forsythe_scaled.md,
  forsythe_zero.md,oo128_close.md,oo53_pair.md,oo53_real.md,
  sim_jordan.md,sim_repeat.md,sim_simple.md,sim_two_jordan.md,
  toeplitz.md,toeplitz_sym.md}
docs/examples/tiered/neig-tier-a/README.md
docs/examples/tiered/neig-tier-a/{frank0.md,frank1.md,grcar.md,had_bidiag.md,
  had_complex.md,markov.md,mks.md,perron_pos.md,wilkinson.md}
docs/examples/tiered/svd-tier-s/README.md
docs/examples/tiered/svd-tier-s/{dd_nonsym.md,dd_sym.md,jacobi_stirling.md,
  lah.md,nro_graded.md,nro_scale_down.md,nro_scale_up.md,nro_three.md,
  nro_two.md}
docs/examples/tiered/svd-tier-a/README.md
docs/examples/tiered/svd-tier-a/{bidiag_mixed.md,bidiag_raw.md,
  hadamard_close.md,hadamard_geometric.md,hadamard_rank4.md,
  hadamard_rank5.md,hadamard_repeat.md,lauchli_complex.md,lauchli_tall.md,
  lauchli_wide.md,nro_companion.md,pascal_lower.md,pascal_sym.md,
  vandermonde.md}
```

The brace groups are literal path lists, not new directory names. Generated
`docs/.build/` output is ignored and was not committed.

## D04 handoff

```text
EXDOC01R2 rendering scope: PASS
EXDOC01R2 PASS: NOT CLAIMED
EXDOC01R2 full milestone: NOT COMPLETE — empirical QA deferred
D04-READY: NOT CLAIMED
No D04 operation started.
```

When the deferred empirical wall is eventually run, it must use the existing
frozen D00/D04 dependency provenance. This rendering change does not alter
MPLAPACK, gmpfrxx_mkII, numerical source, package version, or accepted
precision semantics.

## Numerical source changes

```text
None.
```

No numerical algorithm, matrix definition, tolerance, precision contract,
dependency header, public API, or accepted numerical result was changed.

## Final milestone record

```text
Branch: main
Starting commit: 04647345895cf7c260157ca49532dbf748febb35
Final implementation commit: 2cbe35e69ca084085cf232d836cbcdac2015fdc8
  (this report is maintained in a separate status/report commit)
Files changed: listed in Actual changed paths above
Commands run: listed in Documentation builds and gates above
Tests: static documentation/build gates PASS; empirical QA NOT RUN by instruction
Gate: rendering scope PASS; full EXDOC01R2 gate deferred
Known limitations: no authenticated GitHub UI preview; no empirical numerical/package QA
```

## Next

The rendering scope is ready for the deferred empirical validation wall.
Resume `tools/test-doc-examples.sh`, the standalone Tier examples, focused
eig/SVD and Grcar checks, and package lifecycle QA before claiming the full
milestone or `D04-READY`. If the complete gate later passes, the next
milestone is D04; do not begin D04 automatically from this report.
