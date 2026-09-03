# C01 report

Branch: `topic/complex-c00-c12`

Starting commit: `b158847`

Final commit: `c9ad222c77be742ecfb30bc39e16548b68bdbb47`

Files changed: complex scalar constructor/conversion dispatch, canonical
complex text, explicit complex-double conversion, `isreal`, and C01 tests and
documentation.

Commands run: controlled-prefix `make -C src`; C01 Octave smoke, precision,
special-value, and round-trip tests.

Tests: builtin complex-double and two-text construction PASS; canonical
round-trip PASS; direct component `double` conversion PASS; 1024/2048-bit
precision checks PASS; real constructor kind preservation PASS. The full
real regression wall is run at milestone completion.

Gate: `C01 PASS` (`G-C01-CONSTRUCT`, `G-C01-DOUBLE`, `G-C01-CHAR`,
`G-C01-DISP`, `G-C01-PRECISION`, `G-C01-SPECIAL`, and
`G-C01-REAL-PARITY`).

Known limitations: dense complex matrix operations and complex arithmetic are
deferred to C02 and later.

Branch:
Starting commit:
Final commit:
Files changed:
Commands run:
Tests:
Gate:
Known limitations:
