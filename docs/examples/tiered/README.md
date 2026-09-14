# Tiered nonsymmetric eigensystem and SVD examples

This is the complete learning map for the decomposed difficult-matrix examples. There are 44 standard cases: 21 nonsymmetric-eigensystem cases and 23 SVD cases, split into Tier S (deep stress/semantic cases) and Tier A (broad advanced controls). Every row has exactly one conceptual case, one runnable .m entry point, and one matching detailed .md explanation. The historical numbered scripts remain indexes and counted regression surfaces.

## Start with the mathematical contract

For nonsymmetric eigensystems, the right and left equations are

```math
A V=V D,\qquad A^{\mathsf H}W=WD^{\mathsf H}.
```

For SVD,

```math
A=U\Sigma V^{\mathsf H}.
```

The residuals are backward-style equation diagnostics. Forward error additionally depends on conditioning, scale, gaps, multiplicity, and the exact model that was stored. Repeated or defective eigenspaces and repeated or null singular groups must be compared as subspaces. A high-precision reference is not silently inserted into measured output.

The examples use only the public arbitrary-precision interfaces. Input/source precision, operation/work precision, and mathematical conditioning are separate fields. A displayed conversion to binary64 is a presentation boundary, never an unreported numerical fallback.

## Family guides

| Family | Cases | Purpose | Guide |
|---|---:|---|---|
| NEIG Tier S | 12 | fixed generator, near/repeated/defective roots, Toeplitz and Forsythe representations | [neig-tier-s/README.md](neig-tier-s/README.md) |
| NEIG Tier A | 9 | Hadamard, Frank, companion, Grcar, MKS, Markov/Perron, complex control | [neig-tier-a/README.md](neig-tier-a/README.md) |
| SVD Tier S | 9 | NRO, combinatorial growth, exponent range, diagonally dominant paths | [svd-tier-s/README.md](svd-tier-s/README.md) |
| SVD Tier A | 14 | Pascal, Vandermonde, bidiagonal, Läuchli, known groups/rank, companion-like controls | [svd-tier-a/README.md](svd-tier-a/README.md) |

## Complete learning map

The External reference column is a primary or authoritative external source for the mathematical phenomenon. The selected dimensions and thresholds are project fixtures; the detailed page records the attribution boundary.

| ID | Family | Mathematical definition / phenomenon | Main measured question | Runnable example | Detailed explanation | External reference |
|---|---|---|---|---|---|---|
| OO53_REAL | NEIG-S1 | fixed $g=53$ Ozaki–Ogita real triple product | requested versus realized spectrum | [oo53_real.m](../../../examples/tiered/neig-tier-s/oo53_real.m) | [oo53_real.md](neig-tier-s/oo53_real.md) | [Ozaki–Ogita 2022](https://doi.org/10.1007/s11075-021-01186-7) |
| OO53_PAIR | NEIG-S1 | paired real 2-by-2 standard blocks | sign-copy and conjugate pairs | [oo53_pair.m](../../../examples/tiered/neig-tier-s/oo53_pair.m) | [oo53_pair.md](neig-tier-s/oo53_pair.md) | [Ozaki–Ogita 2022](https://doi.org/10.1007/s11075-021-01186-7) |
| OO128_CLOSE | NEIG-S1 | fixed $g=128$ close standard form | deliberate $2^{-120}$ realization loss | [oo128_close.m](../../../examples/tiered/neig-tier-s/oo128_close.m) | [oo128_close.md](neig-tier-s/oo128_close.md) | [Ozaki–Ogita 2022](https://doi.org/10.1007/s11075-021-01186-7) |
| SIM_SIMPLE | NEIG-S2 | dense similarity of a 2-by-2 near-Jordan model | simple near-defective roots | [sim_simple.m](../../../examples/tiered/neig-tier-s/sim_simple.m) | [sim_simple.md](neig-tier-s/sim_simple.md) | [Rump 2022](https://doi.org/10.1137/21M1451440) |
| SIM_REPEAT | NEIG-S2 | dense similarity of $I_2$ | semisimple repeated eigenspace | [sim_repeat.m](../../../examples/tiered/neig-tier-s/sim_repeat.m) | [sim_repeat.md](neig-tier-s/sim_repeat.md) | [Rump 2001](https://doi.org/10.1016/S0024-3795(00)00279-2) |
| SIM_JORDAN | NEIG-S2 | dense similarity of $J_2(1)$ | genuine defect and block relation | [sim_jordan.m](../../../examples/tiered/neig-tier-s/sim_jordan.m) | [sim_jordan.md](neig-tier-s/sim_jordan.md) | [Rump 2022](https://doi.org/10.1137/21M1451440) |
| SIM_TWO_JORDAN | NEIG-S2 | two nearby defective blocks | separated versus merged clusters | [sim_two_jordan.m](../../../examples/tiered/neig-tier-s/sim_two_jordan.m) | [sim_two_jordan.md](neig-tier-s/sim_two_jordan.md) | [Rump 2001](https://doi.org/10.1016/S0024-3795(00)00279-2) |
| TOEPLITZ | NEIG-S3 | diagonal scaling of tridiagonal Toeplitz | spectrum versus vector conditioning | [toeplitz.m](../../../examples/tiered/neig-tier-s/toeplitz.m) | [toeplitz.md](neig-tier-s/toeplitz.md) | [Noschese et al. 2013](https://doi.org/10.1002/nla.1811) |
| TOEPLITZ_SYM | NEIG-S3 | explicit symmetric Toeplitz control | representation sensitivity | [toeplitz_sym.m](../../../examples/tiered/neig-tier-s/toeplitz_sym.m) | [toeplitz_sym.md](neig-tier-s/toeplitz_sym.md) | [Noschese et al. 2013](https://doi.org/10.1002/nla.1811) |
| FORSYTHE | NEIG-S4 | $I+N$ plus $\varepsilon$ corner | tiny cyclic perturbation | [forsythe.m](../../../examples/tiered/neig-tier-s/forsythe.m) | [forsythe.md](neig-tier-s/forsythe.md) | [Higham 2002](https://doi.org/10.1137/1.9780898718027) |
| FORSYTHE_SCALED | NEIG-S4 | $I+rP$ normal control | scaled versus original coordinates | [forsythe_scaled.m](../../../examples/tiered/neig-tier-s/forsythe_scaled.m) | [forsythe_scaled.md](neig-tier-s/forsythe_scaled.md) | [Higham 2002](https://doi.org/10.1137/1.9780898718027) |
| FORSYTHE_ZERO | NEIG-S4 | $I+N$, true Jordan limit | no full eigenbasis claim | [forsythe_zero.m](../../../examples/tiered/neig-tier-s/forsythe_zero.m) | [forsythe_zero.md](neig-tier-s/forsythe_zero.md) | [Rump 2022](https://doi.org/10.1137/21M1451440) |
| HAD_BIDIAG | NEIG-A1 | Hadamard similarity of upper bidiagonal T | separated roots, sensitive vectors | [had_bidiag.m](../../../examples/tiered/neig-tier-a/had_bidiag.m) | [had_bidiag.md](neig-tier-a/had_bidiag.md) | [Rump 2022](https://doi.org/10.1137/21M1451440) |
| FRANK0 | NEIG-A2 | explicit integer Frank orientation | small reciprocal roots | [frank0.m](../../../examples/tiered/neig-tier-a/frank0.m) | [frank0.md](neig-tier-a/frank0.md) | [Higham 2002](https://doi.org/10.1137/1.9780898718027) |
| FRANK1 | NEIG-A2 | $RF_0^{\mathsf T}R$ reflected orientation | left/right transformation | [frank1.m](../../../examples/tiered/neig-tier-a/frank1.m) | [frank1.md](neig-tier-a/frank1.md) | [Higham 2002](https://doi.org/10.1137/1.9780898718027) |
| WILKINSON | NEIG-A3 | integer-root Frobenius companion | polynomial versus matrix backward error | [wilkinson.m](../../../examples/tiered/neig-tier-a/wilkinson.m) | [wilkinson.md](neig-tier-a/wilkinson.md) | [Aurentz et al. 2018](https://doi.org/10.1137/17M1152802) |
| GRCAR | NEIG-A4 | exact $0/\pm1$ Grcar band | nonnormal pseudospectrum | [grcar.m](../../../examples/tiered/neig-tier-a/grcar.m) | [grcar.md](neig-tier-a/grcar.md) | [Rump 2006](https://doi.org/10.1016/j.laa.2005.06.009) |
| MKS | NEIG-A5 | $N^m+\delta\mathbf{1}\mathbf{1}^{\mathsf T}$ | defective zero and reduced q | [mks.m](../../../examples/tiered/neig-tier-a/mks.m) | [mks.md](neig-tier-a/mks.md) | [Morimoto et al. 2025](https://doi.org/10.1142/S2661335225500133) |
| MARKOV | NEIG-A6 | dyadic irreducible row-stochastic P | nonuniform stationary left vector | [markov.m](../../../examples/tiered/neig-tier-a/markov.m) | [markov.md](neig-tier-a/markov.md) | [Miyajima 2021](https://doi.org/10.13001/ela.2021.5181) |
| PERRON_POS | NEIG-A6 | positive diagonal similarity of P | positive root and both vectors | [perron_pos.m](../../../examples/tiered/neig-tier-a/perron_pos.m) | [perron_pos.md](neig-tier-a/perron_pos.md) | [Miyajima 2021](https://doi.org/10.13001/ela.2021.5181) |
| HAD_COMPLEX | NEIG-A1 | quarter-turn unitary phase | complex adjoint convention | [had_complex.m](../../../examples/tiered/neig-tier-a/had_complex.m) | [had_complex.md](neig-tier-a/had_complex.md) | [Rump 2022](https://doi.org/10.1137/21M1451440) |
| S1-NRO-TWO | SVD-S1 | NRO block with reciprocal weights | reciprocal extreme values | [nro_two.m](../../../examples/tiered/svd-tier-s/nro_two.m) | [nro_two.md](svd-tier-s/nro_two.md) | [Nishi et al. 2011](https://doi.org/10.1587/nolta.2.226) |
| S1-NRO-THREE | SVD-S1 | NRO block with zero-weight half | unit and reciprocal groups | [nro_three.m](../../../examples/tiered/svd-tier-s/nro_three.m) | [nro_three.md](svd-tier-s/nro_three.md) | [Nishi et al. 2011](https://doi.org/10.1587/nolta.2.226) |
| S1-NRO-GRADED | SVD-S1 | graded powers-of-two weights | multiple singular scales | [nro_graded.m](../../../examples/tiered/svd-tier-s/nro_graded.m) | [nro_graded.md](svd-tier-s/nro_graded.md) | [Nishi et al. 2011](https://doi.org/10.1587/nolta.2.226) |
| S1-NRO-SCALE-UP | SVD-S1 | $2^{600}$ NRO scale control | large exponent range | [nro_scale_up.m](../../../examples/tiered/svd-tier-s/nro_scale_up.m) | [nro_scale_up.md](svd-tier-s/nro_scale_up.md) | [MPFR manual](https://www.mpfr.org/mpfr-current/mpfr.html) |
| S1-NRO-SCALE-DOWN | SVD-S1 | $2^{-600}$ NRO scale control | small exponent range | [nro_scale_down.m](../../../examples/tiered/svd-tier-s/nro_scale_down.m) | [nro_scale_down.md](svd-tier-s/nro_scale_down.md) | [MPFR manual](https://www.mpfr.org/mpfr-current/mpfr.html) |
| S2-JS | SVD-S2 | Jacobi–Stirling lower triangle | combinatorial growth | [jacobi_stirling.m](../../../examples/tiered/svd-tier-s/jacobi_stirling.m) | [jacobi_stirling.md](svd-tier-s/jacobi_stirling.md) | [Delgado–Peña 2014](https://doi.org/10.1016/j.amc.2014.03.047) |
| S3-LAH | SVD-S3 | unsigned Lah lower triangle | growth and small tail | [lah.m](../../../examples/tiered/svd-tier-s/lah.m) | [lah.md](svd-tier-s/lah.md) | [Delgado et al. 2019](https://doi.org/10.1002/nla.2217) |
| S4-DD-SYM | SVD-S4 | symmetric shifted path | exact tiny $\sigma_{\min}$ | [dd_sym.m](../../../examples/tiered/svd-tier-s/dd_sym.m) | [dd_sym.md](svd-tier-s/dd_sym.md) | [Dopico–Koev 2011](https://doi.org/10.1007/s00211-011-0382-3) |
| S4-DD-NONSYM | SVD-S4 | biased dominant path | eigenvalue is not $\sigma_{\min}$ | [dd_nonsym.m](../../../examples/tiered/svd-tier-s/dd_nonsym.m) | [dd_nonsym.md](svd-tier-s/dd_nonsym.md) | [Dopico–Koev 2011](https://doi.org/10.1007/s00211-011-0382-3) |
| A1-PASCAL-LOWER | SVD-A1 | lower Pascal Q | exact combinatorial source | [pascal_lower.m](../../../examples/tiered/svd-tier-a/pascal_lower.m) | [pascal_lower.md](svd-tier-a/pascal_lower.md) | [Alonso et al. 2013](https://doi.org/10.1016/j.cam.2011.12.007) |
| A1-PASCAL-SYM | SVD-A1 | $P=QQ^{\mathsf T}$ | dense symmetric product | [pascal_sym.m](../../../examples/tiered/svd-tier-a/pascal_sym.m) | [pascal_sym.md](svd-tier-a/pascal_sym.md) | [Alonso et al. 2013](https://doi.org/10.1016/j.cam.2011.12.007) |
| A2-VAND | SVD-A2 | dyadic-node Vandermonde | node and power conditioning | [vandermonde.m](../../../examples/tiered/svd-tier-a/vandermonde.m) | [vandermonde.md](svd-tier-a/vandermonde.md) | [Koev 2005](https://doi.org/10.1137/S0895479803438225) |
| A3-BDI-RAW | SVD-A3 | graded upper bidiagonal | small-tail accuracy | [bidiag_raw.m](../../../examples/tiered/svd-tier-a/bidiag_raw.m) | [bidiag_raw.md](svd-tier-a/bidiag_raw.md) | [LAPACK DLASQ1](https://www.netlib.org/lapack/explore-html/d5/dce/group__lasq1_ga5a8c1474ef61ff7c59c17412ae456ca6.html) |
| A3-BDI-MIXED | SVD-A3 | $HBG^{\mathsf T}/n$ | dense representation | [bidiag_mixed.m](../../../examples/tiered/svd-tier-a/bidiag_mixed.m) | [bidiag_mixed.md](svd-tier-a/bidiag_mixed.md) | [LAPACK DLASQ1](https://www.netlib.org/lapack/explore-html/d5/dce/group__lasq1_ga5a8c1474ef61ff7c59c17412ae456ca6.html) |
| A4-LAU-TALL | SVD-A4 | tall Läuchli construction | repeated small group | [lauchli_tall.m](../../../examples/tiered/svd-tier-a/lauchli_tall.m) | [lauchli_tall.md](svd-tier-a/lauchli_tall.md) | [Läuchli 1961](https://doi.org/10.1007/BF01386022) |
| A4-LAU-WIDE | SVD-A4 | transpose of tall case | shape and side exchange | [lauchli_wide.m](../../../examples/tiered/svd-tier-a/lauchli_wide.m) | [lauchli_wide.md](svd-tier-a/lauchli_wide.md) | [Läuchli 1961](https://doi.org/10.1007/BF01386022) |
| A4-LAU-COMPLEX | SVD-A4 | phased complex tall case | MPC conjugation | [lauchli_complex.m](../../../examples/tiered/svd-tier-a/lauchli_complex.m) | [lauchli_complex.md](svd-tier-a/lauchli_complex.md) | [Läuchli 1961](https://doi.org/10.1007/BF01386022) |
| A5-GEO | SVD-A5 | Hadamard mix of geometric d | dense known spectrum | [hadamard_geometric.m](../../../examples/tiered/svd-tier-a/hadamard_geometric.m) | [hadamard_geometric.md](svd-tier-a/hadamard_geometric.md) | [Wedin 1972](https://doi.org/10.1007/BF01932678) |
| A5-CLOSE | SVD-A5 | close Hadamard pair | value gap and vector gap | [hadamard_close.m](../../../examples/tiered/svd-tier-a/hadamard_close.m) | [hadamard_close.md](svd-tier-a/hadamard_close.md) | [Wedin 1972](https://doi.org/10.1007/BF01932678) |
| A5-REPEAT | SVD-A5 | repeated Hadamard group | subspace, not columns | [hadamard_repeat.m](../../../examples/tiered/svd-tier-a/hadamard_repeat.m) | [hadamard_repeat.md](svd-tier-a/hadamard_repeat.md) | [Wedin 1972](https://doi.org/10.1007/BF01932678) |
| A5-RANK4 | SVD-A5 | four positive d values | exact rank four | [hadamard_rank4.m](../../../examples/tiered/svd-tier-a/hadamard_rank4.m) | [hadamard_rank4.md](svd-tier-a/hadamard_rank4.md) | [Wedin 1972](https://doi.org/10.1007/BF01932678) |
| A5-RANK5 | SVD-A5 | $\eta$ beside exact zeros | near-rank boundary | [hadamard_rank5.m](../../../examples/tiered/svd-tier-a/hadamard_rank5.m) | [hadamard_rank5.md](svd-tier-a/hadamard_rank5.md) | [Wedin 1972](https://doi.org/10.1007/BF01932678) |
| A6-NRO-COMPANION | SVD-A6 | bounded-integer companion-like | recurrence and dense SVD | [nro_companion.m](../../../examples/tiered/svd-tier-a/nro_companion.m) | [nro_companion.md](svd-tier-a/nro_companion.md) | [Nishi et al. 2011](https://doi.org/10.1587/nolta.2.226) |

## Running the layers

One-case pages are deliberately light-weight entry points:

~~~octave
pkg load mplapack-interop
run ("examples/tiered/neig-tier-s/sim_jordan.m");
run ("examples/tiered/svd-tier-a/hadamard_close.m");
~~~

The counted measurement runners remain authoritative:

~~~octave
pkg load mplapack-interop
addpath (fullfile (pwd (), "examples", "neig_tiers"));
neig_smoke = mp_neig_tiers ("smoke", struct ("plot", false));
addpath (fullfile (pwd (), "examples", "svd_tiers"));
svd_smoke = mp_svd_tiers ("smoke", struct ("plot", false));
~~~

Use the NEIG V-S/V-A examples and SVT V verification entry points only for the certificate claims they explicitly report. Stress and plotting are opt-in and remain outside ordinary PASS unless executed.

## Historical and verification surfaces

- [NEIG Tier S guide](neig-tier-s/README.md), [NEIG Tier A guide](neig-tier-a/README.md).
- [SVD Tier S guide](svd-tier-s/README.md), [SVD Tier A guide](svd-tier-a/README.md).
- [Migration table](MIGRATION.md).
- [NEIG cases](../../../docs/codex/neigt/cases.json), [NEIG verification jobs](../../../docs/codex/neigt/verification-jobs.json), and [NEIG sources](../../../docs/codex/neigt/SOURCES.md).
- [SVT cases](../../../docs/codex/svt/cases.json), [SVT verification](../../../docs/codex/svt/VERIFICATION.md), and [SVT sources](../../../docs/codex/svt/SOURCES.md).
- Historical numbered indexes: [14_neig_tier_s.m](../../../examples/14_neig_tier_s.m), [15_neig_tier_a.m](../../../examples/15_neig_tier_a.m), [14_svd_tier_s.m](../../../examples/14_svd_tier_s.m), [15_svd_tier_a.m](../../../examples/15_svd_tier_a.m).
- Full measured V surfaces: [16_neig_verified_vs.m](../../../examples/16_neig_verified_vs.m), [17_neig_verified_va.m](../../../examples/17_neig_verified_va.m), [16_svd_verified.m](../../../examples/16_svd_verified.m).

This map is pedagogical. It does not replace the exact-count profile gates, replay/adversarial tests, or isolated clean-package QA.
