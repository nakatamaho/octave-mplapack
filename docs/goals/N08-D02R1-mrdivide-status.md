# N08 / D02R1 status

Updated: 2026-09-08

## Final state

N08 and D02R1 are complete on `topic/d02r1-0.3.1-release-freeze`.

```text
N08 PASS — DENSE REAL+COMPLEX MRDIVIDE COMPLETE
D02R1 PASS — MPLAPACK-INTEROP 0.3.1 SOURCE REFREEZE
```

The immutable release tag is `v0.3.1`, pointing to
`41123b30a03b594aefaa9dec8ac82c8690a128df`. The historical `v0.3.0`
release and real-only checkpoint remain unchanged.

## N08 source identity

```text
implementation: 5a4f2fd       Implement dense real and complex mrdivide
test hardening: 05a2636       Harden mrdivide regression expectations
reference hardening: 2ec10d506e609aca4c3e5ef4c5039a3683c5442c
N08 completion: 05da88ec0cc65febfed063a551e8cfc2fb0863e8
branch: topic/n08-mrdivide
release branch: topic/d02r1-0.3.1-release-freeze
```

Dense real and complex right division covers scalar, square, rectangular,
rank-deficient, mixed, empty, special-value, immutable-input, and Grcar
cases. Square paths use `Rgesv`/`Cgesv`; rectangular and forced
rank-revealing paths use the accepted MPFR/MPC backend paths. Destructive
calls receive operation-owned copies, and no real-only operation is routed
through a complex kernel.

## D02R1 frozen identity

```text
gmpfrxx_mkII 1.4.1: 32a7fb797202cdf92312ed9d133f96fdbcda590a
MPLAPACK 3.0.1: c21a9f56224308afda9e7424ca9928d4cf840f7a
octave-mplapack 0.3.1: 41123b30a03b594aefaa9dec8ac82c8690a128df
tag: v0.3.1
archive SHA256: 21a7c6751a17e783196c0e28e45d521a9251a1e3f2c210f38ab733fc89e0624b
archive size: 306951 bytes
```

The final archive was generated twice from independent clean trees. Both
archives had identical top-level directory, file list, size, and SHA256. A
fresh extraction of that exact archive built and passed the full M00-M23,
C00-C12/C11L, and N00-N08 regression wall, followed by package smoke.

## Gates

```text
G-N08-SCALAR: PASS
G-N08-MATRIX-SCALAR: PASS
G-N08-MATRIX-MATRIX: PASS
G-N08-REAL: PASS
G-N08-COMPLEX: PASS
G-N08-MIXED: PASS
G-N08-SQUARE: PASS
G-N08-RECTANGULAR: PASS
G-N08-RANK-DEFICIENT: PASS
G-N08-MINIMUM-NORM: PASS
G-N08-CONJUGATE-TRANSPOSE: PASS
G-N08-PRECISION: PASS
G-N08-EMPTY: PASS
G-N08-SPECIAL: PASS
G-N08-IMMUTABILITY: PASS
G-N08-OCTAVE: PASS
G-N08-GRCAR-INTEGRATION: PASS
G-N08-REGRESSION: PASS

G-D02R1-SOURCE-FREEZE: PASS
G-D02R1-VERSION: PASS
G-D02R1-REPRODUCIBLE: PASS
G-D02R1-N08: PASS
G-D02R1-FULL-REGRESSION: PASS
G-D02R1-PACKAGE-LIFECYCLE: PASS
G-D02R1-RUNTIME-CLOSURE: PASS
G-D02R1-DOCS: PASS
G-D02R1-TAG: PASS
G-D02R1-BINARY-HANDOFF: PASS

D02R1-G source/version freeze: PASS
D02R1-S frozen three-archive rebuild: PASS
D02R1-R source archive reproducibility: PASS
D02R1-Q regression/sanitizer/provenance/lifecycle: PASS
D02R1-T v0.3.1 tag target and remote verification: PASS
D02R1-H dependency handoff manifest: PASS
```

No D01, binary, Debian, PPA, Launchpad, or registry work has started.
