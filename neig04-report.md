# NEIG04 report

Task and milestone: NEIG — difficult nonsymmetric eigensystems; NEIG04 Frank constructor and independent reference path.

Branch: `main`

Starting commit: `3148dd5f14a111c10f8347d22776097bfe5ef2a0`

Validated implementation commit or uncommitted state: implementation and focused tests are present in the working tree; this report is written before the milestone commit.

Files created/modified:

- `examples/nonsymmetric_eig/private/nes_frank_characteristic_coefficients.m`
- `examples/nonsymmetric_eig/private/nes_exact_small_determinant.m`
- `examples/nonsymmetric_eig/private/nes_frank_run.m`
- `examples/nonsymmetric_eig/private/nes_build.m`
- `examples/nonsymmetric_eig/private/nes_reference.m`
- `examples/nonsymmetric_eig/private/nes_cases.m`
- `examples/nonsymmetric_eig/mp_eig_suite.m`
- `examples/nonsymmetric_eig/mp_eig_suite_selftest.m`
- `test/test_nonsymmetric_eig_suite.m`
- `neig04-report.md`

Environment and executable/module resolution:

- GNU Octave 11.1.0 from `/usr/bin/octave`, through `tools/dev-octave.sh`.
- MPLAPACK 3.0.1 MPFR/MPC stack from `/home/docker/opt/octave-mplapack-stack`, selected through `PKG_CONFIG_PATH`, `CPATH`, and `LD_LIBRARY_PATH`.
- The Frank reference uses the package's public real symmetric `eig` path on a separately rebuilt Jacobi/Hermite tridiagonal matrix.  The general Frank matrix is sent to the general eigensolver only in the experiment rows.

Commands run:

```text
PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/dev-octave.sh --eval 'run ("test/test_nonsymmetric_eig_suite.m");'

PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/dev-octave.sh --eval '<Frank smoke/demo summary>'

git diff --check
```

Tests and numerical results:

- Exact Frank orientation: PASS.  The n=5 constructor matched the prescribed matrix exactly:
  `[[5,4,3,2,1]; [4,4,3,2,1]; [0,3,3,2,1]; [0,0,2,2,1]; [0,0,0,1,1]]`.
- Independent characteristic recurrence: PASS for n=2..5.  The exact descending coefficient fixtures matched `[1,-3,1]`, `[1,-6,6,-1]`, `[1,-10,21,-10,1]`, and `[1,-15,55,-55,15,-1]`.
- Independent determinant check: PASS at several exact integer evaluation points for n=2..5 using an MP Leibniz expansion of `det(xI-F)`.  No `poly(eig(F))` check was used.
- Hermite/Jacobi reference: PASS for even n=8 and odd n=7.  The tridiagonal entries were built with one MP square-root value assigned symmetrically to both off-diagonal positions.  The cancellation-safe negative-z branch was exercised by the negative half of the symmetric spectrum.
- Reference consistency: PASS.  For Frank(8), the 512-bit and 640-bit constructions agreed with a relative bottleneck of approximately `9.95e-154`, below the declared `2^-256` consistency limit.
- Reference properties: PASS.  The reference eigenvalues were finite, positive, reciprocal-paired, and the odd-order central value was 1 within the 640-bit test tolerance.
- Frank smoke: 6 rows, both balance modes, native/128-bit/256-bit MP; `results.ok=true`.  MP relative bottleneck log2 values were approximately `-111.94` (128 bits) and `-243.73` (256 bits).  The p=256 target `2^-120` passed in both modes.
- Frank demo: 8 rows, both balance modes, native/128/256/512-bit MP; `results.ok=true`.  MP relative bottleneck log2 values were approximately `-40.94/-43.62` at 128 bits, `-167.18/-171.59` at 256 bits, and `-423.40/-425.17` at 512 bits for balance/nobalance.  The p=512 target `2^-200` passed in both modes.
- Actual Frank solver outputs were matched and measured; the Hermite reference was not substituted for solver eigenvalues.

Gate: PASS

Known limitations:

- Frank reference computations share the package's scalar MP arithmetic and symmetric eigensolver/backend; they are a structured independent path, not a completely independent numerical library.
- Full all-family dispatch, output files, and the remaining companion/Forsythe families are deferred.
- `test_nonsymmetric_eig_suite.m` currently remains a focused test command rather than part of `test/run_tests.m`; integration is deferred to NEIG08.

Next milestone or minimal blocker reproducer: proceed to NEIG05.

