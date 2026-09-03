# v0.1 release checklist

M22 prepares this checklist; M23 executes the freeze and release-candidate
subset. No tag, GitHub release, or PPA upload is made by M22.

- [ ] Set and audit the authoritative version (`0.1.0` target).
- [ ] Complete `DESCRIPTION`, `NEWS.md`, `README.md`, license, and API/help text.
- [ ] Verify the MPLAPACK feature probe, `pkg-config`, and runtime linkage.
- [ ] Build from a clean checkout with no source-tree/private dependency paths.
- [ ] Build and inspect a clean source/package archive.
- [ ] Install, load, smoke-test, unload, uninstall, reinstall, and smoke-test again.
- [ ] Run every shipped example and installed help audit.
- [ ] Run full local CI, ASan, UBSan, LSan, and the M00-M21 regression suite.
- [ ] Check archive contents, source checksums, generated-artifact policy, and no private reports.
- [ ] Review the Ubuntu 26.04/amd64 PPA handoff and MPLAPACK Debian package boundary.
- [ ] Create the release tag/source archive only after M23 passes.
- [ ] Build the PPA source package, Launchpad staging build, and `apt` install smoke test.
