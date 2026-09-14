# GitHub math-rendering migration

Status: DOCMATH01 migration record.

This document records the repository-wide audit for fragile piecewise
definitions in GitHub Markdown. The rendering target is GitHub's MathJax
Markdown support, documented at
https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/writing-mathematical-expressions.

## Permanent rule

In live Markdown mathematics, an ordinary piecewise definition uses the
standard cases environment. A piecewise brace must not be emulated with an
aligned or array environment between a left brace and a right invisible
delimiter.

The forbidden and replacement forms are shown below as non-math documentation
examples. They are intentionally not parsed as live equations by the checker.

```text
FORBID:
\left\{ ... \begin{aligned} ... \end{aligned} ... \right.

REPLACE WITH:
\begin{cases}
...
\end{cases}
```

The aligned environment remains valid for genuinely aligned systems of
equations. This migration does not impose a blanket ban on aligned.

## Scan

The audit command walks every .md and .markdown file outside .git. The live
enforcement scanner excludes docs/goals, release/logs, and generated
docs/.build so historical goal text, immutable release evidence, and generated
output are not rewritten or treated as current documentation. Non-math fenced
code blocks are ignored; fenced math blocks and standalone $$ displays are
checked.

At the pre-migration audit, the only live fragile piecewise candidates were
the two displays in docs/examples/tiered/neig-tier-a/frank0.md:

1. the Frank matrix-entry definition;
2. the cancellation-safe scalar map used for the independent Jacobi
   reference.

No live alignedat, array, leftlbrace, or other brace variant required
migration. Existing aligned systems that are not piecewise definitions remain
unchanged.

## Migration

Both Frank displays were rewritten to cases in the same fenced math blocks.
Branch order, branch conditions, numerical constants, and mathematical meaning
are unchanged. The scalar display uses dfrac for the visually larger
fractions, and the optional row-spacing command was removed because the
repository's raw-delimiter check treats that spelling as a fragile delimiter;
this affects layout only.

The Tiered NEIG and SVD pages were audited explicitly. No Tier S or Tier A SVD
page contained a live fragile piecewise construction. The top README,
documentation outside docs/examples/tiered, current reports, and the
user-facing Markdown inventory contain no live fragile construction after the
migration.

## Immutable and non-live occurrences

No docs/goals or release/logs file was modified. A policy example in AGENTS.md
and the examples in this document use inline code or a non-math text fence;
they describe the forbidden form and are not live mathematical displays.
Generated docs/.build output was not modified.

## Enforcement

tools/check-github-math.sh now performs a deterministic repository-wide
fragile-piecewise scan in addition to the existing Tiered Markdown structure
checks. It rejects left brace or leftlbrace followed by aligned, alignedat, or
array and a right invisible delimiter when that sequence occurs in live math.
It ignores non-math code fences and the historical/immutable paths above.
tools/check-docs.sh already invokes tools/check-github-math.sh, so future
documentation changes are covered by the normal consistency gate.

## Validation method

The nearest available rendering validation is the repository's GitHub-math
structural checker, together with the official GitHub MathJax Markdown syntax
for fenced math blocks. The actual GitHub web UI was not automated in this
container. Representative coverage includes the Frank matrix-entry case, the
Frank scalar mapping, and the Tiered NEIG/SVD documentation trees.
