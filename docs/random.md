# Arbitrary-precision random generation

The closed random-generation API is documented in
[`rng.md`](rng.md): `mprand`, `mprandn`, `mprandi`, and `mprng`. It uses the
fixed native `xorshift128plus-v1` engine, exact MPFR generation, and a
versioned state schema. It is separate from Octave's builtin `rand` and
`randn` state.

The implementation is deterministic for a fixed state and precision, but it
is not a cryptographic source. No random numerical path uses builtin binary64
generation.
