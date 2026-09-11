# Preparation evidence, not implementation acceptance

Prepared 2026-09-10. No Octave or MPLAPACK execution was performed in this runtime;
`command -v octave` found no executable. The numerical acceptance gates are
predeclared targets to be executed by Codex in the user's checkout. A supplied
instruction bundle is not proof of an implemented verifier.

## Exact rational checks actually executed

`preparation/check_math.py` uses only Python's standard library, principally
`fractions.Fraction` and integer arithmetic. It implements a rational binary RN
model (ties to even) rather than assuming host floats are exact.

| Check | Executed result |
|---|---|
| Ozaki--Ogita models | 6 fixtures: n=8/16, real53/pair53/close128; both products have zero rational rounding error |
| Requested versus realized | Changes present in all 6; close128 retains exactly 2^-80 and removes the 2^-120 increment |
| MKS characteristic formula | 168 exact determinant evaluations across n=3..9 and allowed m at four exact trial points |
| Stochastic constructions | n=8, epsilon=2^-24 and n=16, epsilon=2^-80; exact positivity, row sums, nontrivial stationary equations and characteristic identities |
| Outward primitives | 11,460 rational comparisons at q=64/128/256, including tiny values, four arithmetic operations and square roots |
| Graph/inverse identities | A small nonzero-quadratic Riccati example, exact similarity and finite-pencil identities |

The JSON result is `preparation/check-results.json`, with status
`PASS_PREPARATION_ONLY`, `octave_executed=false`, `mplapack_executed=false`.
The rational matrix hashes in that preparation file identify its own textual
rational convention; they are not the production certificate binary hashes.

The separate `preparation/validate_bundle.py` checks the two manifests, unique
case/job IDs, 120/168/64 measured counts, 26 jobs per mandatory profile and 26
milestone headings; compiles bundled Python without creating cache files; checks
Markdown fence balance; verifies exact square-freeness of the MKS reduced
polynomials at (n,m)=(6,3),(12,3),(32,3),(64,5); and tests the installer in owned
temporary Git-like directories. Its installer tests cover dry-run, initial copy,
identical rerun, a conflicting file with all-file preflight, and symlink-parent
rejection. `bundle-validation.json` records those preparation results.

These checks are bug detectors, not exhaustive proofs of a completed implementation.
In particular they do not audit a local mp binding's rounding, execute real MPFR
calls through Octave, run eig/Schur/QR there, or prove a numerical result from a
future implementation. The mathematical proofs and their locally enforced
hypotheses in ARITHMETIC.md/CERTIFICATES.md are separate obligations.

## Reproduce checks without replacing existing evidence

From the repository root after installing the instructions:

```bash
python3 docs/codex/neigt/preparation/check_math.py --output /tmp/neigt-math-new.json
python3 docs/codex/neigt/preparation/validate_bundle.py --bundle . --output /tmp/neigt-bundle-new.json
```

Use fresh output filenames. The bundle validator validates only paths in the
bundle manifest; it does not certify unrelated repository contents or execute
Octave. Its temporary install test reads the checksum manifest, so checksum
verification must still be valid after copying the instructions. If any bundled
specification is edited later, the original checksum mismatch is expected and
must not be disguised as an unchanged bundle.

## Source-access qualifications

Publisher/author full HTML was available for Ozaki--Ogita and the MKS preprint;
publisher metadata and abstracts were used for the other listed identifiers as
stated in SOURCES.md. The Rump2022 author PDF was parsed as text; web screenshot
attempts failed, so no claims depend on visually reading its tables or figures.
Current public GitHub repository fetches also failed in this preparation turn.
Prior uploaded NEIG and SVT specifications were read for compatibility, but do
not establish the executor's current code, API, package version or implemented
verification primitives. NEIGT00/13 must establish those facts locally.

No paper PDFs, licensed third-party source, font files, or compiled binaries are
included. The ZIP contains instruction/source files and exact-arithmetic
preparation evidence only.
