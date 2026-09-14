# Nonsymmetric eigensystems — Tier A

Tier A is the broad advanced-example path. These cases retain exact integer/dyadic models while introducing eigenvalue conditioning, companion-polynomial diagnostics, pseudospectrum probes, stochastic/Perron structure, and a complex phase control. Each row is one conceptual case with one runnable entry point and one detailed mathematical explanation.

The detailed pages print every small smoke or fixed control in full with exact
integer or dyadic entries. The source matrix is not solver output, and source
precision remains separate from measured eigensystem precision.

## Common diagnostic language

For right eigenvectors V and left eigenvectors W:

```math
A V = V D,\qquad
A^{\mathsf H}W=WD^{\mathsf H},\qquad
r_{\mathrm{eig}} =
\frac{\lVert AV-VD\rVert_F}
{\lVert A\rVert_F\lVert V\rVert_F}.
```

A forward comparison uses an independent exact, analytic, or high-precision reference appropriate to the case. A polynomial coefficient backward error, a pseudospectral shifted singular value, a Perron contraction, and an eig residual are different claims. The tables and detail pages name which one is being measured.

## Learning map

| Case | Mathematical object | Main question | Start here | Detailed page | External primary context |
|---|---|---|---|---|---|
| HAD_BIDIAG | Hadamard similarity of upper bidiagonal T | separated roots, sensitive vectors | [had_bidiag.m](../../../../examples/tiered/neig-tier-a/had_bidiag.m) | [had_bidiag.md](./had_bidiag.md) | [Rump (2022)](https://doi.org/10.1137/21M1451440) |
| FRANK0 | explicit integer Frank orientation | small positive reciprocal roots | [frank0.m](../../../../examples/tiered/neig-tier-a/frank0.m) | [frank0.md](./frank0.md) | [Higham (2002)](https://doi.org/10.1137/1.9780898718027) |
| FRANK1 | $RF_0^{\mathsf T}R$ orientation | orientation and left/right exchange | [frank1.m](../../../../examples/tiered/neig-tier-a/frank1.m) | [frank1.md](./frank1.md) | [Higham (2002)](https://doi.org/10.1137/1.9780898718027) |
| WILKINSON | integer-root Frobenius companion | matrix versus polynomial backward error | [wilkinson.m](../../../../examples/tiered/neig-tier-a/wilkinson.m) | [wilkinson.md](./wilkinson.md) | [Aurentz et al. (2018)](https://doi.org/10.1137/17M1152802) |
| GRCAR | exact $0/\pm1$ Grcar band | nonnormal pseudospectrum | [grcar.m](../../../../examples/tiered/neig-tier-a/grcar.m) | [grcar.md](./grcar.md) | [Rump (2006)](https://doi.org/10.1016/j.laa.2005.06.009) |
| MKS | $N^m+\delta\mathbf{1}\mathbf{1}^{\mathsf T}$ | defective zero part and small q | [mks.m](../../../../examples/tiered/neig-tier-a/mks.m) | [mks.md](./mks.md) | [Morimoto–Katori–Shirai (2025)](https://doi.org/10.1142/S2661335225500133) |
| MARKOV | irreducible dyadic row-stochastic P | nonuniform left stationary vector | [markov.m](../../../../examples/tiered/neig-tier-a/markov.m) | [markov.md](./markov.md) | [Miyajima (2021)](https://doi.org/10.13001/ela.2021.5181) |
| PERRON_POS | positive diagonal similarity of P | positive root and both vectors | [perron_pos.m](../../../../examples/tiered/neig-tier-a/perron_pos.m) | [perron_pos.md](./perron_pos.md) | [Miyajima (2021)](https://doi.org/10.13001/ela.2021.5181) |
| HAD_COMPLEX | quarter-turn unitary phase | complex left-vector convention | [had_complex.m](../../../../examples/tiered/neig-tier-a/had_complex.m) | [had_complex.md](./had_complex.md) | [Rump (2022)](https://doi.org/10.1137/21M1451440) |

The cited works are mathematical context, not claims that the package implements their complete algorithms. Fixed parameters and acceptance thresholds are suite-specific.

## How to run

~~~octave
pkg load mplapack-interop
run ("examples/tiered/neig-tier-a/grcar.m");
~~~

For counted coverage:

~~~octave
pkg load mplapack-interop
addpath (fullfile (pwd (), "examples", "neig_tiers"));
result = mp_neig_tiers ("demo", struct ("tier", "A", "plot", false));
~~~

The smoke profile includes the eight Tier A cases; the demo adds HAD_COMPLEX. Use the V-S/V-A entry points for verified targets and read their certificate status independently from ordinary eig residuals.

## Suggested order

Start with HAD_BIDIAG, compare FRANK0/FRANK1, then read WILKINSON and GRCAR for backward-error and pseudospectral meaning. Finish with MKS, MARKOV, and PERRON_POS, where algebraic multiplicity, the left stationary vector, and positive-pair verification matter. HAD_COMPLEX is the final API/conjugation control.

See the [master map](../README.md), [NEIG cases](../../../../docs/codex/neigt/cases.json), and [NEIG sources](../../../../docs/codex/neigt/SOURCES.md).
