# C00 report

Branch: `topic/complex-c00-c12`

Starting commit: `4aed479ef9cb8dff24f0326e1c2ec2a7c1ed83a3`

Final commit: pending

Files changed: complex scalar/matrix storage, native payload types, composed
MPFR/MPC precision scope, C00 probe, build wiring, development version, and
C00 documentation/status.

Commands run: `make -C src check-deps`; direct C++ compile; `make -C src
check-complex-storage`; module build with the controlled shared MPLAPACK
prefix.

Tests: C00 storage/scope/TLS/lifetime/special-value probe PASS at 128, 256,
512, 1024, and 2048 bits under ASan/UBSan/LSan. Real regression wall pending.

Gate: pending real regression wall.

Known limitations: public complex behavior is intentionally deferred to C01
and later.

Branch:
Starting commit:
Final commit:
Files changed:
Commands run:
Tests:
Gate:
Known limitations:
