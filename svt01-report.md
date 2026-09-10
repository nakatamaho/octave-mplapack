# SVT01 report

## Result

SVT01: PASS. The example-local `mp_svd_tiers` facade now validates profiles,
tiers, options, manifest shape/counts, precision cleanup, exact widening, and
non-overwriting output-directory behavior. It deliberately returns
`status=INCOMPLETE`, `ok=false`, and zero measured rows until later milestones
register and execute all constructors and verification jobs.

## Implementation

```text
examples/svd_tiers/mp_svd_tiers.m
examples/svd_tiers/mp_svd_tiers_selftest.m
examples/svd_tiers/private/svt_load_manifest.m
examples/svd_tiers/private/svt_manifest_profile.m
examples/svd_tiers/private/svt_widen.m
```

The JSON manifest is decoded from the repository-relative path
`docs/codex/svt/cases.json`. The manifest schema, unique IDs, and measured-row
formula are checked. The validated counts are smoke 20 cases/120 rows and demo
23 cases/184 rows. The demo `tier=S` filter reports nine selected cases while
retaining the full manifest count of 23, so filtered coverage is not confused
with full-task completion.

`svt_widen` rejects a target below source precision, creates a target-precision
zero, and adds it to the existing value. It does not use text or binary64
round-trips. An `onCleanup` scope restores the project default after normal and
error paths. The output directory is required to be absent and is never removed
or overwritten by the facade.

## Gate and commands

Environment/module resolution was the SVT00 environment:

```text
GNU Octave 11.1.0
source module: /tmp/t00-t14/src/__mplapack_core__.oct
MPLAPACK: /home/docker/opt/octave-mplapack-stack/lib/libmplapack_mpfr.so.3
```

Executed:

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
tools/dev-octave.sh --eval \
  "addpath('examples/svd_tiers'); report=mp_svd_tiers_selftest(); assert(report.ok);"
```

Observed result: `SVT01 selftest PASS`. The selftest covered invalid profile,
unknown option, invalid tier and plot type, precision restoration, exact value
preservation across 128-to-256-bit widening, insufficient widening rejection,
manifest counts, filtered coverage, new output-directory creation, and
existing-directory rejection. No numerical row was claimed complete.

Branch: `topic/svd-tier-sav-examples`
Starting commit: `9cc37c62733ee645dd0b8096fc989e7ef66c5c2a`
Final commit: recorded after this report is committed
Files changed: `examples/svd_tiers/mp_svd_tiers.m`, `mp_svd_tiers_selftest.m`, four private facade helpers, `svt01-report.md`
Commands run: the selftest command above
Tests: SVT01 facade selftest PASS
Gate: PASS
Known limitations: constructors, measured SVD runner, and all Tier V certificate code remain pending in SVT02 onward
