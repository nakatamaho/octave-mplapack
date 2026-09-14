# EXDOC01R3 RESULT

## Result

PASS

EXDOC01R3 PASS — SMOKE MATRICES EXPLICITLY DOCUMENTED

D04-READY

This milestone stopped after the documentation gate. D04 was not started
automatically.

## Baseline

EXDOC01R2:

The audited main-tree baseline was 06517cdebfe7eb7637331bfd03ecc036e71a810e,
which is also the recorded origin/main tip before this milestone.

Development version:

mplapack-interop 0.5.0-dev

Implementation/final audited commit:

ef6f5a4 (full SHA recorded below after the implementation commit was created).

## Smoke cases audited

Documents containing Smoke:

47 Tiered Markdown pages contain smoke-related wording, including the detailed
pages, indexes, family guides, and migration guidance. There are 44 detailed
case pages in total.

n=8 cases:

33 complete 8-by-8 matrices are covered: 15 NEIG cases and 18 SVD cases.
Every selected n=8 square smoke fixture is printed in full.

Other small fixed/smoke matrices:

WILKINSON is printed as a complete 10-by-10 matrix. A4-LAU-TALL and
A4-LAU-WIDE are printed as complete 5-by-4 and 4-by-5 matrices. The small
fixed A4-LAU-COMPLEX demo control is printed as a complete 9-by-8 matrix.

Larger n=12, n=16, n=24, and scale-up/scale-down demonstrations retain their
general definitions and generator parameters without a full dense dump. They
are outside the comfortable small-matrix rule and were not silently changed.

## Explicit matrices added

NEIG Tier S:

OO53_REAL, OO53_PAIR, OO128_CLOSE, SIM_SIMPLE, SIM_REPEAT, SIM_JORDAN,
SIM_TWO_JORDAN, FORSYTHE, FORSYTHE_SCALED, FORSYTHE_ZERO.

NEIG Tier A:

HAD_BIDIAG, FRANK0, FRANK1, WILKINSON, MARKOV, PERRON_POS.

SVD Tier S:

S1-NRO-TWO, S1-NRO-THREE, S1-NRO-GRADED, S2-JS, S3-LAH, S4-DD-SYM,
S4-DD-NONSYM.

SVD Tier A:

A1-PASCAL-LOWER, A1-PASCAL-SYM, A2-VAND, A3-BDI-RAW, A3-BDI-MIXED,
A4-LAU-TALL, A4-LAU-WIDE, A4-LAU-COMPLEX, A5-GEO, A5-CLOSE, A5-REPEAT,
A5-RANK4, A5-RANK5, A6-NRO-COMPANION.

Total:

37 exact matrix blocks, with 37 corresponding generator records and 37
corresponding detailed-page markers.

## Frank n=8

Case document:

docs/examples/tiered/neig-tier-a/frank0.md

General definition present:

YES. The existing upper-Hessenberg Frank definition remains before the
concrete fixture.

Explicit 8x8 matrix present:

YES. The required orientation is shown with rows

8 7 6 5 4 3 2 1

7 7 6 5 4 3 2 1

0 6 6 5 4 3 2 1

0 0 5 5 4 3 2 1

0 0 0 4 4 3 2 1

0 0 0 0 3 3 2 1

0 0 0 0 0 2 2 1

0 0 0 0 0 0 1 1

Matrix verified against code:

YES. tools/check-smoke-matrices.sh regenerates FRANK0 with the current
net_frank_model constructor and compares every entry exactly. A focused check
also verifies (F_0)11=8, (F_0)18=1, (F_0)43=5, and (F_0)42=0.

GitHub render:

PASS. The matrix uses an isolated fenced math block and bmatrix. The complete
51-document GitHub math gate passed.

Smoke/demo distinction explained:

YES. The page identifies n=8 as the inspectable smoke case and n=24 as the
larger demo generated from the same family without dumping the 24-by-24 array.

## Source precision

Exact/integer cases:

All 37 displayed fixtures are represented as exact integers or dyadic
rationals. The dump uses the existing MP constructors at 256-bit work
precision for exact-model cases. Common powers of two are displayed outside a
matrix only as exact factors.

Double-origin cases:

None for the displayed source matrices. The documentation audit does not build
a matrix from a binary64 intermediate.

MP/text-origin cases:

The three Ozaki–Ogita fixtures retain their declared 53-bit or 128-bit fixed
generation result in A_model and are serialized as exact dyadics. The other
selected constructors are evaluated in the MP model at the declared work
precision. No long decimal text was used to define an explicit matrix.

## Documentation policy

AGENTS.md:

PASS. Added the permanent rule requiring full exact small smoke/fixed matrices,
generator mapping, separate source/solver precision, and deterministic
comparison.

Family README:

PASS. NEIG Tier S/A and SVD Tier S/A guides describe the explicit-matrix policy.

Master index:

PASS. docs/examples/tiered/README.md records the same policy and audit command.

Static checker:

PASS. Added tools/check-smoke-matrices.sh, tools/check-smoke-matrices.py,
tools/dump_smoke_matrices.m, and tools/format_smoke_matrices.py. The checker is
now part of tools/check-docs.sh and performs exact Fraction-based comparison,
not residual or binary64 comparison.

## Validation

check-docs:

PASS — tools/check-docs.sh

check-github-math:

PASS — tools/check-github-math.sh; 51 documents checked.

matrix/code comparison:

PASS — tools/check-smoke-matrices.sh; all 37 cases, all dimensions, and all
entries matched. The focused FRANK0 orientation checks also passed.

standalone examples:

NOT RUN. This milestone changed documentation and documentation QA only; the
existing standalone numerical example wall was not repeated.

focused eig/SVD:

NOT RUN as a numerical solver wall. The focused work here was exact source
fixture regeneration and comparison, so no solver result is claimed by this
milestone.

manual build:

NOT RUN. The Texinfo/manual sources were not changed; tools/check-docs.sh and
the GitHub/tiered documentation gates passed.

Additional checks:

PASS — bash -n tools/check-smoke-matrices.sh, Python syntax compilation,
and git diff --check. Octave emitted the pre-existing package warnings about
functions shadowing core functions; they did not affect the gate.

## Numerical source changes

None. No eig/SVD algorithm, matrix generator, precision policy, public API, or
dependency source was changed.

## D04 handoff

EXDOC01R3 PASS:

YES

D04-READY:

YES

## Milestone commit metadata

Branch:

main

Starting commit:

06517cdebfe7eb7637331bfd03ecc036e71a810e

Final audited implementation commit:

ef6f5a49976c8c479ffd0614a05c21785dc6a40b

The abbreviated implementation commit above is ef6f5a4; the full SHA should be
used for provenance.

Files changed:

- AGENTS.md
- tools/check-docs.sh
- tools/check-smoke-matrices.py
- tools/check-smoke-matrices.sh
- tools/dump_smoke_matrices.m
- tools/format_smoke_matrices.py
- docs/examples/tiered/README.md
- docs/examples/tiered/neig-tier-s/README.md
- docs/examples/tiered/neig-tier-a/README.md
- docs/examples/tiered/svd-tier-s/README.md
- docs/examples/tiered/svd-tier-a/README.md
- the 16 explicit NEIG pages under docs/examples/tiered/neig-tier-s and
  docs/examples/tiered/neig-tier-a
- the 21 explicit SVD pages under docs/examples/tiered/svd-tier-s and
  docs/examples/tiered/svd-tier-a

The exact page names are the case names listed in Explicit matrices added
above; no unrelated user files were staged.

Commands run:

- tools/check-smoke-matrices.sh
- tools/check-tiered-math.sh
- tools/check-github-math.sh
- tools/check-docs.sh
- bash -n tools/check-smoke-matrices.sh
- python3 syntax checks for the two Python helpers
- git diff --check

Tests:

The exact documentation fixture gate passed for 37 cases. Numerical eig/SVD
walls, standalone examples, manual rebuild, stress, and plotting were not run
under this documentation-only milestone.

Gate:

PASS

Known limitations:

The exact matrix audit covers all comfortably small selected smoke/fixed cases,
not the larger n=12/n=16/n=24 or scale-range demonstrations. The audit uses
the installed mplapack-interop package to load public MP functions while
calling the repository's existing private example constructors; it does not
claim a fresh solver QA result.

## Next

If PASS:

D04 — freeze the documented release candidate.

Do not begin D04 automatically.

STOP
