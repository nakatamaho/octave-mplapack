# NEIG06 report

Task and milestone: NEIG — difficult nonsymmetric eigensystems; NEIG06 Forsythe scaled control and high-precision reference.

Branch: `main`

Starting commit: `7891c3c1127f06c7ea5859687ca06469a37f3216`

Validated implementation commit or uncommitted state: implementation and focused tests are present in the working tree; this report is written before the milestone commit.

## Scope

NEIG06 adds the fourth required family, the Forsythe scaled control.  It provides two mathematically related input representations:

- `original`: `I + N + 2^(-a*n) e_n e_1^T`, with unit superdiagonal in `N`;
- `explicitly_scaled`: `I + 2^(-a) P`, where `P` is the cyclic shift.

The diagonal similarity relation is constructed and tested as

```text
original_A * scaling = scaling * scaled_A
```

with `scaling = diag(1, 2^(-a), ..., 2^(-(n-1)*a))`.  Both representations therefore have the same exact spectrum, while the explicitly scaled form makes the small cyclic coupling visible to a native-double control.  The MP path constructs both forms at the requested working precision and never routes an MP input through binary64.

Files created/modified:

- `examples/nonsymmetric_eig/private/nes_forsythe_run.m`
- `examples/nonsymmetric_eig/private/nes_build.m`
- `examples/nonsymmetric_eig/private/nes_reference.m`
- `examples/nonsymmetric_eig/private/nes_cases.m`
- `examples/nonsymmetric_eig/mp_eig_suite.m`
- `examples/nonsymmetric_eig/mp_eig_suite_selftest.m`
- `test/test_nonsymmetric_eig_suite.m`
- `neig06-report.md`

## Reference and precision contract

For `r = 2^(-a)`, the exact eigenvalues are `1 + r*exp(2*pi*i*k/n)`.  The reference path evaluates the unit roots with MP `acos`, `sin`, and `cos`, forms the complex MP values from MP real and imaginary strings, and checks low/high reference agreement with a deterministic bottleneck match.  Even-order real endpoints and odd-order conjugate pairing are tested explicitly.

The constructor preserves and restores the ambient `mpbits()` setting.  The n=20, a=80 stress constructor produces a nonzero MP `2^-1600` coupling at 2048 bits while classifying the corresponding native-double value as underflow.  This is recorded as input representation metadata and is not used as an MP fallback.

## Environment and commands

- GNU Octave 11.1.0 from `/usr/bin/octave`, through `tools/dev-octave.sh`.
- MPLAPACK 3.0.1 MPFR/MPC stack from `/home/docker/opt/octave-mplapack-stack`, selected through `PKG_CONFIG_PATH`, `CPATH`, and `LD_LIBRARY_PATH`.
- Source implementation files were placed on the Octave path by `tools/dev-octave.sh`; no installed package copy was used for the changed example code.

Commands run:

```text
PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/dev-octave.sh --eval 'addpath ("examples/nonsymmetric_eig"); mp_eig_suite_selftest (); ...'

PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/dev-octave.sh --eval 'run ("test/test_nonsymmetric_eig_suite.m");'

git diff --check
```

The first command included the Forsythe smoke and demo suite and asserted that the ambient precision was restored.  The second command reran the complete focused Hadamard, Frank, companion, and Forsythe test entry point.

## Tests and numerical results

- Constructor exactness: PASS.  For n=8, a=4, MP `epsilon` equals `2^-32`, MP radius equals `2^-4`, and both representations are finite.
- Similarity relation: PASS.  The MP Frobenius norm of `original_A*scaling - scaling*scaled_A` was exactly zero.
- Structural control: PASS.  The original n=8 matrix is nonnormal; the explicitly scaled cyclic-shift matrix is normal to exact MP zero in the tested construction.
- Reference properties: PASS.  n=8 and n=7 references were finite, unit-circle roots had modulus one within the high-precision check, even endpoints were checked directly, and odd-order conjugate pairing was checked.
- Reference consistency: PASS.  The 512-bit and 640-bit Forsythe references were classified `evaluated_consistent`.
- Precision canary: PASS.  The 2048-bit n=20, a=80 original construction retained nonzero `2^-1600` MP coupling; the native construction classified that coupling as underflow.  The 2048-bit explicitly scaled matrix retained its `2^-80` MP cyclic coefficient.
- Forsythe smoke: PASS.  12 rows (two representations × two modes × native/128/256-bit MP).  At 256 bits, circle-error logs were approximately `-230.2` for `original` and `-249.1` for `explicitly_scaled` in both modes; the `2^-120` target passed.
- Forsythe demo: PASS.  16 rows (two representations × two modes × native/128/256/512-bit MP).  At 512 bits, circle-error logs were approximately `-176.1` for `original` and `-487.6` for `explicitly_scaled` in both modes.  The `2^-64` original target and `2^-200` explicitly scaled target passed.
- Residuals: PASS.  At the 512-bit demo rows, normalized global right residual logs were approximately `-509.7` for the original form and `-509.8` for the explicitly scaled form.
- Existing focused regression: PASS.  `test/test_nonsymmetric_eig_suite.m` passed after adding the Forsythe smoke/demo checks.

## Gate

NEIG06 gate: **PASS**

## Known limitations

- The native-double Forsythe rows are an explicit rounded-input control.  They demonstrate the representation/underflow boundary and are not used to claim MP accuracy.
- Output serialization, all-family dispatch, the 30-row smoke / 40-row demo wall, plots, documentation integration, and clean-package example QA are deferred to NEIG07–NEIG08.

Next milestone: proceed to NEIG07.
