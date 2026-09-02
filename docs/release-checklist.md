# v0.1.0 release checklist

M23 executes the upstream freeze and release-candidate subset. PPA1--PPA4 and
the final tag remain subsequent release steps.

- [x] Set and audit the authoritative version (`0.1.0`).
- [x] Complete `DESCRIPTION`, `NEWS.md`, `README.md`, license, and API/help text.
- [x] Verify the MPLAPACK feature probe, `pkg-config`, and runtime linkage.
- [x] Build from a clean checkout with no source-tree/private dependency paths.
- [x] Build and inspect two identical clean source/package archives.
- [x] Install, load, smoke-test, unload, uninstall, reinstall, and smoke-test again.
- [x] Run every shipped example and installed help audit.
- [x] Run full local CI, ASan, UBSan, LSan, and the M00-M22 regression suite.
- [x] Check archive contents, source checksums, generated-artifact policy, and no private reports.
- [x] Review the Ubuntu 26.04/amd64 PPA handoff and MPLAPACK Debian package boundary.
- [ ] Create the final release tag/source archive after the PPA release gate.
- [ ] Build the PPA source package, Launchpad staging build, and `apt` install smoke test.
