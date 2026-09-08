# T09 report — arbitrary-precision RNG core

## Result

`T09 PASS — ARBITRARY-PRECISION RNG CORE CLOSED`

T09 was implemented on the T08 head
`89a25a7a8362ccc9d49ffa0dc2ad92e8b677f981` on
`topic/t00-t14-continuation` and tested with GNU Octave 11.1.0, the frozen
MPLAPACK MPFR backend, and the existing gmpfrxx_mkII 1.4.1 dependency.

## API and implementation

- `mprand` generates p-bit MPFR values directly from integer engine bits on
  `[0,1)`.
- `mprandn` uses an MPFR-only Box–Muller transform and explicitly handles a
  zero first uniform sample.
- `mprandi` generates inclusive exact integer `mp` values using rejection
  sampling, including signed bounds.
- `mprng` exposes a validated, serializable state/seed/reset API.
- No builtin `rand`, `randn`, `modulo` reduction, binary64 construction, or
  binary64 fallback is used by these paths.

The fixed engine is `xorshift128plus-v1`, with two uint64 state words and a
versioned state schema.  Seed expansion uses a fixed SplitMix64 sequence.
The exact endpoint and state contracts are recorded in `docs/rng.md`.

## Focused QA

`test/t09_random.tst` passed all four tests:

- fixed-seed exact canonical output and repeatability;
- checkpoint/restore continuation and binary save/load of the public state;
- 128-, 512-, 1024-, and 2048-bit output, ambient-precision changes, endpoint
  checks, and a non-binary64 high-precision tail;
- uniform and normal moment sanity checks plus a 6000-sample inclusive
  0..2 integer frequency check.

The fixed seed `uint64(7)` first 128-bit uniform value is
`6.0142955925964410792087642635995321571e-1`.

The focused gate was run as:

```text
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
octave-cli --no-gui --quiet --eval \
  'addpath("inst"); addpath("src"); \
   assert(test("test/t09_random.tst","quiet",stdout));'
```

## Required real-regression wall

The complete `test/run_tests.m` wall passed after T09, covering M00–M23,
C00–C12 including C11L, N00–N08, S00–S08, and T00–T09.  Existing headless
gnuplot warnings remain non-fatal diagnostics from the graphics tests.

Cross-platform sequence execution was not available in this Linux container;
the sequence is specified only in fixed-width unsigned integer operations and
is suitable for independent macOS/Windows confirmation.  No cross-platform
result is claimed here beyond the tested Linux implementation.
