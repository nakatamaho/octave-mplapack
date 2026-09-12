# Singular value decomposition — Tier S

This family page is the short-case index for the project-specific Tier-S SVD examples. Each row has one runnable example and one detailed explanation. The complete manifest/profile runner remains the regression authority.

| Case ID | Runnable example | Detailed explanation |
|---|---|---|
| `S1-NRO-TWO` | [`nro_two.m`](../../../../examples/tiered/svd-tier-s/nro_two.m) | [`nro_two.md`](./nro_two.md) |
| `S1-NRO-THREE` | [`nro_three.m`](../../../../examples/tiered/svd-tier-s/nro_three.m) | [`nro_three.md`](./nro_three.md) |
| `S1-NRO-GRADED` | [`nro_graded.m`](../../../../examples/tiered/svd-tier-s/nro_graded.m) | [`nro_graded.md`](./nro_graded.md) |
| `S1-NRO-SCALE-UP` | [`nro_scale_up.m`](../../../../examples/tiered/svd-tier-s/nro_scale_up.m) | [`nro_scale_up.md`](./nro_scale_up.md) |
| `S1-NRO-SCALE-DOWN` | [`nro_scale_down.m`](../../../../examples/tiered/svd-tier-s/nro_scale_down.m) | [`nro_scale_down.md`](./nro_scale_down.md) |
| `S2-JS` | [`jacobi_stirling.m`](../../../../examples/tiered/svd-tier-s/jacobi_stirling.m) | [`jacobi_stirling.md`](./jacobi_stirling.md) |
| `S3-LAH` | [`lah.m`](../../../../examples/tiered/svd-tier-s/lah.m) | [`lah.md`](./lah.md) |
| `S4-DD-SYM` | [`dd_sym.m`](../../../../examples/tiered/svd-tier-s/dd_sym.m) | [`dd_sym.md`](./dd_sym.md) |
| `S4-DD-NONSYM` | [`dd_nonsym.m`](../../../../examples/tiered/svd-tier-s/dd_nonsym.m) | [`dd_nonsym.md`](./dd_nonsym.md) |

## Run the complete family

From a configured checkout, use the full measured runner rather than this page's index:

```octave
pkg load mplapack-interop
addpath (fullfile (pwd (), "examples", "svd_tiers"));
result = mp_svd_tiers ("smoke", struct ("tier", "S", "plot", false));
```

The standard smoke profile contains 7 Tier-S and 13 Tier-A cases; the demo profile adds the scale and complex controls.
