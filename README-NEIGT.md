# NEIGT: complete Codex Luna xhigh instruction bundle

Target: `nakatamaho/octave-mplapack`, Octave package `mplapack-interop`.
Prepared: 2026-09-10. This bundle supplies **implementation instructions**, exact
fixtures, proofs, acceptance criteria, source metadata, and preparation checks.
It is not a preimplemented or tested Octave package extension.

## Install the instruction files without overwriting prior work

Unpack this ZIP into a new directory outside the target checkout. Set the two
paths below to your actual directories. Python 3 is used only to install/validate
this instruction bundle; the resulting Octave examples must not depend on Python.

```bash
BUNDLE="$HOME/Downloads/mplapack-interop-neig-tiers-codex"
REPO="$HOME/src/octave-mplapack"
python3 "$BUNDLE/install-neigt.py" --repo "$REPO"
python3 "$BUNDLE/install-neigt.py" --repo "$REPO" --apply
```

The default command is a dry run. The second verifies SHA-256 hashes, checks all
destinations before copying, preserves identical installed instruction files and
refuses any differing existing file. It does not run git, change branches, modify
AGENTS.md, install a package, or start Codex. Symlink destinations/parents are
rejected. A conflict requires a deliberate manual resolution; no `--force` exists.
New files are atomically placed. On a copy failure, only files created by that
attempt are rolled back. Existing files are never deleted.

The installer copies the specification documents, manifests, preparation files,
this README, the installer itself and the checksum manifest to the corresponding
repository-relative paths. It does not create example implementation files or
replace earlier NEIG/SVT instructions. Run from a stable checkout without concurrent
writes to these destination paths.

## File layout

```text
README-NEIGT.md
install-neigt.py
SHA256SUMS-NEIGT
docs/codex/NEIGT-LUNA-XHIGH.md
docs/codex/NEIGT-GOAL.md
docs/codex/neigt/COVERAGE.md
docs/codex/neigt/GENERATOR-OO.md
docs/codex/neigt/CASES.md
docs/codex/neigt/NUMERICS.md
docs/codex/neigt/ARITHMETIC.md
docs/codex/neigt/CERTIFICATES.md
docs/codex/neigt/ACCEPTANCE.md
docs/codex/neigt/MILESTONES.md
docs/codex/neigt/SOURCES.md
docs/codex/neigt/PREPARATION.md
docs/codex/neigt/cases.json
docs/codex/neigt/verification-jobs.json
docs/codex/neigt/preparation/check_math.py
docs/codex/neigt/preparation/check-results.json
docs/codex/neigt/preparation/validate_bundle.py
docs/codex/neigt/preparation/bundle-validation.json
```

Open Codex in the target checkout, select Luna with xhigh reasoning, and paste
`docs/codex/NEIGT-GOAL.md`'s `/goal` block. NEIGT00--NEIGT25 are sequential gates,
not requests for another planning document. Preserve prior NEIG/SVD/SVT/NEIGV code
and reports, and never confuse earlier specs with implemented features.

## Scope in one table

| Layer | Required implementation |
|---|---|
| Tier S | Ozaki--Ogita exact generator; exact simple/repeated/Jordan similarities; Toeplitz; Forsythe |
| Tier A | Hadamard bidiagonal; Frank; Wilkinson; Grcar; MKS rank-one Toeplitz; stochastic/positive Perron |
| V-S | Counted eigenvalue inclusions; invariant clusters; pseudospectrum points/cells |
| V-A | Compatible eigen/Schur/block-Schur factors; finite generalized pencils; normalized Perron pairs |

The V methods are specified conservative rigorous baselines, not full algorithm
ports from the cited Rump/Miyajima/Frommer papers. They are mandatory. The finite
pencil path verifies reduction error and does not require public eig(A,B).
Defective matrices are tested by clusters/block Schur, not false diagonalization.
No backend, installed API, dependency header or global rounding setter is changed.

## Coverage

Smoke: 20 matrices, native+128+256 bits, both balance modes: 120 measured eig calls.
Demo: 21 matrices, native+128+256+512 bits, both modes: 168 measured eig calls.
Each also requires 26 separately counted verification jobs. Stress is optional
(8 matrices, 64 measured calls) and cannot substitute for mandatory coverage.
Reference/candidate/SVD/solve/proof work is counted separately from those calls.

## Preparation evidence and limits

The bundled standard-library Python script ran exact rational checks of generator
products, MKS determinant identities, Markov spectral/stationary identities,
small graph inequalities and individual outward arithmetic operations. Its
JSON output is marked PASS_PREPARATION_ONLY. It is not evidence of Octave or
MPLAPACK execution. Both were unavailable in the preparation runtime. The target
repository's current web fetch also failed, so actual APIs, source rounding
contracts and loaded module paths must be audited in NEIGT00/13.

To rerun preparation without overwriting its recorded result:

```bash
python3 docs/codex/neigt/preparation/check_math.py --output /tmp/neigt-check-new.json
```

See PREPARATION.md for precise counts and qualifications. Samples detect bugs;
the documented theorem hypotheses and audited arithmetic justify certificates.
