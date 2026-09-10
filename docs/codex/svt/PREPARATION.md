# Preparation evidence and limitations

Prepared on 2026-09-10. These are checks of mathematical definitions and bundle
consistency, not tests of an octave-mplapack implementation. No Octave executable
was available. Attempts to refresh the public target repository failed. The actual
local API, MPFR rounding-mode use, native module selection, implementation results,
and clean-package QA are deliberately left to the mandatory SVT milestones.

## Executed preparation command

From the bundle root, the preparation run was equivalent to:

```sh
python3 docs/codex/svt/preparation/check_math.py \
  --output docs/codex/svt/preparation/check-results.json
```

The checked-in output records that actual run. A rerun must not overwrite it.
Run without `--output` to print results, or choose a new output filename.
The script uses Python's standard library only and refuses to replace an existing
output file. It is not required at runtime by the eventual Octave suite.

## Exact checks that passed

The script checked the following with integers and fractions:

- Sylvester orthogonality at orders 1,2,4,8,16,32; the 32-by-32 NRO demo's explicit
  inverse identity and exact representability of every input entry in binary64.
- Jacobi--Stirling leading rows; Lah recurrence versus the integer closed form;
  Pascal's P=Q*Q' identity at orders 8,16,20,24,32.
- The published NRO equation-(82) matrix/inverse identity in both product orders;
  the deterministic companion-like generator's entry bound, Horner invariant,
  and exact determinant at orders 2,3,8,16,32 with the tested integer parameters.
- Symmetric and biased DD tau=0 matrices: all row sums zero, every proper leading
  principal determinant equal to one, full determinant zero. Adding 2^-160 to
  their diagonals is lost in binary64 and in toy 128-bit RN, but retained at 256.
- The Hadamard-mixed geometric demo's exact dyadic entries need at most 121
  significant binary digits; the specification's conservative guard is 126.
- Every manifest bit guard and row count, including explicit below-guard DD rows.

Selected largest integer-entry bit lengths:

| Order | Jacobi--Stirling | Lah | Symmetric Pascal |
|---:|---:|---:|---:|
| 8 | 16 | 18 | 12 |
| 16 | 52 | 49 | 28 |
| 20 | 74 | 67 | 36 |
| 24 | 98 | 86 | 43 |
| 32 | 150 | 126 | 59 |

These are maximum entry bit lengths, not condition numbers, required solve
precisions, or sufficient proofs for every intermediate. The specification uses
separate conservative intermediate bounds.

Profile consistency checks:

| Profile | Cases | Work bits | Measured SVD calls including native |
|---|---:|---|---:|
| smoke | 20 | 128,256 | 120 |
| demo | 23 | 128,256,512 | 184 |
| stress, opt-in | 7 | 256,512,1024 | 56 |

Reference solves, shape tests, inverse solves, and V jobs are excluded from these
counts. Only the two DD demo cases at 128 bits and the DD stress case at 256/512
bits are intentionally below their exact-model construction guard.

## Rounding-algebra checks

A small exact Fraction implementation of normalized binary RN (unbounded exponent,
ties to even) corroborated the primitive outward enclosure at 5,184 signed-rational
and square-root test points, including deliberately small toy precisions. For
square roots, comparison was performed by squaring rational endpoints exactly.

This sampling is not a proof of a universal rounding theorem and does not audit
the target library. The proof is explicitly given in VERIFICATION.md and the
executor must separately establish that the real scalar binding satisfies its
hypotheses. Toy q=8/16 tests intentionally go below the verifier's supported q>=64;
they are extra algebra checks, not expanded production scope.

## Unexecuted and unclaimed

No actual Octave/MPLAPACK SVD, matrix solve, scalar-binding audit, interval checker,
certificate replay, numerical acceptance target, plotting backend, or isolated
package test was executed here. The Tier V algorithms specified in this bundle
have proofs and implementation requirements, but are not an already-built library.
The preparation data must never be copied into an implementation report as evidence
that SVT00--SVT19 passed.

Publisher/author-institution records establish the cited bibliographic metadata
and claim limits. The bundle does not claim to port the complete Rump--Lange,
Rump--Ogita, or Rump algorithms. See SOURCES.md for exact DOI matches and access
scope, and VERIFICATION.md for the actual narrower certificate methods.
