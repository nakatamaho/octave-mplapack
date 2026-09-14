# Singular value decompositions — Tier A

Tier A broadens the SVD path with Pascal and Vandermonde structure, raw versus dense bidiagonal representations, tall/wide/complex Läuchli shapes, known singular-value groups, exact rank controls, and a bounded-integer companion-like construction.

The detailed pages print every small smoke or fixed control in full with exact
integer or dyadic entries, including the small rectangular and complex
Läuchli controls. The source matrix is kept separate from measured SVD output,
and the exact generator comparison is `tools/check-smoke-matrices.sh`.

## Core equation and interpretation

For $A\in\mathbb{C}^{m\times n}$:

```math
A=U\Sigma V^{\mathsf H},
\qquad
r_{\mathrm{svd}}=
\frac{\lVert A-U\Sigma V^{\mathsf H}\rVert_F}{\lVert A\rVert_F},
\qquad
r_U=\lVert U^{\mathsf H}U-I\rVert_F,\quad
r_V=\lVert V^{\mathsf H}V-I\rVert_F.
```

The value spectrum, reconstruction, factor orthogonality, rank, and repeated subspaces are separate diagnostics. A known spectrum does not make individual factors canonical, and a tiny measured singular value is not automatically an exact rank proof.

## Learning map

| Case | Mathematical object | Main question | Start here | Detailed page | External primary context |
|---|---|---|---|---|---|
| A1-PASCAL-LOWER | lower binomial triangle Q | exact combinatorial input | [pascal_lower.m](../../../../examples/tiered/svd-tier-a/pascal_lower.m) | [pascal_lower.md](./pascal_lower.md) | [Alonso et al. (2013)](https://doi.org/10.1016/j.cam.2011.12.007) |
| A1-PASCAL-SYM | $P=QQ^{\mathsf T}$ | dense symmetric product | [pascal_sym.m](../../../../examples/tiered/svd-tier-a/pascal_sym.m) | [pascal_sym.md](./pascal_sym.md) | [Alonso et al. (2013)](https://doi.org/10.1016/j.cam.2011.12.007) |
| A2-VAND | dyadic-node Vandermonde | powers and node conditioning | [vandermonde.m](../../../../examples/tiered/svd-tier-a/vandermonde.m) | [vandermonde.md](./vandermonde.md) | [Koev (2005)](https://doi.org/10.1137/S0895479803438225) |
| A3-BDI-RAW | graded upper bidiagonal | relative tail accuracy | [bidiag_raw.m](../../../../examples/tiered/svd-tier-a/bidiag_raw.m) | [bidiag_raw.md](./bidiag_raw.md) | [LAPACK DLASQ1](https://www.netlib.org/lapack/explore-html/d5/dce/group__lasq1_ga5a8c1474ef61ff7c59c17412ae456ca6.html) |
| A3-BDI-MIXED | $HBG^{\mathsf T}/n$ | dense representation | [bidiag_mixed.m](../../../../examples/tiered/svd-tier-a/bidiag_mixed.m) | [bidiag_mixed.md](./bidiag_mixed.md) | [LAPACK DLASQ1](https://www.netlib.org/lapack/explore-html/d5/dce/group__lasq1_ga5a8c1474ef61ff7c59c17412ae456ca6.html) |
| A4-LAU-TALL | tall Läuchli construction | repeated small group | [lauchli_tall.m](../../../../examples/tiered/svd-tier-a/lauchli_tall.m) | [lauchli_tall.md](./lauchli_tall.md) | [Läuchli (1961)](https://doi.org/10.1007/BF01386022) |
| A4-LAU-WIDE | transpose of tall case | shape and side exchange | [lauchli_wide.m](../../../../examples/tiered/svd-tier-a/lauchli_wide.m) | [lauchli_wide.md](./lauchli_wide.md) | [Läuchli (1961)](https://doi.org/10.1007/BF01386022) |
| A4-LAU-COMPLEX | phased complex tall case | MPC conjugation | [lauchli_complex.m](../../../../examples/tiered/svd-tier-a/lauchli_complex.m) | [lauchli_complex.md](./lauchli_complex.md) | [Läuchli (1961)](https://doi.org/10.1007/BF01386022) |
| A5-GEO | Hadamard mix of geometric d | dense known spectrum | [hadamard_geometric.m](../../../../examples/tiered/svd-tier-a/hadamard_geometric.m) | [hadamard_geometric.md](./hadamard_geometric.md) | [Wedin (1972)](https://doi.org/10.1007/BF01932678) |
| A5-CLOSE | close Hadamard pair | value gap versus vector gap | [hadamard_close.m](../../../../examples/tiered/svd-tier-a/hadamard_close.m) | [hadamard_close.md](./hadamard_close.md) | [Wedin (1972)](https://doi.org/10.1007/BF01932678) |
| A5-REPEAT | repeated Hadamard group | subspace, not columns | [hadamard_repeat.m](../../../../examples/tiered/svd-tier-a/hadamard_repeat.m) | [hadamard_repeat.md](./hadamard_repeat.md) | [Wedin (1972)](https://doi.org/10.1007/BF01932678) |
| A5-RANK4 | four nonzero d values | exact rank four | [hadamard_rank4.m](../../../../examples/tiered/svd-tier-a/hadamard_rank4.m) | [hadamard_rank4.md](./hadamard_rank4.md) | [Wedin (1972)](https://doi.org/10.1007/BF01932678) |
| A5-RANK5 | $\eta$ next to exact zeros | near-rank boundary | [hadamard_rank5.m](../../../../examples/tiered/svd-tier-a/hadamard_rank5.m) | [hadamard_rank5.md](./hadamard_rank5.md) | [Wedin (1972)](https://doi.org/10.1007/BF01932678) |
| A6-NRO-COMPANION | bounded-integer companion-like | recurrence and dense SVD | [nro_companion.m](../../../../examples/tiered/svd-tier-a/nro_companion.m) | [nro_companion.md](./nro_companion.md) | [Nishi–Rump–Oishi (2011)](https://doi.org/10.1587/nolta.2.226) |

The references establish the external setting; these fixed parameters and measured dense SVD runs are suite-specific adaptations.

## How to run

~~~octave
pkg load mplapack-interop
run ("examples/tiered/svd-tier-a/hadamard_close.m");
~~~

For counted coverage:

~~~octave
pkg load mplapack-interop
addpath (fullfile (pwd (), "examples", "svd_tiers"));
result = mp_svd_tiers ("demo", struct ("tier", "A", "plot", false));
~~~

The smoke profile has 13 Tier A cases and the demo adds complex Läuchli plus the S1 scale controls. V1/V2/V3 certificates remain separate from ordinary measured SVD rows.

## Suggested order

Read Pascal lower/symmetric first, then raw/mixed bidiagonal. Use tall/wide/complex Läuchli to understand shape and conjugation. Finish with geometric, close, repeated, rank-four/rank-five Hadamard cases and the companion-like matrix. At each step keep value, factor, rank, and subspace claims separate.

See the [master map](../README.md), [SVT cases](../../../../docs/codex/svt/cases.json), [SVT verification limits](../../../../docs/codex/svt/VERIFICATION.md), and [SVT sources](../../../../docs/codex/svt/SOURCES.md).
