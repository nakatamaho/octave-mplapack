# Tiered example migration

EXDOC01 decomposes the four original numbered Tier S/A surfaces without changing their numerical fixtures or deleting their regression runners. The numbered files now act as deterministic indexes.

| Original entry point | New family index | Split cases | Regression authority |
|---|---|---:|---|
| `examples/14_neig_tier_s.m` | [`neig-tier-s/README.md`](neig-tier-s/README.md) | 12 | `examples/neig_tiers/mp_neig_tiers.m` + `test_neigt*` |
| `examples/15_neig_tier_a.m` | [`neig-tier-a/README.md`](neig-tier-a/README.md) | 9 | `examples/neig_tiers/mp_neig_tiers.m` + `test_neigt*` |
| `examples/14_svd_tier_s.m` | [`svd-tier-s/README.md`](svd-tier-s/README.md) | 9 | `examples/svd_tiers/mp_svd_tiers.m` + `test_svd_tiers` |
| `examples/15_svd_tier_a.m` | [`svd-tier-a/README.md`](svd-tier-a/README.md) | 14 | `examples/svd_tiers/mp_svd_tiers.m` + `test_svd_tiers` |

## Nonsymmetric eigensystem — Tier S

- `OO53_REAL` → [`examples/tiered/neig-tier-s/oo53_real.m`](../../../examples/tiered/neig-tier-s/oo53_real.m) + [`oo53_real.md`](./neig-tier-s/oo53_real.md)
- `OO53_PAIR` → [`examples/tiered/neig-tier-s/oo53_pair.m`](../../../examples/tiered/neig-tier-s/oo53_pair.m) + [`oo53_pair.md`](./neig-tier-s/oo53_pair.md)
- `OO128_CLOSE` → [`examples/tiered/neig-tier-s/oo128_close.m`](../../../examples/tiered/neig-tier-s/oo128_close.m) + [`oo128_close.md`](./neig-tier-s/oo128_close.md)
- `SIM_SIMPLE` → [`examples/tiered/neig-tier-s/sim_simple.m`](../../../examples/tiered/neig-tier-s/sim_simple.m) + [`sim_simple.md`](./neig-tier-s/sim_simple.md)
- `SIM_REPEAT` → [`examples/tiered/neig-tier-s/sim_repeat.m`](../../../examples/tiered/neig-tier-s/sim_repeat.m) + [`sim_repeat.md`](./neig-tier-s/sim_repeat.md)
- `SIM_JORDAN` → [`examples/tiered/neig-tier-s/sim_jordan.m`](../../../examples/tiered/neig-tier-s/sim_jordan.m) + [`sim_jordan.md`](./neig-tier-s/sim_jordan.md)
- `SIM_TWO_JORDAN` → [`examples/tiered/neig-tier-s/sim_two_jordan.m`](../../../examples/tiered/neig-tier-s/sim_two_jordan.m) + [`sim_two_jordan.md`](./neig-tier-s/sim_two_jordan.md)
- `TOEPLITZ` → [`examples/tiered/neig-tier-s/toeplitz.m`](../../../examples/tiered/neig-tier-s/toeplitz.m) + [`toeplitz.md`](./neig-tier-s/toeplitz.md)
- `TOEPLITZ_SYM` → [`examples/tiered/neig-tier-s/toeplitz_sym.m`](../../../examples/tiered/neig-tier-s/toeplitz_sym.m) + [`toeplitz_sym.md`](./neig-tier-s/toeplitz_sym.md)
- `FORSYTHE` → [`examples/tiered/neig-tier-s/forsythe.m`](../../../examples/tiered/neig-tier-s/forsythe.m) + [`forsythe.md`](./neig-tier-s/forsythe.md)
- `FORSYTHE_SCALED` → [`examples/tiered/neig-tier-s/forsythe_scaled.m`](../../../examples/tiered/neig-tier-s/forsythe_scaled.m) + [`forsythe_scaled.md`](./neig-tier-s/forsythe_scaled.md)
- `FORSYTHE_ZERO` → [`examples/tiered/neig-tier-s/forsythe_zero.m`](../../../examples/tiered/neig-tier-s/forsythe_zero.m) + [`forsythe_zero.md`](./neig-tier-s/forsythe_zero.md)

## Nonsymmetric eigensystem — Tier A

- `HAD_BIDIAG` → [`examples/tiered/neig-tier-a/had_bidiag.m`](../../../examples/tiered/neig-tier-a/had_bidiag.m) + [`had_bidiag.md`](./neig-tier-a/had_bidiag.md)
- `FRANK0` → [`examples/tiered/neig-tier-a/frank0.m`](../../../examples/tiered/neig-tier-a/frank0.m) + [`frank0.md`](./neig-tier-a/frank0.md)
- `FRANK1` → [`examples/tiered/neig-tier-a/frank1.m`](../../../examples/tiered/neig-tier-a/frank1.m) + [`frank1.md`](./neig-tier-a/frank1.md)
- `WILKINSON` → [`examples/tiered/neig-tier-a/wilkinson.m`](../../../examples/tiered/neig-tier-a/wilkinson.m) + [`wilkinson.md`](./neig-tier-a/wilkinson.md)
- `GRCAR` → [`examples/tiered/neig-tier-a/grcar.m`](../../../examples/tiered/neig-tier-a/grcar.m) + [`grcar.md`](./neig-tier-a/grcar.md)
- `MKS` → [`examples/tiered/neig-tier-a/mks.m`](../../../examples/tiered/neig-tier-a/mks.m) + [`mks.md`](./neig-tier-a/mks.md)
- `MARKOV` → [`examples/tiered/neig-tier-a/markov.m`](../../../examples/tiered/neig-tier-a/markov.m) + [`markov.md`](./neig-tier-a/markov.md)
- `PERRON_POS` → [`examples/tiered/neig-tier-a/perron_pos.m`](../../../examples/tiered/neig-tier-a/perron_pos.m) + [`perron_pos.md`](./neig-tier-a/perron_pos.md)
- `HAD_COMPLEX` → [`examples/tiered/neig-tier-a/had_complex.m`](../../../examples/tiered/neig-tier-a/had_complex.m) + [`had_complex.md`](./neig-tier-a/had_complex.md)

## Singular value decomposition — Tier S

- `S1-NRO-TWO` → [`examples/tiered/svd-tier-s/nro_two.m`](../../../examples/tiered/svd-tier-s/nro_two.m) + [`nro_two.md`](./svd-tier-s/nro_two.md)
- `S1-NRO-THREE` → [`examples/tiered/svd-tier-s/nro_three.m`](../../../examples/tiered/svd-tier-s/nro_three.m) + [`nro_three.md`](./svd-tier-s/nro_three.md)
- `S1-NRO-GRADED` → [`examples/tiered/svd-tier-s/nro_graded.m`](../../../examples/tiered/svd-tier-s/nro_graded.m) + [`nro_graded.md`](./svd-tier-s/nro_graded.md)
- `S1-NRO-SCALE-UP` → [`examples/tiered/svd-tier-s/nro_scale_up.m`](../../../examples/tiered/svd-tier-s/nro_scale_up.m) + [`nro_scale_up.md`](./svd-tier-s/nro_scale_up.md)
- `S1-NRO-SCALE-DOWN` → [`examples/tiered/svd-tier-s/nro_scale_down.m`](../../../examples/tiered/svd-tier-s/nro_scale_down.m) + [`nro_scale_down.md`](./svd-tier-s/nro_scale_down.md)
- `S2-JS` → [`examples/tiered/svd-tier-s/jacobi_stirling.m`](../../../examples/tiered/svd-tier-s/jacobi_stirling.m) + [`jacobi_stirling.md`](./svd-tier-s/jacobi_stirling.md)
- `S3-LAH` → [`examples/tiered/svd-tier-s/lah.m`](../../../examples/tiered/svd-tier-s/lah.m) + [`lah.md`](./svd-tier-s/lah.md)
- `S4-DD-SYM` → [`examples/tiered/svd-tier-s/dd_sym.m`](../../../examples/tiered/svd-tier-s/dd_sym.m) + [`dd_sym.md`](./svd-tier-s/dd_sym.md)
- `S4-DD-NONSYM` → [`examples/tiered/svd-tier-s/dd_nonsym.m`](../../../examples/tiered/svd-tier-s/dd_nonsym.m) + [`dd_nonsym.md`](./svd-tier-s/dd_nonsym.md)

## Singular value decomposition — Tier A

- `A1-PASCAL-LOWER` → [`examples/tiered/svd-tier-a/pascal_lower.m`](../../../examples/tiered/svd-tier-a/pascal_lower.m) + [`pascal_lower.md`](./svd-tier-a/pascal_lower.md)
- `A1-PASCAL-SYM` → [`examples/tiered/svd-tier-a/pascal_sym.m`](../../../examples/tiered/svd-tier-a/pascal_sym.m) + [`pascal_sym.md`](./svd-tier-a/pascal_sym.md)
- `A2-VAND` → [`examples/tiered/svd-tier-a/vandermonde.m`](../../../examples/tiered/svd-tier-a/vandermonde.m) + [`vandermonde.md`](./svd-tier-a/vandermonde.md)
- `A3-BDI-RAW` → [`examples/tiered/svd-tier-a/bidiag_raw.m`](../../../examples/tiered/svd-tier-a/bidiag_raw.m) + [`bidiag_raw.md`](./svd-tier-a/bidiag_raw.md)
- `A3-BDI-MIXED` → [`examples/tiered/svd-tier-a/bidiag_mixed.m`](../../../examples/tiered/svd-tier-a/bidiag_mixed.m) + [`bidiag_mixed.md`](./svd-tier-a/bidiag_mixed.md)
- `A4-LAU-TALL` → [`examples/tiered/svd-tier-a/lauchli_tall.m`](../../../examples/tiered/svd-tier-a/lauchli_tall.m) + [`lauchli_tall.md`](./svd-tier-a/lauchli_tall.md)
- `A4-LAU-WIDE` → [`examples/tiered/svd-tier-a/lauchli_wide.m`](../../../examples/tiered/svd-tier-a/lauchli_wide.m) + [`lauchli_wide.md`](./svd-tier-a/lauchli_wide.md)
- `A4-LAU-COMPLEX` → [`examples/tiered/svd-tier-a/lauchli_complex.m`](../../../examples/tiered/svd-tier-a/lauchli_complex.m) + [`lauchli_complex.md`](./svd-tier-a/lauchli_complex.md)
- `A5-GEO` → [`examples/tiered/svd-tier-a/hadamard_geometric.m`](../../../examples/tiered/svd-tier-a/hadamard_geometric.m) + [`hadamard_geometric.md`](./svd-tier-a/hadamard_geometric.md)
- `A5-CLOSE` → [`examples/tiered/svd-tier-a/hadamard_close.m`](../../../examples/tiered/svd-tier-a/hadamard_close.m) + [`hadamard_close.md`](./svd-tier-a/hadamard_close.md)
- `A5-REPEAT` → [`examples/tiered/svd-tier-a/hadamard_repeat.m`](../../../examples/tiered/svd-tier-a/hadamard_repeat.m) + [`hadamard_repeat.md`](./svd-tier-a/hadamard_repeat.md)
- `A5-RANK4` → [`examples/tiered/svd-tier-a/hadamard_rank4.m`](../../../examples/tiered/svd-tier-a/hadamard_rank4.m) + [`hadamard_rank4.md`](./svd-tier-a/hadamard_rank4.md)
- `A5-RANK5` → [`examples/tiered/svd-tier-a/hadamard_rank5.m`](../../../examples/tiered/svd-tier-a/hadamard_rank5.m) + [`hadamard_rank5.md`](./svd-tier-a/hadamard_rank5.md)
- `A6-NRO-COMPANION` → [`examples/tiered/svd-tier-a/nro_companion.m`](../../../examples/tiered/svd-tier-a/nro_companion.m) + [`nro_companion.md`](./svd-tier-a/nro_companion.md)

## Coverage boundary

The split files are intentionally pedagogical and one-case. Full smoke/demo measured rows, V verification jobs, exact replay, adversarial checks, native controls, and package QA remain in the original harnesses and test runner. The `case_id` option only selects a manifest case; it does not replace or reduce the profile definitions.
