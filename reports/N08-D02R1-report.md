# N08 / D02R1 report

## N08 result

```text
N08 PASS — DENSE REAL+COMPLEX MRDIVIDE COMPLETE
```

N08 added dense real and complex right division without changing the frozen
real-only checkpoint or routing existing real-only operations through complex
kernels.

## Source identity

| Item | Value |
|---|---|
| Repository | `octave-mplapack` |
| Branch | `topic/n08-mrdivide` |
| D02 base | `9b0be1dd8e...` |
| Implementation commit | `5a4f2fd` |
| Test hardening commit | `05a2636` |
| Final N08 commit | `2ec10d506e609aca4c3e5ef4c5039a3683c5442c` |
| Development version | `0.3.1-dev` |

The final N08 commit is pushed to:

```text
origin/topic/n08-mrdivide
```

The historical real-only checkpoint remains:

```text
REAL_V0_1_RC_COMMIT=0bef79cddd3fdd70abafdf38bc1a4ab492652d33
```

The frozen D02 v0.3.0 release remains unchanged:

```text
tag:    v0.3.0
commit: 392b727...
```

## Implementation summary

- `inst/@mp/mrdivide.m` implements the conjugate-transpose identity
  `A / B = (B' \\ A')'` and dispatches singular square cases to the existing
  rank-revealing minimum-norm path.
- `src/octave_bridge.cc` supports real and complex square, rectangular, mixed,
  and scalar/matrix solve preparation while preserving operation precision.
- Complex square systems use `Cgesv`; rectangular and forced singular fallback
  systems use `Cgelsy`/the accepted rank-revealing path.
- Destructive LAPACK calls receive operation-owned copies; public `mp` values
  remain unchanged.
- No binary64 complex fallback was introduced.

## Test evidence

```text
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex LU: PASS
N00-N07 regression: PASS
N08 mrdivide regression: PASS
1024-bit / 2^-700: PASS
2048-bit / 2^-1500: PASS
ambient precision and restoration: PASS
input immutability: PASS
native ASan/UBSan/LSan wall: PASS
tools/check-format.sh: PASS
tools/check-tree.sh: PASS
tools/local-ci.sh: PASS
```

`tools/local-ci.sh` also passed the clean dependency probes, native linkage
and SONAME checks, package source archive reproducibility checks, clean
extracted installation, unload/uninstall/reinstall lifecycle, and second
smoke wall.  The run used the frozen MPLAPACK 3.0.1 installation under
`/home/docker/opt/octave-mplapack-stack`.

The N08 reference tests do not use host Octave complex matrix right division,
left division, or inverse helpers because this host can crash in its OpenBLAS
`ctrmm` implementation after the earlier regression wall.  Independent scalar
complex formulas are used for reference values; all tested `mp` divisions
still execute the MPLAPACK implementation.

## D02R1 state

```text
D02R1: NOT STARTED
release metadata: 0.3.1-dev
v0.3.0: preserved
v0.3.1: not created
```

The D02R1 freeze must perform only release engineering: version metadata,
final frozen-stack QA, source archive reproducibility, provenance recording,
and the final tag.  It must not add numerical functionality or start D01.
