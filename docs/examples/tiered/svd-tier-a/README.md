# Singular value decomposition — Tier A

This family page is the short-case index for the project-specific Tier-A SVD examples. Each row has one runnable example and one detailed explanation. The complete manifest/profile runner remains the regression authority.

| Case ID | Runnable example | Detailed explanation |
|---|---|---|
| `A1-PASCAL-LOWER` | [`pascal_lower.m`](../../../../examples/tiered/svd-tier-a/pascal_lower.m) | [`pascal_lower.md`](./pascal_lower.md) |
| `A1-PASCAL-SYM` | [`pascal_sym.m`](../../../../examples/tiered/svd-tier-a/pascal_sym.m) | [`pascal_sym.md`](./pascal_sym.md) |
| `A2-VAND` | [`vandermonde.m`](../../../../examples/tiered/svd-tier-a/vandermonde.m) | [`vandermonde.md`](./vandermonde.md) |
| `A3-BDI-RAW` | [`bidiag_raw.m`](../../../../examples/tiered/svd-tier-a/bidiag_raw.m) | [`bidiag_raw.md`](./bidiag_raw.md) |
| `A3-BDI-MIXED` | [`bidiag_mixed.m`](../../../../examples/tiered/svd-tier-a/bidiag_mixed.m) | [`bidiag_mixed.md`](./bidiag_mixed.md) |
| `A4-LAU-TALL` | [`lauchli_tall.m`](../../../../examples/tiered/svd-tier-a/lauchli_tall.m) | [`lauchli_tall.md`](./lauchli_tall.md) |
| `A4-LAU-WIDE` | [`lauchli_wide.m`](../../../../examples/tiered/svd-tier-a/lauchli_wide.m) | [`lauchli_wide.md`](./lauchli_wide.md) |
| `A4-LAU-COMPLEX` | [`lauchli_complex.m`](../../../../examples/tiered/svd-tier-a/lauchli_complex.m) | [`lauchli_complex.md`](./lauchli_complex.md) |
| `A5-GEO` | [`hadamard_geometric.m`](../../../../examples/tiered/svd-tier-a/hadamard_geometric.m) | [`hadamard_geometric.md`](./hadamard_geometric.md) |
| `A5-CLOSE` | [`hadamard_close.m`](../../../../examples/tiered/svd-tier-a/hadamard_close.m) | [`hadamard_close.md`](./hadamard_close.md) |
| `A5-REPEAT` | [`hadamard_repeat.m`](../../../../examples/tiered/svd-tier-a/hadamard_repeat.m) | [`hadamard_repeat.md`](./hadamard_repeat.md) |
| `A5-RANK4` | [`hadamard_rank4.m`](../../../../examples/tiered/svd-tier-a/hadamard_rank4.m) | [`hadamard_rank4.md`](./hadamard_rank4.md) |
| `A5-RANK5` | [`hadamard_rank5.m`](../../../../examples/tiered/svd-tier-a/hadamard_rank5.m) | [`hadamard_rank5.md`](./hadamard_rank5.md) |
| `A6-NRO-COMPANION` | [`nro_companion.m`](../../../../examples/tiered/svd-tier-a/nro_companion.m) | [`nro_companion.md`](./nro_companion.md) |

## Run the complete family

From a configured checkout, use the full measured runner rather than this page's index:

```octave
pkg load mplapack-interop
addpath (fullfile (pwd (), "examples", "svd_tiers"));
result = mp_svd_tiers ("smoke", struct ("tier", "A", "plot", false));
```

The standard smoke profile contains 7 Tier-S and 13 Tier-A cases; the demo profile adds the scale and complex controls.
