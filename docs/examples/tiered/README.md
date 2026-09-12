# Tiered NEIG and SVD examples

This is the master index for the decomposed difficult-eigensystem and singular-value examples. The four family pages below contain exactly one short runnable example and one matching detailed explanation per standard case. The old numbered scripts remain compatibility indexes and full smoke aggregators; the heavy manifest runners and V examples remain the regression/verification surfaces.

## Families

| Family | Cases | Index |
|---|---:|---|
| Nonsymmetric eigensystem — Tier S | 12 | [`neig-tier-s/README.md`](neig-tier-s/README.md) |
| Nonsymmetric eigensystem — Tier A | 9 | [`neig-tier-a/README.md`](neig-tier-a/README.md) |
| Singular value decomposition — Tier S | 9 | [`svd-tier-s/README.md`](svd-tier-s/README.md) |
| Singular value decomposition — Tier A | 14 | [`svd-tier-a/README.md`](svd-tier-a/README.md) |
## Suggested order

1. Start with the family page and run one case file.
2. Read its matching `.md` before changing dimensions or precision.
3. Run the complete `mp_neig_tiers` or `mp_svd_tiers` smoke/demo profile for counted regression coverage.
4. Use the existing verified V entry points only when a certificate, replay bundle, or adversarial check is required.

## Precision and interpretation

All cases use the existing public `mp`, `mpbits`, `eig`, `svd`, and related inspection interfaces. A measured residual is not automatically a forward-error or conditioning certificate. Repeated/defective eigenspaces and repeated singular subspaces are compared as subspaces; complex left eigenvectors and SVD factors use conjugate transpose.

## Historical entry points

- [`examples/14_neig_tier_s.m`](../../../examples/14_neig_tier_s.m) and [`examples/15_neig_tier_a.m`](../../../examples/15_neig_tier_a.m) are family indexes.
- [`examples/14_svd_tier_s.m`](../../../examples/14_svd_tier_s.m) and [`examples/15_svd_tier_a.m`](../../../examples/15_svd_tier_a.m) are family indexes.
- `examples/neig_tiers/mp_neig_tiers.m` and `examples/svd_tiers/mp_svd_tiers.m` preserve full measured coverage.
- `examples/16_neig_verified_vs.m`, `examples/17_neig_verified_va.m`, and `examples/16_svd_verified.m` preserve verification examples.

See [`MIGRATION.md`](MIGRATION.md) for the old-to-new map.
