# Singular value decompositions — Tier S

Tier S is the SVD learning path for matrices whose singular values, subspaces, or exponent ranges defeat a residual-only reading. The NRO family begins with exact integer block matrices, Jacobi–Stirling and Lah cases exercise combinatorial growth, and the diagonally dominant pair separates an analytic symmetric tail from a genuinely nonsymmetric SVD.

The detailed pages print every small smoke matrix in full with exact integer or
dyadic entries. The source/model matrix, fixed-generation precision, any exact
widening, and the measured SVD output are kept as distinct objects; the exact
matrix audit is `tools/check-smoke-matrices.sh`.

## Core equation

For $A\in\mathbb{C}^{m\times n}$, the measured factorization is

```math
A=U\Sigma V^{\mathsf H}.
```

Use

```math
r_{\mathrm{svd}}=
\frac{\lVert A-U\Sigma V^{\mathsf H}\rVert_F}{\lVert A\rVert_F},
\qquad
r_U=\lVert U^{\mathsf H}U-I\rVert_F,\qquad
r_V=\lVert V^{\mathsf H}V-I\rVert_F.
```

A small reconstruction residual is a backward-style factorization check. Forward singular-value error depends on scale and gaps; repeated groups require subspace/projector comparisons.

## Learning map

| Case | Mathematical object | Main question | Start here | Detailed page | External primary context |
|---|---|---|---|---|---|
| S1-NRO-TWO | NRO block with all weights $w=2^b$ | reciprocal extreme values | [nro_two.m](../../../../examples/tiered/svd-tier-s/nro_two.m) | [nro_two.md](./nro_two.md) | [Nishi–Rump–Oishi (2011)](https://doi.org/10.1587/nolta.2.226) |
| S1-NRO-THREE | same block with zero-weight half | unit and reciprocal groups | [nro_three.m](../../../../examples/tiered/svd-tier-s/nro_three.m) | [nro_three.md](./nro_three.md) | [Nishi–Rump–Oishi (2011)](https://doi.org/10.1587/nolta.2.226) |
| S1-NRO-GRADED | powers-of-two graded w_j | several singular scales | [nro_graded.m](../../../../examples/tiered/svd-tier-s/nro_graded.m) | [nro_graded.md](./nro_graded.md) | [Nishi–Rump–Oishi (2011)](https://doi.org/10.1587/nolta.2.226) |
| S1-NRO-SCALE-UP | $2^{600}$ times NRO block | large exponent range | [nro_scale_up.m](../../../../examples/tiered/svd-tier-s/nro_scale_up.m) | [nro_scale_up.md](./nro_scale_up.md) | [MPFR manual](https://www.mpfr.org/mpfr-current/mpfr.html) |
| S1-NRO-SCALE-DOWN | $2^{-600}$ times NRO block | small exponent range | [nro_scale_down.m](../../../../examples/tiered/svd-tier-s/nro_scale_down.m) | [nro_scale_down.md](./nro_scale_down.md) | [MPFR manual](https://www.mpfr.org/mpfr-current/mpfr.html) |
| S2-JS | Jacobi–Stirling unit lower triangle | combinatorial growth | [jacobi_stirling.m](../../../../examples/tiered/svd-tier-s/jacobi_stirling.m) | [jacobi_stirling.md](./jacobi_stirling.md) | [Delgado–Peña (2014)](https://doi.org/10.1016/j.amc.2014.03.047) |
| S3-LAH | unsigned Lah lower triangle | growth and small tail | [lah.m](../../../../examples/tiered/svd-tier-s/lah.m) | [lah.md](./lah.md) | [Delgado–Orera–Peña (2019)](https://doi.org/10.1002/nla.2217) |
| S4-DD-SYM | symmetric shifted path | exact tiny $\sigma_{\min}$ | [dd_sym.m](../../../../examples/tiered/svd-tier-s/dd_sym.m) | [dd_sym.md](./dd_sym.md) | [Dopico–Koev (2011)](https://doi.org/10.1007/s00211-011-0382-3) |
| S4-DD-NONSYM | biased diagonally dominant path | eigenvalue is not $\sigma_{\min}$ | [dd_nonsym.m](../../../../examples/tiered/svd-tier-s/dd_nonsym.m) | [dd_nonsym.md](./dd_nonsym.md) | [Dopico–Koev (2011)](https://doi.org/10.1007/s00211-011-0382-3) |

The source papers motivate the families. The selected dimensions, dyadic values, exactness guards, and SVD acceptance thresholds are suite-specific.

## How to run

~~~octave
pkg load mplapack-interop
run ("examples/tiered/svd-tier-s/nro_two.m");
~~~

For counted coverage:

~~~octave
pkg load mplapack-interop
addpath (fullfile (pwd (), "examples", "svd_tiers"));
result = mp_svd_tiers ("smoke", struct ("tier", "S", "plot", false));
~~~

The smoke profile has seven Tier S cases and the demo adds the scale-up, scale-down, and complex controls. Keep the analytic or exact reference separate from the measured U, Sigma, and V.

## Suggested order

Start with NRO-TWO, then NRO-THREE and NRO-GRADED. Use the scale controls to learn input range versus arithmetic precision. Read Jacobi–Stirling and Lah for combinatorial growth, then compare the symmetric and nonsymmetric DD paths. The distinction between input loss, solver error, and mathematical conditioning should be explicit in every report.

See the [master map](../README.md), [SVT cases](../../../../docs/codex/svt/cases.json), [SVT verification limits](../../../../docs/codex/svt/VERIFICATION.md), and [SVT sources](../../../../docs/codex/svt/SOURCES.md).
