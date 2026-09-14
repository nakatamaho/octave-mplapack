# EXDOC01R1 RESULT

## Result

```text
DOCUMENTATION SCOPE PASS — EMPIRICAL QA DEFERRED
EXDOC01R1 full milestone: NOT COMPLETE
D04-READY: NOT CLAIMED
```

The mathematical-documentation scope is complete and its static gates pass.
The user explicitly deferred empirical QA for this continuation. Therefore no
unexecuted example, aggregator, verification job, focused regression, or
package lifecycle check is reported as PASS, and the full
`EXDOC01R1 PASS — TIERED NEIG/SVD DOCUMENTS MATHEMATICALLY COMPLETE` conclusion
is intentionally not claimed yet.

## Baseline

```text
EXDOC01 implementation baseline:
  implementation commit: f6188394095cc30394239a75c06ccf2fbeb14400
  prior report: exdoc01-report.md

DOC00:
  implementation freeze: 8f8bbdc0d75ccf4bc572ba843ad6b1ebf4ae0f75
  report: reports/DOC00-report.md
  status: DOC00 PASS — USER/DEVELOPER DOCUMENTATION CLOSED

Current documentation worktree base:
  b82112f46bf839565c91eb28a4b060ff7d0431bd

Working branch:
  topic/exdoc01r1-deep-math-docs

Development version:
  mplapack-interop 0.5.0-dev

Permanent documentation rule:
  AGENTS.md, "Documentation is part of Definition of Done"
```

The historical real checkpoint and the T00–T14/DOC00 numerical baselines are
unchanged. No dependency repository, dependency header, numerical backend,
installed `mp` method, or public numerical API was modified by this revision.

## Documents rewritten

| Family | Detailed case documents | Matching runnable entries | Family guide |
|---|---:|---:|---|
| NEIG Tier S | 12 | 12 | `docs/examples/tiered/neig-tier-s/README.md` |
| NEIG Tier A | 9 | 9 | `docs/examples/tiered/neig-tier-a/README.md` |
| SVD Tier S | 9 | 9 | `docs/examples/tiered/svd-tier-s/README.md` |
| SVD Tier A | 14 | 14 | `docs/examples/tiered/svd-tier-a/README.md` |
| **Total case documents** | **44** | **44** | `docs/examples/tiered/README.md` |

The one-case/one-`.m`/one-`.md` decomposition is preserved. The two missing
NRO scale documents were added as `nro_scale_up.md` and `nro_scale_down.md`.
The four historical numbered indexes and the counted family runners remain
the authoritative regression surfaces.

## Mathematical-definition audit

```text
Documents with rendered matrix/problem definition: 44/44
Documents missing definition: 0
Small fixed matrices shown explicitly: applicable cases reviewed; explicit
  block/matrix displays are used for low-dimensional fixtures
Structured families defined symbolically: 44/44
Parameters/dimensions defined: 44/44
Case IDs and matching runnable entries: 44/44
```

Each detail page now starts with the requested learning order:

```text
Quick idea
Mathematical problem
Why this problem is numerically difficult
What the Octave example computes
```

The pages then define construction/exactness, diagnostics, backward versus
forward error, precision roles, output interpretation, common mistakes,
scope, external references, and project provenance. The Markov/Perron pages
explicitly distinguish the teleportation target $r$ from the nonuniform
stationary vector $\pi$. The two-Jordan page explicitly uses the complement
$\mathrm{diag}(4,5,\ldots,n-1)$, matching the generator.

## Math rendering

```text
Display equations checked: 44/44
Unbalanced $$: 0
Raw \[...\] remnants: 0
Raw \(...\) remnants: 0
Equations improperly fenced: 0
Detail pages below the 1000-word depth floor: 0
```

`tools/check-tiered-math.sh` checks the required headings, rendered display
math, eigen/SVD equations, residual definitions, external references,
relative links, and placeholder content. All checks pass without running
Octave or numerical examples.

## Depth review

```text
Cases with full conditioning/sensitivity explanation: 44/44
Cases with backward-vs-forward discussion: 44/44
Cases with MP-specific analysis: 44/44
Cases with output-interpretation section: 44/44
Cases with common-mistakes section: 44/44
```

The documents keep input/source precision, operation/work precision, and
mathematical conditioning as separate concepts. They also retain the
one-operation/one-precision MPFR/MPC contract, operation-owned values, and
the rule that binary64 conversion is a declared presentation boundary only.

## NEIG pedagogy

```text
Eigenproblem equations: 21/21
Left/right explanation: 21/21
Nonnormality or sensitivity discussion: 21/21
Defectiveness where relevant: all applicable repeated/defective cases
Residual formula: 21/21
Ordering/matching warning: 21/21
Eigenvector ambiguity and scaling: 21/21
Conditioning: 21/21
```

The documents use the right relation $AV=VD$ and the left relation
$A^{\mathsf H}W=WD^{\mathsf H}$. Repeated and defective cases are described
as invariant-subspace or block problems; a true Jordan block is never called
diagonalizable, and a merged disk count is never used as an exact
multiplicity proof. The case-specific pages distinguish requested and
realized Ozaki–Ogita standard forms, analytic controls, and measured solver
outputs.

## SVD pedagogy

```text
SVD equation: 23/23
Reconstruction residual: 23/23
Orthogonality: 23/23
Tiny singular values: applicable cases covered
Rank/tolerance: applicable cases covered
Conditioning: 23/23
Full/economy dimensions where relevant: 23/23
```

The SVD pages use $A=U\Sigma V^{\mathsf H}$, distinguish reconstruction
from value-wise forward error, and explain why repeated singular values,
null spaces, and rectangular full/economy conventions require subspace-aware
comparisons rather than column-by-column claims.

## References

```text
Total external primary/authoritative reference entries: 92
DOI URL occurrences: 130
Unique DOI targets: 17
Direct publisher links outside DOI resolvers: 0
arXiv links: 0
Official LAPACK/Netlib links: 10
Official MPFR links: 26
Project-local cases without external provenance: 0
References incorrectly self-linked: 0
Result: PASS
```

The References sections contain literature, DOI, official Netlib/LAPACK, or
official MPFR sources with author/title/publication/year information where
applicable and a relevance note. Project examples, manifests, certificate
specifications, and runner paths are kept under `Project provenance` instead
of being presented as literature.

## Project navigation

```text
Project links separated from literature references: PASS
Migration map: docs/examples/tiered/MIGRATION.md
Tier family indexes: 4/4 present and linked
Master learning map: docs/examples/tiered/README.md
Glossary: docs/examples/tiered/GLOSSARY.md
```

The migration table maps every case to its layer, runnable entry, detailed
page, mathematical definition, external reference, and documentation depth.
The glossary defines the recurring eigensystem, SVD, precision, conditioning,
certificate, and matching terms used by the pages.

## Manual integration

```text
Worked examples section: PASS — @section Tiered worked examples
Representative equations: PASS — eigensystem and SVD relations/residuals
Links/paths: PASS — master map, family indexes, migration map, glossary
Generated Markdown manual: PASS — docs/mplapack-interop.md
```

`doc/mplapack-interop.texi` now explains the 21/23 NEIG/SVD split, the Tier S
and Tier A learning layers, right/left eigensystem equations, SVD
reconstruction diagnostics, and links to the detailed mathematical map. The
manual Markdown artifact was regenerated with
`tools/build-manual-markdown.sh`.

## CI

The following are deliberately separated into static/documentation checks
and empirical checks. The latter are deferred by the user's instruction for
this continuation.

```text
Standalone examples:
  NOT RUN for final validation; empirical QA deferred

tools/test-doc-examples.sh:
  INCOMPLETE / NOT ACCEPTED as evidence; a pre-deferral partial attempt was
  interrupted while entering examples/14_neig_tier_s.m, so no full-wall PASS
  is claimed

tools/check-docs.sh:
  PASS

tools/check-tiered-math.sh:
  PASS

tools/build-manual-markdown.sh:
  PASS

tools/build-docs.sh:
  PASS — generated user HTML, Info/plaintext, Markdown, and Doxygen HTML;
  no working TeX toolchain was available for a PDF

Focused eig/SVD regression:
  NOT RUN for final validation; empirical QA deferred

Package lifecycle:
  NOT RUN for final validation; empirical QA deferred

tools/check-tree.sh:
  PASS

git diff --check:
  PASS

Shell syntax checks:
  PASS — check-tiered-math.sh, check-docs.sh, build-manual-markdown.sh,
  build-docs.sh, and test-doc-examples.sh

tools/check-format.sh:
  NOT CLEAN because the pre-existing user-owned untracked
  test/octave-workspace contains trailing whitespace and carriage returns;
  this file was not edited or staged
```

No empirical result is inferred from the static checks. The partial attempt
is retained only as process context and is not a milestone gate result.

### All 26 verification-job statuses

The manifest contains the same 26 job IDs for the `smoke` and `demo`
profiles. Both profile columns are intentionally `NOT RUN`; no V-S/V-A
certificate is reclassified by this documentation revision.

| Job | Smoke | Demo |
|---|---|---|
| VS1-01 | NOT RUN | NOT RUN |
| VS1-02 | NOT RUN | NOT RUN |
| VS1-03 | NOT RUN | NOT RUN |
| VS1-04 | NOT RUN | NOT RUN |
| VS1-05 | NOT RUN | NOT RUN |
| VS1-06 | NOT RUN | NOT RUN |
| VS1-07 | NOT RUN | NOT RUN |
| VS1-08 | NOT RUN | NOT RUN |
| VS2-01 | NOT RUN | NOT RUN |
| VS2-02 | NOT RUN | NOT RUN |
| VS2-03 | NOT RUN | NOT RUN |
| VS2-04 | NOT RUN | NOT RUN |
| VS3-01 | NOT RUN | NOT RUN |
| VS3-02 | NOT RUN | NOT RUN |
| VS3-03 | NOT RUN | NOT RUN |
| VS3-04 | NOT RUN | NOT RUN |
| VA1-01 | NOT RUN | NOT RUN |
| VA1-02 | NOT RUN | NOT RUN |
| VA1-03 | NOT RUN | NOT RUN |
| VA2-01 | NOT RUN | NOT RUN |
| VA2-02 | NOT RUN | NOT RUN |
| VA2-03 | NOT RUN | NOT RUN |
| VA3-01 | NOT RUN | NOT RUN |
| VA3-02 | NOT RUN | NOT RUN |
| VA3-03 | NOT RUN | NOT RUN |
| VA3-04 | NOT RUN | NOT RUN |

No measured S/A/V rows were produced by this revision. Existing accepted
T00–T14/DOC00 evidence remains historical baseline evidence and was not
silently reused as fresh EXDOC01R1 empirical evidence.

## Numerical source changes

```text
None.
```

No production numerical source, dependency header, MPLAPACK source,
precision implementation, public API, or compiler behavior was changed.
The only corrections made after the static audit were documentation-model
clarifications: the Markov/Perron stationary-vector definitions and the
`SIM_TWO_JORDAN` complement index. They match the existing generators and do
not change them.

## Actual changed paths

The documentation worktree changes are limited to the following paths. The
three unrelated user-owned untracked files were preserved and are not part of
this list.

```text
exdoc01r1-report.md
doc/mplapack-interop.texi
docs/mplapack-interop.md
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
tools/check-docs.sh
tools/check-tiered-math.sh
```

The brace groups above are literal path lists, not new directory names.
Generated `docs/.build/` output and temporary worktree/build files are not
tracked.

## D04 handoff

```text
EXDOC01R1 PASS: NOT CLAIMED — empirical QA intentionally deferred
D04-READY: NOT CLAIMED / DEFERRED
```

The documentation is ready for the remaining empirical validation, but the
release-candidate handoff must not be represented as complete until the
standalone examples, aggregators, focused eig/SVD checks, and package
lifecycle have been run and recorded. No D04 operation was started.

## Next

Resume the empirical validation wall before claiming the full
`EXDOC01R1 PASS — TIERED NEIG/SVD DOCUMENTS MATHEMATICALLY COMPLETE` result or
`D04-READY`. Do not begin D04 automatically.
