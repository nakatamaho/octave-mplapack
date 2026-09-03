# C12 complex release-closure checklist

This checklist records the development closure for C00–C12. It does not
freeze MPLAPACK 3.0.1 or begin D00, Debian, PPA, or Launchpad work.

- [x] `G-C12-API`: supported complex API inventory and constructor grammar
      recorded in `complex-api.md`.
- [x] `G-C12-DOCS`: API, compatibility, backend, and release-closure docs
      agree with the tested implementation.
- [x] `G-C12-FIREWALL`: complex unsupported functions reject cleanly with no
      binary64 fallback, crash, or recursion.
- [x] `G-C12-REAL-REGRESSION`: complete M01–M23 public and native real wall.
- [x] `G-C12-COMPLEX-REGRESSION`: complete C01–C11L public and native wall.
- [x] `G-C12-PRECISION`: 1024/2048-bit tails, source-precision pivots,
      mixed promotion, and all earlier real canaries.
- [x] `G-C12-TLS`: low/high ambient precision, thread-local scope, and
      lifetime probes.
- [x] `G-C12-SANITIZERS`: ASan/UBSan/LSan native gates.
- [x] `G-C12-PACKAGE-LIFECYCLE`: source archive build, install/load,
      unload, reinstall, and real+complex smoke.
- [x] `G-C12-UPSTREAM-PROVENANCE`: exact tested dependency commits and the
      required MPLAPACK precision-scope-header fix recorded.

## Development identity

- package version: `0.2.0-dev`;
- MPLAPACK pkg-config identity: `mplapack_mpfr 3.0.1`;
- final release commit/tag/archive: not frozen here;
- Debian package, Launchpad upload, and PPA work: not started;
- next separate goal: `D00 — Dependency Release Freeze`.
