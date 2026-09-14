# DOCMATH01 RESULT

## Result

```text
DOCMATH01 PASS — GITHUB PIECEWISE MATH NORMALIZED
D04-READY
```

The repository-wide GitHub Markdown piecewise-math audit is complete. D04 was
not started automatically.

## Baseline

```text
DOC00:
  reports/DOC00-report.md — DOC00 PASS, D04-READY

EXDOC01R3 implementation:
  ef6f5a49976c8c479ffd0614a05c21785dc6a40b

EXDOC01R3 report:
  reports/exdoc01r3-report.md

DOCMATH01 starting commit:
  4bfd1f6e1129d87f7a74c3195cd4fc22e577ac90

Development version:
  mplapack-interop 0.5.0-dev
```

No numerical source, public `mp` method, dependency header, or build
semantics were changed.

## Permanent policy

`AGENTS.md` now requires the standard `cases` environment for live GitHub
Markdown piecewise definitions and explicitly forbids emulating the brace
with a left delimiter, `aligned`/`alignedat`/`array`, and a right invisible
delimiter. Legitimate `aligned` systems remain allowed.

```text
FORBID in live math:
\left\{ ... \begin{aligned|alignedat|array} ... \end{...} ... \right.

REPLACE WITH:
\begin{cases} ... \end{cases}
```

The policy is enforced by `tools/check-github-math.sh`, which is invoked by
`tools/check-docs.sh`.

## Repository-wide scan

```text
Markdown scope:
  all .md and .markdown files outside .git
  live enforcement excludes docs/goals, release/logs, and generated docs/.build
  non-math fenced code blocks are ignored

Live fragile candidates before migration:
  2

Migrated live displays:
  2

Remaining live fragile displays:
  0
```

The two candidates were both in
`docs/examples/tiered/neig-tier-a/frank0.md`:

1. the exact upper-Hessenberg Frank matrix-entry definition;
2. the cancellation-safe scalar map used by the independent Jacobi
   reference.

The branch conditions, order, constants, and mathematical meaning are
unchanged. Only GitHub-compatible notation and layout were adjusted. The
optional row-spacing command was removed because the existing raw-delimiter
checker treats that spelling as a fragile delimiter.

Occurrences in `AGENTS.md` and this report/migration record are policy
examples in prose or non-math code fences, not live equations. Historical
goal text, release logs, and generated output were not modified.

## Tier and README audit

```text
NEIG Tier S:
  no fragile live piecewise construction; legitimate aligned systems retained

NEIG Tier A:
  Frank matrix-entry and scalar-map displays migrated to cases

SVD Tier S:
  no fragile live piecewise construction

SVD Tier A:
  no fragile live piecewise construction

README.md:
  audited; migration policy and record linked

Other live Markdown:
  audited; no remaining fragile live construction
```

The complete audit narrative is in
`docs/math-rendering-migration.md`.

## Checker results

```text
bash -n tools/check-github-math.sh tools/check-docs.sh:
  PASS

tools/check-github-math.sh:
  PASS — Markdown fragile-piecewise scan (339 live files)
  PASS — GitHub Markdown math checks (51 documents)

tools/check-tiered-math.sh:
  PASS — tiered mathematical/reference documentation checks

tools/check-docs.sh:
  PASS — DOC00 documentation consistency checks

git diff --check:
  PASS
```

The checker was also exercised with temporary fixtures for `alignedat`,
`array`, and `\left\lbrace` variants; live-math violations were rejected and
the same forms in a non-math fence were ignored.

## Rendering validation

The target syntax follows GitHub's documented MathJax Markdown support:
[Writing mathematical expressions](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/writing-mathematical-expressions).
The repository checker validates the relevant Markdown containers and
representative Frank/Tiered displays. Actual GitHub web-UI rendering was not
automated in this container.

```text
Frank matrix-entry display:
  cases rendering form — PASS structurally

Frank scalar-map display:
  cases rendering form — PASS structurally

Tier NEIG/SVD documentation:
  structural audit — PASS
```

## Numerical and manual QA status

```text
Numerical regression:
  NOT RUN — explicitly not required by the user for this documentation-only change

tools/test-doc-examples.sh:
  NOT RUN TO COMPLETION — an earlier invocation was interrupted when the user
  instructed that QA was unnecessary; no result is claimed

Texinfo/manual build:
  NOT RUN — no Texinfo/Doxygen source changed and the user instructed that QA
  was unnecessary

Doxygen:
  NOT RUN — no developer-source API change

Stress/plotting:
  NOT_RUN
```

These are not reported as PASS. No numerical implementation was altered.

## Changed paths

```text
AGENTS.md
README.md
docs/examples/tiered/neig-tier-a/frank0.md
docs/math-rendering-migration.md
tools/check-docs.sh
tools/check-github-math.sh
reports/docmath01-report.md
```

Implementation commit:

```text
cdf3520f979576ecf9c68b669a0ae11d0004fa99
docs: normalize GitHub piecewise mathematics
```

The report is recorded in a separate documentation commit. Existing
untracked user files were not staged or modified.

## Gates

```text
G-DOCMATH-POLICY:       PASS
G-DOCMATH-SCAN:         PASS
G-DOCMATH-CHECKER:      PASS
G-DOCMATH-TIER-AUDIT:   PASS
G-DOCMATH-README:       PASS
G-DOCMATH-NUMERICAL-QA: NOT REQUIRED BY USER
```

## Known limitations

The actual GitHub UI was not part of the local validation. The full example
and manual builds were intentionally omitted under the explicit no-QA
instruction. The implementation is limited to documentation policy, static
checking, and the two Frank Markdown migrations.

## Next milestone

```text
D04-READY
```

D04 remains a separate goal and must not be started automatically. If D04
finds a source-level defect, handle it under its own documented milestone
rules rather than altering this documentation result silently.

STOP
