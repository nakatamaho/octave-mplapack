# Nonsymmetric eigensystems — Tier S

Tier S is the study path for cases where a residual-only eigensystem check is not enough. The cases progress from a specified eigenvalue generator to exact similarities, representation-sensitive Toeplitz/Forsythe pairs, and a genuine Jordan limit. Each row below is one conceptual case, one runnable .m file, and one detailed mathematical page.

## What to know first

The public result is interpreted as a right relation

```math
A V = V D
```

and, when left vectors are requested, an adjoint relation

```math
A^{\mathsf H} W = W D^{\mathsf H}.
```

The basic residual is

```math
r_{\mathrm{eig}} =
\frac{\lVert A V - V D\rVert_F}
{\lVert A\rVert_F\lVert V\rVert_F}.
```

It is a backward-style equation diagnostic. Forward eigenvalue accuracy also depends on separation and left/right conditioning. For repeated or defective roots the target is a cluster or invariant subspace, not a list of canonical individual vectors.

The exact model, any once-rounded/generated input, the work precision, and the measured solver output are recorded separately. Raising the selected mpbits improves later arithmetic; it does not restore a bit removed by a fixed generator or make a Jordan block diagonalizable.

## Learning map

| Case | Mathematical object | Main question | Start here | Detailed page | External primary context |
|---|---|---|---|---|---|
| OO53_REAL | Fixed $g=53$ Ozaki–Ogita real triple product | requested versus realized roots | [oo53_real.m](../../../../examples/tiered/neig-tier-s/oo53_real.m) | [oo53_real.md](./oo53_real.md) | [Ozaki–Ogita (2022)](https://doi.org/10.1007/s11075-021-01186-7) |
| OO53_PAIR | Fixed $g=53$ paired 2-by-2 blocks | sign-copy and complex pairs | [oo53_pair.m](../../../../examples/tiered/neig-tier-s/oo53_pair.m) | [oo53_pair.md](./oo53_pair.md) | [Ozaki–Ogita (2022)](https://doi.org/10.1007/s11075-021-01186-7) |
| OO128_CLOSE | Fixed $g=128$ close standard form | lost $2^{-120}$ tail | [oo128_close.m](../../../../examples/tiered/neig-tier-s/oo128_close.m) | [oo128_close.md](./oo128_close.md) | [Ozaki–Ogita (2022)](https://doi.org/10.1007/s11075-021-01186-7) |
| SIM_SIMPLE | Dense similarity of a 2-by-2 near-Jordan model | simple but near-defective roots | [sim_simple.m](../../../../examples/tiered/neig-tier-s/sim_simple.m) | [sim_simple.md](./sim_simple.md) | [Rump (2022)](https://doi.org/10.1137/21M1451440) |
| SIM_REPEAT | Dense similarity of $I_2$ | semisimple repeated eigenspace | [sim_repeat.m](../../../../examples/tiered/neig-tier-s/sim_repeat.m) | [sim_repeat.md](./sim_repeat.md) | [Rump (2001)](https://doi.org/10.1016/S0024-3795(00)00279-2) |
| SIM_JORDAN | Dense similarity of $J_2(1)$ | defective block and no full basis | [sim_jordan.m](../../../../examples/tiered/neig-tier-s/sim_jordan.m) | [sim_jordan.md](./sim_jordan.md) | [Rump (2022)](https://doi.org/10.1137/21M1451440) |
| SIM_TWO_JORDAN | Two nearby J_2 blocks | separate versus merged clusters | [sim_two_jordan.m](../../../../examples/tiered/neig-tier-s/sim_two_jordan.m) | [sim_two_jordan.md](./sim_two_jordan.md) | [Rump (2001)](https://doi.org/10.1016/S0024-3795(00)00279-2) |
| TOEPLITZ | diagonally scaled tridiagonal Toeplitz | symmetric spectrum, nonsymmetric vectors | [toeplitz.m](../../../../examples/tiered/neig-tier-s/toeplitz.m) | [toeplitz.md](./toeplitz.md) | [Noschese–Pasquini–Reichel (2013)](https://doi.org/10.1002/nla.1811) |
| TOEPLITZ_SYM | explicit symmetric Toeplitz control | representation effect | [toeplitz_sym.m](../../../../examples/tiered/neig-tier-s/toeplitz_sym.m) | [toeplitz_sym.md](./toeplitz_sym.md) | [Noschese–Pasquini–Reichel (2013)](https://doi.org/10.1002/nla.1811) |
| FORSYTHE | Jordan block with $\varepsilon=r^n$ corner | tiny cyclic perturbation | [forsythe.m](../../../../examples/tiered/neig-tier-s/forsythe.m) | [forsythe.md](./forsythe.md) | [Higham (2002)](https://doi.org/10.1137/1.9780898718027) |
| FORSYTHE_SCALED | $I+rP$ normal control | scaled normal comparison | [forsythe_scaled.m](../../../../examples/tiered/neig-tier-s/forsythe_scaled.m) | [forsythe_scaled.md](./forsythe_scaled.md) | [Higham (2002)](https://doi.org/10.1137/1.9780898718027) |
| FORSYTHE_ZERO | $I+N$ genuine Jordan block | exact defective limit | [forsythe_zero.m](../../../../examples/tiered/neig-tier-s/forsythe_zero.m) | [forsythe_zero.md](./forsythe_zero.md) | [Rump (2022)](https://doi.org/10.1137/21M1451440) |

The primary papers motivate the phenomenon and terminology. The dimensions, dyadic parameters, acceptance gates, and runnable implementation are explicit suite choices.

## How to run

Run one case from the repository root:

~~~octave
pkg load mplapack-interop
run ("examples/tiered/neig-tier-s/oo128_close.m");
~~~

Run the complete counted family through the existing runner:

~~~octave
pkg load mplapack-interop
addpath (fullfile (pwd (), "examples", "neig_tiers"));
result = mp_neig_tiers ("smoke", struct ("tier", "S", "plot", false));
~~~

The smoke profile contains 12 Tier S cases and the demo profile uses the larger dimensions plus the demo-only complex Hadamard control in Tier A. The full runner, not a copied formula in this README, is the measurement authority.

## Suggested order

1. Start with OO53_REAL to learn the fixed generation precision and realized-spectrum record.
2. Read SIM_SIMPLE, then SIM_REPEAT and SIM_JORDAN, to separate simple, semisimple, and defective claims.
3. Compare TOEPLITZ with TOEPLITZ_SYM and FORSYTHE with FORSYTHE_SCALED.
4. Finish with SIM_TWO_JORDAN and FORSYTHE_ZERO, where cluster and block semantics matter most.

See the [master tiered map](../README.md), [NEIG manifest](../../../../docs/codex/neigt/cases.json), and [NEIG certificates](../../../../docs/codex/neigt/CERTIFICATES.md) for the boundary between ordinary measured rows and conservative verification claims.
