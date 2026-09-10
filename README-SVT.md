# Tier S/A/V SVD example specification bundle

Target: `nakatamaho/octave-mplapack`, GNU Octave package `mplapack-interop`.
Executor: the user's selected Luna model with xhigh reasoning in Codex.

## Placement

Place `docs/codex/SVT-LUNA-XHIGH.md`, `docs/codex/SVT-GOAL.md`, and the complete
`docs/codex/svt/` directory at the repository-relative paths shown here. Inspect
existing paths before copying. These are additive SVT paths, not replacements for
NEIG or the earlier SVD specification/implementation. Never overwrite a same-name
file with unreviewed local changes. README-SVT.md and SHA256SUMS-SVT may be kept at
the repository root as bundle metadata.

```text
README-SVT.md
SHA256SUMS-SVT
docs/codex/SVT-LUNA-XHIGH.md
docs/codex/SVT-GOAL.md
docs/codex/svt/CASES.md
docs/codex/svt/VERIFICATION.md
docs/codex/svt/MILESTONES.md
docs/codex/svt/SOURCES.md
docs/codex/svt/cases.json
docs/codex/svt/PREPARATION.md
docs/codex/svt/preparation/check_math.py
docs/codex/svt/preparation/check-results.json
```

Read the main specification, then use the prompt in `docs/codex/SVT-GOAL.md`.
The complete implementation contract is split into small, cross-referenced files
rather than requiring the executor to reconstruct previous conversations.

## Scope

All selected S/A families are specified. B/C families and a full implementation of
all algorithms in the Rump papers are not requested. Tier V nevertheless requires
real finite-arithmetic certificates: the bundle supplies explicit conservative
proofs and an example-local arithmetic layer, with no backend/public-API expansion.
There are 20 sequential milestones, SVT00--SVT19. Smoke has 120 measured SVD calls;
demo has 184; references, shape tests, inverse solves, and V jobs are separately
counted. The stress manifest is opt-in.

## Preparation versus execution

This bundle contains specifications and a standard-library Python mathematical
check, not an Octave implementation. The Python results are not performance data
or proof that the Octave API/gates work. The preparation environment has no Octave,
and refreshing the GitHub checkout failed. Local API/rounding audits, actual
numerical measurements, and clean-package tests are mandatory executor milestones.
See `docs/codex/svt/PREPARATION.md` for the exact preparation scope.

## Integrity

From an extracted bundle root, `sha256sum -c SHA256SUMS-SVT` checks the recorded
files on systems providing sha256sum. Do not treat these hashes as a signature,
a numerical certificate, or permission to overwrite repository files.
