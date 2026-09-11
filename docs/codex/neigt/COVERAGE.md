# Coverage map: no requested tier is optional

| Requested item | Implementation | Method/source relationship |
|---|---|---|
| S1 Ozaki--Ogita | OO53_REAL, OO53_PAIR, OO128_CLOSE | Theorem-1 triple product with fixed generation precision; paired-block adaptation; not just a generic similarity |
| S2 exact similarities | SIM_SIMPLE, SIM_REPEAT, SIM_JORDAN, SIM_TWO_JORDAN | Rump-style integer unit-triangular construction; deterministic suite parameters |
| S3 tridiagonal Toeplitz | TOEPLITZ, TOEPLITZ_SYM | Closed-form spectrum/left/right vectors; exact original and symmetric control |
| S4 Forsythe | FORSYTHE, FORSYTHE_SCALED, FORSYTHE_ZERO | Existing family extended; zero limit is not a diagonalization success test |
| A1 Hadamard bidiagonal | HAD_BIDIAG | Reuse exact existing definition and analytic conditioning |
| A2 Frank | FRANK0, FRANK1 | Opposite orientations of one family, not unrelated new spectra |
| A3 Wilkinson companion | WILKINSON | Exact coefficients plus rootwise polynomial coefficient backward error |
| A4 Grcar | GRCAR | Existing matrix plus verified pseudospectral probes |
| A5 Morimoto--Katori--Shirai | MKS | Model 1 only, exact zero multiplicity and reduced nonzero-root polynomial |
| A6 Perron/stochastic | MARKOV, PERRON_POS | Dyadic derived applications; known spectrum, nonuniform stationary vector |
| Demo complex control | HAD_COMPLEX | Quarter-turn unitary diagonal similarity; conjugation/coordinate checks |
| V-S1 all eigenvalues | VS1-01..08 | Verified similarity plus counted Gershgorin groups; conservative baseline, not Rump's full algorithm |
| V-S2 cluster/subspace | VS2-01..04 | Verified Riccati-graph contraction, including defective/semisimple/merged cases |
| V-S3 pseudospectrum | VS3-01..04 | Verified SVD and 1-Lipschitz cell classification; not Frommer's full algorithm |
| V-A1 eigen/Schur factors | VA1-01..03 | Compatible eigentriples, interval exact QR, block-Schur for defect |
| V-A2 generalized pencils | VA2-01..03 | Nonsingular-B verified solve reduction, all roots and selected subspace; no public generalized eig prerequisite |
| V-A3 Perron pair | VA3-01..04 | Collatz--Wielandt plus normalized positive eigenpair contraction; not Miyajima's full M-matrix algorithm |

## Explicit first-release limits

Finite dense point real/complex matrices; proof helpers also accept enclosing
rectangles for an exact but indirectly represented matrix. Mandatory pencils have
certifiably nonsingular B, hence finite eigenvalues. Singular-B/infinite-eigenvalue
pencils, arbitrary interval-pencil regularity, general nonlinear eigenproblems,
PDE discretization error, and an INTLAB clone are outside scope.

The factor verifier proves a genuine triangular Schur factorization for separated
simple cases. On the defective case it proves a unitary **block-upper-triangular**
factorization with the declared invariant block. It must not label a dense block
as triangular Schur form or claim a diagonalization exists.

Pseudospectrum means the closed, complex-perturbation, unstructured 2-norm
pseudospectrum. Real-only or Toeplitz-preserving pseudospectra are different sets.
Ordinary structured sensitivity diagnostics are labeled MEASURED, never used as
certified membership tests for these other sets.

The suite does not promise validation of every arbitrary input. It must validate
its specified positive tests, reject or remain inconclusive on adversarial tests,
and preserve every assumption in the proof witness. These are implementable
bounded baselines, not empty extension points for later work.
