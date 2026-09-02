# M23 RESULT

Repository: `nakatamaho/octave-mplapack`
Remote: `origin` (`https://github.com/nakatamaho/octave-mplapack.git`)
Branch: `topic/m23-v0.1-freeze`
Starting commit: `d697e6969c393b4f68c6570c0a56d21018cd7cee`
V0.1.0_RC_COMMIT: `0bef79cddd3fdd70abafdf38bc1a4ab492652d33`
M23 report commit: `c53e4bf54a76a124741973f48c8dc99cd29f3b75`
Branch tip: `c53e4bf54a76a124741973f48c8dc99cd29f3b75` before the final report-only metadata follow-up
PR: `#24`

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
- Compatibility firewall: passed; unsupported matrix operations fail cleanly without double fallback
- Result: PASS; no numerical feature or production implementation change

## Version

- DESCRIPTION Name: `mplapack`
- Repository name: `octave-mplapack`
- Version before: `0.1.0-dev`
- Version after: `0.1.0`
- Minimum Octave: `11.1.0`
- NEWS: final `0.1.0` section
- README: release-candidate status and PPA handoff
- Stale 0.1.0-dev references: none in user-facing release metadata; historical wording classified
- Result: PASS

## Release candidate identity

- V0.1.0_RC_COMMIT: `0bef79cddd3fdd70abafdf38bc1a4ab492652d33`
- Commit tree: metadata/docs/QA only; no numerical source changes
- Source freeze clean: PASS for the candidate; five unrelated legacy report deletions remain unstaged and excluded
- Subsequent source-changing commits: none permitted after RC
- Report-only commit: `c53e4bf54a76a124741973f48c8dc99cd29f3b75` (final metadata follow-up is recorded after this report)
- Result: PASS; the report/manifest follow-up is metadata-only

## MPLAPACK dependency

- Validated source commit: `1cf03d1a1aa2afecde5f1840fbe9663ecfc31e57`
- pkg-config: `mplapack_mpfr`
- pkg-config version: `3.0.1`
- Required header: `mplapack_mpfr_precision.h`
- Required interface: `MplapackMpfrPrecisionScope`
- Dependency probe: PASS (`make -C src check-dependency`)
- Runtime SONAME: `libmplapack_mpfr.so.3`
- MPFR: `libmpfr.so.6`
- MPC: `libmpc.so.3`
- GMP: `libgmp.so.10`
- Source-tree dependency: none; installed headers/libraries through pkg-config
- Result: PASS

## Archive

- Canonical filename: `mplapack-0.1.0.tar.gz`
- Top-level directory: `mplapack-0.1.0/`
- Source commit: `0bef79cddd3fdd70abafdf38bc1a4ab492652d33`
- Size: `161819 bytes`
- SHA256: `35d004adf831c79fe470ff890ce3698dfe7e6f624ea31c174b1d60a03d110db6`
- Second-build SHA256: `35d004adf831c79fe470ff890ce3698dfe7e6f624ea31c174b1d60a03d110db6`
- Hashes identical: PASS
- Contents audit: PASS; one `mplapack-0.1.0/` top-level directory and 195 entries
- Build products excluded: PASS (`.o`, `.oct`, `.libs`, `.deps`, `dist`, and build caches excluded)
- Private files excluded: PASS; root reports and handoff manifest intentionally excluded
- Result: PASS

## Reproducibility

### Build A

- Fresh directory: independent temporary checkout A created by `tools/verify-release-candidate.sh`
- Archive: `mplapack-0.1.0.tar.gz`
- SHA256: `35d004adf831c79fe470ff890ce3698dfe7e6f624ea31c174b1d60a03d110db6`

### Build B

- Fresh directory: independent temporary checkout B created by `tools/verify-release-candidate.sh`
- Archive: `mplapack-0.1.0.tar.gz`
- SHA256: `35d004adf831c79fe470ff890ce3698dfe7e6f624ea31c174b1d60a03d110db6`

- File lists identical: PASS
- Metadata identical: PASS (`SOURCE_DATE_EPOCH=0`, normalized tar/gzip metadata)
- Result: PASS

## Fresh-clone QA

- Clone/check-out commit: `0bef79cddd3fdd70abafdf38bc1a4ab492652d33`
- Dependency probe: PASS
- Native build: PASS
- Public smoke: PASS
- Package build: PASS
- Result: PASS; independent `git clone --no-local` validation

## Extracted archive lifecycle

- Extraction: PASS
- Package build: PASS
- Install: PASS
- Installed version: `0.1.0`
- Fresh mpbits(): `512`
- pkg load: PASS
- Public smoke: PASS
- Help: PASS (`help @mp/lu`)
- Examples: PASS through package lifecycle smoke
- pkg unload: PASS
- Uninstall: PASS
- Reinstall: PASS
- Second smoke: PASS
- Result: PASS

## Numerical / regression QA

- tools/local-ci.sh: PASS
- M00-M22 regression: PASS
- M20 complex probe: PASS
- 1024/2048 precision regression: PASS
- rank precision canary: PASS
- Cholesky precision canary: PASS
- QR precision canary: PASS
- LU pivot precision canary: PASS
- Compatibility firewall: PASS
- ASan: PASS
- UBSan: PASS
- LSan: PASS
- git diff --check: PASS
- Result: PASS

## Runtime linkage

- Built .oct: `src/__mplapack_core__.oct`
- ldd: PASS; `libmplapack_mpfr.so.3`, MPC, MPFR, GMP, Octave/runtime libraries resolved
- ldd -r: PASS; no missing libraries or unresolved non-host symbols
- Runtime SONAME: `libmplapack_mpfr.so.3`
- RPATH: no development prefix expected
- RUNPATH: no development prefix expected
- Development path leak: none in committed build/package configuration or release `.oct` RPATH/RUNPATH
- Result: PASS

## Documentation

- README: final release-candidate text
- NEWS: final `0.1.0` section
- v0.1 API: frozen
- compatibility: tested Octave 11.1.0 and intentional differences recorded
- release checklist: M23 subset marked from evidence
- release manifest: this handoff file
- PPA plan: consistent with RC handoff
- Limitations consistent: PASS across README, NEWS, API, compatibility, manifest, and PPA plan
- False PPA availability claim: none
- Result: PASS

## Release manifest

- File: `docs/v0.1-release-manifest.md`
- Upstream version: `0.1.0`
- Upstream commit: `0bef79cddd3fdd70abafdf38bc1a4ab492652d33`
- Archive: `mplapack-0.1.0.tar.gz`
- SHA256: `35d004adf831c79fe470ff890ce3698dfe7e6f624ea31c174b1d60a03d110db6`
- Octave minimum: `11.1.0`
- Ubuntu initial target: `Ubuntu 26.04`
- MPLAPACK requirement: feature probe plus uniform-precision scope
- Complex status: public complex unsupported; probe-only audit retained
- PPA status: handoff ready; PPA not published
- Complete: PASS

## PPA handoff

- PPA1 input commit: `0bef79cddd3fdd70abafdf38bc1a4ab492652d33` (V0.1.0_RC_COMMIT)
- PPA1 upstream archive: `mplapack-0.1.0.tar.gz`
- PPA1 archive SHA256: `35d004adf831c79fe470ff890ce3698dfe7e6f624ea31c174b1d60a03d110db6`
- PPA2 upstream source: `V0.1.0_RC_COMMIT`
- Ubuntu target: `Ubuntu 26.04`, initial deep validation on amd64
- Complex blocks PPA: no (`REAL-PPA-GO`)
- Remaining packaging-policy work: PPA1--PPA4 Debian/Launchpad policy and build QA
- Result: PASS; remaining work is packaging policy/build execution only

## Gates

- G23-SOURCE-FREEZE: PASS
- G23-VERSION: PASS
- G23-REPRODUCIBLE: PASS
- G23-ARCHIVE: PASS
- G23-QA: PASS
- G23-PACKAGE: PASS
- G23-LINKAGE: PASS
- G23-DOCS: PASS
- G23-PPA-HANDOFF: PASS

M23 PASS — V0.1.0-RC-FROZEN

Release conclusion:

V0.1.0-RC-FROZEN

## Code changes

No numerical source changes. `DESCRIPTION` is frozen at `0.1.0`; release
documentation, dependency probing, reproducibility verification, and package
lifecycle QA were completed.

## Files changed

The release metadata/docs/QA changes listed in the RC commit and this
metadata-only report follow-up are included. Five pre-existing legacy report
deletions remain unstaged and excluded.

## Commits

- `815bd362966f9464c402f94f0ae67217c7696330` M23: freeze v0.1.0 release candidate metadata
- `0bef79cddd3fdd70abafdf38bc1a4ab492652d33` M23: fix standalone archive documentation links
- `c53e4bf54a76a124741973f48c8dc99cd29f3b75` M23 report/manifest metadata follow-up

## Push

- Push: PASS; branch pushed and PR #24 opened
- Remote tip: `c53e4bf54a76a124741973f48c8dc99cd29f3b75` (before final report-only metadata follow-up)
- Local tip: `c53e4bf54a76a124741973f48c8dc99cd29f3b75` (before final report-only metadata follow-up)
- GitHub CI: pending/PR #24 checks

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
Final commit: `c53e4bf54a76a124741973f48c8dc99cd29f3b75` report evidence commit; final branch tip is the subsequent report-only metadata commit
Files changed: release metadata/docs/QA only; legacy report deletions excluded
Commands run: `tools/check-tree.sh`; `tools/check-format.sh`; `git diff --check`; `tools/verify-release-candidate.sh 0bef79cddd3fdd70abafdf38bc1a4ab492652d33`; `tools/local-ci.sh`; independent fresh-clone and extracted-archive lifecycle QA; linkage audit
Tests: M00-M22 regression, M20 complex probe, dependency probe, package reproducibility, install/lifecycle, compatibility firewall, ASan, UBSan, LSan
Gate: G23-SOURCE-FREEZE/VERSION/REPRODUCIBLE/ARCHIVE/QA/PACKAGE/LINKAGE/DOCS/PPA-HANDOFF all PASS
Known limitations: documented above and in docs/v0.1-api.md
