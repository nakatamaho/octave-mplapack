# M00 — Bootstrap

# Goal

Establish the public repository and project contracts without implementing
numerical functionality.

# Scope

- GitHub repository and initial branch workflow
- Required repository tree and BSD-2-Clause license
- Octave package metadata
- Architecture and normative precision contracts
- Contributor and agent rules
- M00-M10 and P00-P06 milestone definitions
- Structural QA and lightweight baseline CI

# Non-goals

- Native MPFR storage or a working `mp` value
- Matrix arithmetic, GEMM, or GESV
- Debian packages or Launchpad publication

# Design constraints

MPLAPACK remains an installed dependency discovered through `pkg-config` and
must not be vendored or modified. The only planned backend through M10 is real
MPFR. Octave's system BLAS/LAPACK remain untouched, and every callable M00 stub
must fail explicitly.

# Implementation tasks

- Validate all mandatory environment prerequisites.
- Create the public repository, `main`, and `topic/m00-bootstrap` safely.
- Add all required package, source-placeholder, test-placeholder, documentation,
  QA, CI, and packaging-placeholder files.
- Commit and push the reviewed scaffold.

# Required tests

Run `tools/check-tree.sh`, `tools/check-format.sh`, `tools/local-ci.sh`, and
`git diff --check`. Inspect the complete diff, generated artifacts, repository
status, remote, and pushed branch.

# Gate

`G00` passes only when all mandatory prerequisites pass, the public repository
and correct remote exist, `topic/m00-bootstrap` exists, required files exist,
all M00 QA passes, no unexplained artifacts remain, a commit exists, and a
normal push succeeds. A mandatory dependency or command cannot be skipped.

Result: `G00 PASS`.

# Expected commit

`M00: bootstrap octave-mplapack repository`
