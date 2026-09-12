# Nonsymmetric eigensystem — Tier S

This family page is the short-case index for the project-specific Tier-S nonsymmetric eigensystem examples. Each row has one runnable example and one detailed explanation. The complete manifest/profile runner remains the regression authority.

| Case ID | Runnable example | Detailed explanation |
|---|---|---|
| `OO53_REAL` | [`oo53_real.m`](../../../../examples/tiered/neig-tier-s/oo53_real.m) | [`oo53_real.md`](./oo53_real.md) |
| `OO53_PAIR` | [`oo53_pair.m`](../../../../examples/tiered/neig-tier-s/oo53_pair.m) | [`oo53_pair.md`](./oo53_pair.md) |
| `OO128_CLOSE` | [`oo128_close.m`](../../../../examples/tiered/neig-tier-s/oo128_close.m) | [`oo128_close.md`](./oo128_close.md) |
| `SIM_SIMPLE` | [`sim_simple.m`](../../../../examples/tiered/neig-tier-s/sim_simple.m) | [`sim_simple.md`](./sim_simple.md) |
| `SIM_REPEAT` | [`sim_repeat.m`](../../../../examples/tiered/neig-tier-s/sim_repeat.m) | [`sim_repeat.md`](./sim_repeat.md) |
| `SIM_JORDAN` | [`sim_jordan.m`](../../../../examples/tiered/neig-tier-s/sim_jordan.m) | [`sim_jordan.md`](./sim_jordan.md) |
| `SIM_TWO_JORDAN` | [`sim_two_jordan.m`](../../../../examples/tiered/neig-tier-s/sim_two_jordan.m) | [`sim_two_jordan.md`](./sim_two_jordan.md) |
| `TOEPLITZ` | [`toeplitz.m`](../../../../examples/tiered/neig-tier-s/toeplitz.m) | [`toeplitz.md`](./toeplitz.md) |
| `TOEPLITZ_SYM` | [`toeplitz_sym.m`](../../../../examples/tiered/neig-tier-s/toeplitz_sym.m) | [`toeplitz_sym.md`](./toeplitz_sym.md) |
| `FORSYTHE` | [`forsythe.m`](../../../../examples/tiered/neig-tier-s/forsythe.m) | [`forsythe.md`](./forsythe.md) |
| `FORSYTHE_SCALED` | [`forsythe_scaled.m`](../../../../examples/tiered/neig-tier-s/forsythe_scaled.m) | [`forsythe_scaled.md`](./forsythe_scaled.md) |
| `FORSYTHE_ZERO` | [`forsythe_zero.m`](../../../../examples/tiered/neig-tier-s/forsythe_zero.m) | [`forsythe_zero.md`](./forsythe_zero.md) |

## Run the complete family

From a configured checkout, use the full measured runner rather than this page's index:

```octave
pkg load mplapack-interop
addpath (fullfile (pwd (), "examples", "neig_tiers"));
result = mp_neig_tiers ("smoke", struct ("tier", "S", "plot", false));
```

The standard smoke profile contains 12 Tier-S and 8 Tier-A cases; the demo profile adds the complex Hadamard case.
