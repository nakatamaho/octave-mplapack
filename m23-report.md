# M23 RESULT

Repository: `nakatamaho/octave-mplapack`
Remote: `origin` (`https://github.com/nakatamaho/octave-mplapack.git`)
Branch: `topic/m23-v0.1-freeze`
Starting commit: `d697e6969c393b4f68c6570c0a56d21018cd7cee`
V0.1.0_RC_COMMIT: `TBD`
M23 report commit: `TBD`
Branch tip: `TBD`
PR: `TBD`

## Baseline

- M22 accepted base: `d697e6969c393b4f68c6570c0a56d21018cd7cee`
- M22 release conclusion: `REAL-V0.1-API-CLOSED`
- M20 PPA decision: `REAL-PPA-GO`
- Validated MPLAPACK commit: `1cf03d1a1aa2afecde5f1840fbe9663ecfc31e57`
- Tested Octave: `11.1.0`
- Fresh default precision: `512` bits

## Feature freeze

- Numerical features added: none
- Release-blocking production fixes: none
- Public API changed: none; version/documentation metadata only
- Unsupported surface changed: none
- Compatibility firewall: pending final RC QA
- Result: pending final RC QA

## Version

- DESCRIPTION Name: `mplapack`
- Repository name: `octave-mplapack`
- Version before: `0.1.0-dev`
- Version after: `0.1.0`
- Minimum Octave: `11.1.0`
- NEWS: final `0.1.0` section
- README: release-candidate status and PPA handoff
- Stale 0.1.0-dev references: pending final search
- Result: pending final RC QA

## Release candidate identity

- V0.1.0_RC_COMMIT: `TBD`
- Commit tree: pending final commit
- Source freeze clean: pending final audit (legacy report deletions excluded)
- Subsequent source-changing commits: none permitted after RC
- Report-only commit: `TBD`
- Result: pending final RC QA

## MPLAPACK dependency

- Validated source commit: `1cf03d1a1aa2afecde5f1840fbe9663ecfc31e57`
- pkg-config: `mplapack_mpfr`
- pkg-config version: `3.0.1`
- Required header: `mplapack_mpfr_precision.h`
- Required interface: `MplapackMpfrPrecisionScope`
- Dependency probe: pending final RC QA
- Runtime SONAME: `libmplapack_mpfr.so.3`
- MPFR: `libmpfr.so.6`
- MPC: `libmpc.so.3`
- GMP: `libgmp.so.10`
- Source-tree dependency: none; installed headers/libraries through pkg-config
- Result: pending final RC QA

## Archive

- Canonical filename: `mplapack-0.1.0.tar.gz`
- Top-level directory: `mplapack-0.1.0/`
- Source commit: `TBD`
- Size: `TBD bytes`
- SHA256: `TBD`
- Second-build SHA256: `TBD`
- Hashes identical: pending final RC QA
- Contents audit: pending final RC QA
- Build products excluded: pending final RC QA
- Private files excluded: pending final RC QA
- Result: pending final RC QA

## Reproducibility

### Build A

- Fresh directory: pending final RC QA
- Archive: `mplapack-0.1.0.tar.gz`
- SHA256: `TBD`

### Build B

- Fresh directory: pending final RC QA
- Archive: `mplapack-0.1.0.tar.gz`
- SHA256: `TBD`

- File lists identical: pending final RC QA
- Metadata identical: pending final RC QA
- Result: pending final RC QA

## Fresh-clone QA

- Clone/check-out commit: `TBD`
- Dependency probe: pending final RC QA
- Native build: pending final RC QA
- Public smoke: pending final RC QA
- Package build: pending final RC QA
- Result: pending final RC QA

## Extracted archive lifecycle

- Extraction: pending final RC QA
- Package build: pending final RC QA
- Install: pending final RC QA
- Installed version: `0.1.0` (pending final QA)
- Fresh mpbits(): `512` (pending final QA)
- pkg load: pending final RC QA
- Public smoke: pending final RC QA
- Help: pending final RC QA
- Examples: pending final RC QA
- pkg unload: pending final RC QA
- Uninstall: pending final RC QA
- Reinstall: pending final RC QA
- Second smoke: pending final RC QA
- Result: pending final RC QA

## Numerical / regression QA

- tools/local-ci.sh: pending final RC QA
- M00-M22 regression: pending final RC QA
- M20 complex probe: pending final RC QA
- 1024/2048 precision regression: pending final RC QA
- rank precision canary: pending final RC QA
- Cholesky precision canary: pending final RC QA
- QR precision canary: pending final RC QA
- LU pivot precision canary: pending final RC QA
- Compatibility firewall: pending final RC QA
- ASan: pending final RC QA
- UBSan: pending final RC QA
- LSan: pending final RC QA
- git diff --check: pending final RC QA
- Result: pending final RC QA

## Runtime linkage

- Built .oct: `src/__mplapack_core__.oct`
- ldd: pending final RC QA
- ldd -r: pending final RC QA
- Runtime SONAME: `libmplapack_mpfr.so.3`
- RPATH: no development prefix expected
- RUNPATH: no development prefix expected
- Development path leak: pending final audit
- Result: pending final RC QA

## Documentation

- README: final release-candidate text
- NEWS: final `0.1.0` section
- v0.1 API: frozen
- compatibility: tested Octave 11.1.0 and intentional differences recorded
- release checklist: M23 subset marked from evidence
- release manifest: this handoff file
- PPA plan: consistent with RC handoff
- Limitations consistent: pending final search
- False PPA availability claim: none
- Result: pending final RC QA

## Release manifest

- File: `docs/v0.1-release-manifest.md`
- Upstream version: `0.1.0`
- Upstream commit: `TBD`
- Archive: `mplapack-0.1.0.tar.gz`
- SHA256: `TBD`
- Octave minimum: `11.1.0`
- Ubuntu initial target: `Ubuntu 26.04`
- MPLAPACK requirement: feature probe plus uniform-precision scope
- Complex status: public complex unsupported; probe-only audit retained
- PPA status: handoff ready; PPA not published
- Complete: pending final RC QA

## PPA handoff

- PPA1 input commit: `TBD` (V0.1.0_RC_COMMIT)
- PPA1 upstream archive: `mplapack-0.1.0.tar.gz`
- PPA1 archive SHA256: `TBD`
- PPA2 upstream source: `V0.1.0_RC_COMMIT`
- Ubuntu target: `Ubuntu 26.04`, initial deep validation on amd64
- Complex blocks PPA: no (`REAL-PPA-GO`)
- Remaining packaging-policy work: PPA1--PPA4 Debian/Launchpad policy and build QA
- Result: pending final RC QA

## Gates

- G23-SOURCE-FREEZE: pending
- G23-VERSION: pending
- G23-REPRODUCIBLE: pending
- G23-ARCHIVE: pending
- G23-QA: pending
- G23-PACKAGE: pending
- G23-LINKAGE: pending
- G23-DOCS: pending
- G23-PPA-HANDOFF: pending

M23 PASS / FAIL

Release conclusion:

V0.1.0-RC-FROZEN / NOT-FROZEN

## Code changes

Pending final RC evidence.

## Files changed

Pending final RC evidence; pre-existing legacy report deletions remain excluded.

## Commits

Pending final RC evidence.

## Push

- Push: pending
- Remote tip: pending
- Local tip: pending
- GitHub CI: pending

## Known v0.1 limitations

Dense real only; complex, sparse, N-D, matrix `char`, growth/deletion and
logical assignment, broad vector-linear indexing, comparisons, reductions,
transcendentals, `det`, `inv`, `rank`, `cond`, `norm`, `eig`, `svd`, QR/LU
update families, `qr(A,B)`, sparse factorization forms, and automatic SPD
solve optimization remain unsupported.

## Remaining work before public release

- PPA1 MPLAPACK Debian packaging
- PPA2 octave-mplapack Debian packaging
- PPA3 Launchpad staging QA
- PPA4 public PPA / final release
- other packaging issues: Debian naming, symbols/shlibs, and multi-series policy

## Recommended next action

If M23 PASS — V0.1.0-RC-FROZEN:

Review and merge M23.

Proceed to PPA1 using exactly:

    V0.1.0_RC_COMMIT
    release archive
    recorded SHA256

PPA1 must package the required MPLAPACK MPFR dependency first.

Do not add new upstream numerical features.

Do not begin complex C00.

Do not create the final v0.1.0 Git tag until the release process reaches
the designated final release gate.

Otherwise:

State the exact release-freeze blocker and stop.

Branch: topic/m23-v0.1-freeze
Starting commit: d697e6969c393b4f68c6570c0a56d21018cd7cee
Final commit: TBD
Files changed: release metadata/docs/QA only; legacy report deletions excluded
Commands run: pending final RC QA
Tests: pending final RC QA
Gate: pending final RC QA
Known limitations: documented above and in docs/v0.1-api.md
