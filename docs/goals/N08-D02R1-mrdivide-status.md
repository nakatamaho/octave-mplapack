# N08 / D02R1 status

Updated: 2026-09-08

## Current state

N08 implementation is complete on `topic/n08-mrdivide`; D02R1 release QA is
complete on `topic/d02r1-0.3.1-release-freeze`.

```text
N08 PASS — DENSE REAL+COMPLEX MRDIVIDE COMPLETE
```

The release candidate version is `0.3.1`.  The historical `v0.3.0` release
remains immutable.  The final release tag is deliberately created only after
the final archive hash and tag-tree verification below are complete.

## N08 source identity

```text
base:          9b0be1dd8e...  (D02 v0.3.0 freeze)
implementation: 5a4f2fd       Implement dense real and complex mrdivide
test hardening: 05a2636       Harden mrdivide regression expectations
final N08:      2ec10d506e609aca4c3e5ef4c5039a3683c5442c
branch:        topic/n08-mrdivide
remote:        origin/topic/n08-mrdivide
```

## N08 contract covered

- dense real and complex `A / B` and `mrdivide (A, B)`;
- scalar denominator native element-wise division;
- square `Rgesv`/`Cgesv` and rectangular/rank-revealing paths;
- singular square fallback to the minimum-norm rank-revealing path;
- mixed real/complex operands;
- empty shapes, special values, input immutability, and Grcar residual;
- 1024-bit and 2048-bit precision canaries with low ambient precision;
- no builtin binary64 complex fallback and no real-operation rerouting.

## N08 gates

```text
N08 implementation/build: PASS
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex LU: PASS
N00-N07 regression: PASS
N08 mrdivide regression: PASS
ASan/UBSan/LSan native wall: PASS
local-ci.sh: PASS
source archive reproducibility in local-ci: PASS
clean extracted package lifecycle: PASS
```

The standard CI was run with the frozen MPLAPACK prefix explicitly selected:

```text
PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:...
CPATH=/home/docker/opt/octave-mplapack-stack/include
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:...
```

An initial CI invocation without that environment selected an unrelated
`/usr/local` MPLAPACK installation and was rejected by the precision-header
provenance check.  It is not a source failure.

The N08 test reference values avoid host Octave complex matrix `/`, `\\`, and
`inv` calls.  On this host those calls could enter an OpenBLAS `ctrmm` path and
segfault after the preceding test wall.  The test now uses independent scalar
complex formulas, while the MPLAPACK `mp` right-division operations remain the
calls under test.

## D02R1 QA state

```text
D02R1-G source/version freeze: PASS
D02R1-S frozen three-archive rebuild: PASS
D02R1-R source archive reproducibility: PASS
D02R1-Q full regression, sanitizer, provenance, lifecycle: PASS
D02R1-T release tag: pending final candidate archive verification
```

The final candidate stack was rebuilt from the exact gmpfrxx and MPLAPACK
archives recorded in the D02R1 report.  The clean archive-only Octave build
passed M00-M23, C00-C12, mandatory C11L, and N00-N08, including the 1024-bit /
2^-700 and 2048-bit / 2^-1500 canaries.  The isolated package lifecycle and
the installed MPLAPACK external consumers also passed.

The next action is the release-engineering tag verification and final report.
No D01, binary, Debian, PPA, Launchpad, or registry work is started here.
