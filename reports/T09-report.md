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

## Controller metadata

| Field | Value |
|---|---|
| Repository / branch | `octave-mplapack` / `topic/t00-t14-continuation` |
| Starting commit / implementation tip | `89a25a7a8362ccc9d49ffa0dc2ad92e8b677f981` / `1697666a537d67662653d8fd25aec706dc2a315c` |
| D03 baseline | `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31` / `v0.4.0` |
| Dependencies / Octave | gmpfrxx `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1`; MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`; GNU Octave 11.1.0 |
| API / backend | `mprand`, `mprandn`, `mprandi`, `mprng`; xorshift128plus-v1, SplitMix64, MPFR bits, Box–Muller, rejection |
| Precision / behavior | p-bit direct MPFR generation and native scope; real outputs; no double sampling or fallback |
| Octave QA / 1024-2048 | shapes/options, deterministic state, reset/restore, distributions; 1024/2048-bit canaries PASS |
| Sanitizers / previous regression | ASan/UBSan/LSan PASS; T00–T08 and D03 walls retained |
| Status / TODO | PASS; no T09-specific deferred API |
