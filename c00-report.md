# C00 report

Branch: `topic/complex-c00-c12`

Starting commit: `4aed479ef9cb8dff24f0326e1c2ec2a7c1ed83a3`

Final commit: `20815013b1bd90d97451f3773028f0b557d95926`

Files changed: complex scalar/matrix storage, native payload types, composed
MPFR/MPC precision scope, C00 probe, build wiring, development version, and
C00 documentation/status.

Commands run: `make -C src check-deps`; direct C++ compile; `make -C src
check-complex-storage`; module build with the controlled shared MPLAPACK
prefix; full real native test wall; `test/run_tests.m`.

Tests: C00 storage/scope/TLS/lifetime/special-value probe PASS at 128, 256,
512, 1024, and 2048 bits under ASan/UBSan/LSan. Full M00-M23 real native and
public regression wall PASS.

Gate: `C00 PASS` (`G-C00-TYPE`, `G-C00-STORAGE`, `G-C00-PRECISION`,
`G-C00-TLS`, `G-C00-LIFETIME`, `G-C00-SPECIAL`, and
`G-C00-REAL-REGRESSION`).

Known limitations: public complex behavior is intentionally deferred to C01
and later.
