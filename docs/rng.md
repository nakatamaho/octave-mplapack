# Arbitrary-precision random generation

The package exposes `mprand`, `mprandn`, `mprandi`, and `mprng`.  These are
numerical pseudo-random generators, not cryptographic random sources, and do
not replace Octave's builtin `rand`/`randn` state.

## Engine and state

The engine identifier is `xorshift128plus-v1`.  Its state is two unsigned
64-bit words and its transition is the explicitly specified xorshift128+
transition:

```text
x = s0; y = s1
s0 = y
x = x xor (x << 23)
s1 = x xor y xor (x >> 17) xor (y >> 26)
output = s1 + y
```

All operations are modulo 2^64.  A seed is expanded into the two-word state
with the fixed SplitMix64 expansion used by the native implementation.  The
all-zero state is rejected.  The public state schema is:

```octave
struct ("algorithm", "xorshift128plus-v1", ...
        "version", uint64 (1), ...
        "state", uint64 ([s0, s1]))
```

`mprng("state")` reads the state, `mprng("state", s)` restores a validated
state, `mprng("seed", seed)` selects a deterministic seed, and
`mprng("reset")` selects seed zero.  The state is ordinary serializable
Octave data, so T07 save/load can persist it without embedding native
addresses or implementation-specific object data.

## Distribution contracts

`mprand` consumes raw engine words to form a p-bit integer `k` and returns the
exact MPFR value `k / 2^p`.  Therefore the endpoint is `[0,1)`, zero is
allowed, one is impossible, and no binary64 value is used in generation.
The output precision is the current `mpbits()` default at the operation
boundary.

`mprandi` uses rejection sampling for the inclusive integer interval
`[imin, imax]`; it never uses biased modulo reduction.  Bounds are finite
exact integer `mp` scalars (ordinary integer scalars are converted to `mp` at
the current default precision), and results are exact MPFR integers.  The
supported dimension forms are scalar, one dimension, a two-element dimension
vector, or two dimensions as documented by the function help.

`mprandn` uses the Box–Muller transform.  Uniform samples, logarithm, square
root, π, trigonometric evaluation, and the result are all computed with MPFR
at the operation precision.  A zero first uniform sample is discarded and a
new raw sample is consumed.  No builtin `randn` or floating distribution is
used.

The implementation defines deterministic numerical sequences, not a security
property.  The fixed-seed sequence is tested in `test/t09_random.tst`; broad
mean/second-moment and small-range frequency checks are sanity checks only.
