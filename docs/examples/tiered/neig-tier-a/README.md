# Nonsymmetric eigensystem — Tier A

This family page is the short-case index for the project-specific Tier-A nonsymmetric eigensystem examples. Each row has one runnable example and one detailed explanation. The complete manifest/profile runner remains the regression authority.

| Case ID | Runnable example | Detailed explanation |
|---|---|---|
| `HAD_BIDIAG` | [`had_bidiag.m`](../../../../examples/tiered/neig-tier-a/had_bidiag.m) | [`had_bidiag.md`](./had_bidiag.md) |
| `FRANK0` | [`frank0.m`](../../../../examples/tiered/neig-tier-a/frank0.m) | [`frank0.md`](./frank0.md) |
| `FRANK1` | [`frank1.m`](../../../../examples/tiered/neig-tier-a/frank1.m) | [`frank1.md`](./frank1.md) |
| `WILKINSON` | [`wilkinson.m`](../../../../examples/tiered/neig-tier-a/wilkinson.m) | [`wilkinson.md`](./wilkinson.md) |
| `GRCAR` | [`grcar.m`](../../../../examples/tiered/neig-tier-a/grcar.m) | [`grcar.md`](./grcar.md) |
| `MKS` | [`mks.m`](../../../../examples/tiered/neig-tier-a/mks.m) | [`mks.md`](./mks.md) |
| `MARKOV` | [`markov.m`](../../../../examples/tiered/neig-tier-a/markov.m) | [`markov.md`](./markov.md) |
| `PERRON_POS` | [`perron_pos.m`](../../../../examples/tiered/neig-tier-a/perron_pos.m) | [`perron_pos.md`](./perron_pos.md) |
| `HAD_COMPLEX` | [`had_complex.m`](../../../../examples/tiered/neig-tier-a/had_complex.m) | [`had_complex.md`](./had_complex.md) |

## Run the complete family

From a configured checkout, use the full measured runner rather than this page's index:

```octave
pkg load mplapack-interop
addpath (fullfile (pwd (), "examples", "neig_tiers"));
result = mp_neig_tiers ("smoke", struct ("tier", "A", "plot", false));
```

The standard smoke profile contains 12 Tier-S and 8 Tier-A cases; the demo profile adds the complex Hadamard case.
