# S00-S08 / D03 RESULT

## Result

```text
PASS

Release conclusion:
ORDINARY SCRIPT COMPATIBILITY CLOSED

Binary handoff:
B01-READY
```

D03 freezes the ordinary-script-compatible `mplapack-interop` source as
version `0.4.0`. The tagged source is `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31`;
the annotated tag `v0.4.0` and its remote dereference both point to that
commit. No numerical implementation was changed during D03.

## Initial state

```text
Package Name: mplapack-interop
Initial version: 0.3.1
Initial freeze/tag: 41123b30a03b594aefaa9dec8ac82c8690a128df / v0.3.1
N08 status: PASS — MRDIVIDE API CLOSED
```

The historical `v0.3.1` tag remains unchanged. The earlier `v0.3.0` tag is
also preserved.

## Frozen dependencies

```text
gmpfrxx_mkII:
  version 1.4.1
  commit 32a7fb797202cdf92312ed9d133f96fdbcda590a
  tag v1.4.1
  archive gmpfrxx_mkII.1.4.1.tar.xz
  SHA256 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4

MPLAPACK:
  version 3.0.1
  tested source commit c21a9f56224308afda9e7424ca9928d4cf840f7a
  archive mplapack-3.0.1.tar.xz
  SHA256 f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1
  runtime SONAME libmplapack_mpfr.so.3
```

The MPLAPACK source/archive identity above is the exact D01R1-tested
candidate. The local pre-existing `v3.0.1` tag targets the older
`fa3ccb4376d2a52c2672322e5b7199a9224bed7f` and is not used as the D03
dependency identity. D03 does not rewrite or retag MPLAPACK.

```text
Changed during S-series: NO
```

The S-series used the installed frozen MPFR/MPC backend throughout. It did
not alter gmpfrxx or MPLAPACK.

## Milestones

```text
S00 predicates/abs/angle: PASS — c17b48c0a8bf7e39c3c9a111bcc8e3ae0c60e048
S01 elementary/power: PASS — 29f3539b2e99b984bc43647c908b9939fb7b155c
S02 reductions/extrema: PASS — 07c047d08d64ecd8c0d623cd2e1e621882b6c8b9
S03 comparison/logical/indexing: PASS — a71c13f96ad0a21cb8a1b6a17f8bf9992dde33ba,
    wrappers 5714787a5f99323bcbf2ba2cff3cdd459f9605d2
S04 matrix utilities: PASS — 2247480a4835519f27cb53b6a39173d05f16bdc8,
    native structure a742fce4dc6f3c372a050e41f25eefe886561dab
S05 ranges/utility: PASS — b97ed2ea231cbb9bb1fd8b7334911d86cb2db7db
S06 statistics: PASS — 0f3e9c8dd4bb00067c117e2144d0e1f3c7179d0b
S07 graphics: PASS — 384987bb6dbddd0758915debcda064acd15caaee
S08 closure: PASS — 51a0b420b6a47df3d84eba99bb27ec4b1d96a622
D03 freeze: PASS — 34993eb569bfaa0d7665ae913a3a1f5a97ac2e31
```

The S00-S08 implementation and report/status commits were pushed after each
milestone. D03 release metadata was introduced at `c0fe945f6ace1420854b96458ffdc897f7076652`,
and the final reproducible archive checksum was recorded at the freeze
commit above.

## Final compatibility matrix

```text
Supported:
  dense real/complex arithmetic, solve, right division, factorization,
  eig, SVD, norm, det, inv, rank, cond, rcond;
  abs, arg, angle, sign, predicates, exact equality;
  power and native MPFR/MPC elementary functions;
  reductions, extrema, comparisons, logicals, find, logical indexing;
  diag, triu/tril, like constructors, repmat, flips, rot90, cat(1/2);
  colon, linspace, logspace, rounding, rem/mod, hypot, atan2, signbit, eps;
  mean, median, var, std, range, bounds;
  plot, semilogx, semilogy, loglog, scatter, stem, stairs at the graphics
  boundary; sort, diff, length, size, rows, columns, numel, ndims, isempty.

Partial:
  graphics accepts an explicit final conversion to builtin double, so the
  plot representation is limited by the host graphics boundary; complex
  ordering uses the documented Octave-compatible magnitude/phase contract.

Deferred:
  sparse, symbolic, signal/image-specialized, ODE/PDE, optimization,
  surface/matrix graphics such as mesh, and general N-D storage. Packed
  triu/tril output, complex colon/logspace/rounding utility forms, weighted
  statistics, and unsupported multi-dimensional statistics forms remain
  explicit compatibility-firewall stops.
```

## Elementary API

S00 and S01 passed native MPFR/MPC tests for `abs`, `arg`, `angle`, `sign`,
element-wise and scalar power, integer square-matrix power, `sqrt`, `exp`,
`expm1`, `log`, `log1p`, `log10`, `log2`, trigonometric functions,
hyperbolic functions, and `cbrt`. Domain-crossing real results promote to
MPC at the selected operation precision. No numerical path uses builtin
binary64 arithmetic.

## Reduction API

S02 passed `sum`, `prod`, `sumsq`, `cumsum`, `cumprod`, `min`, and `max` with
dimensions, `all` where applicable, NaN flags, cumulative direction, native
accumulation, first indices, and the native complex magnitude/phase ordering
contract. S06 passed the statistics API listed above using operation-owned
MPFR/MPC accumulators and stable two-pass variance.

## Comparison/logical API

S00 and S03 passed `isnan`, `isinf`, `isfinite`, `isreal`, `isequal`,
`isequaln`, `isscalar`, `isvector`, `ismatrix`, `isempty`, `isnumeric`, real
comparisons, complex equality, logical conversion, `&`, `|`, `xor`, `~`,
`any`, `all`, `find`, numeric indexing, and logical indexing. Complex ordered
comparisons remain an explicit rejection.

## Matrix utility API

S04 passed native `diag`, `triu`, `tril`, `zeros`, `ones`, `eye`, `NaN`, `Inf`,
`repmat`, `flip`, `fliplr`, `flipud`, `rot90`, and `cat(1/2)`. Constructors
preserve source precision and real/complex storage kind. Matrix structure and
assignment remain value-semantic and operation-owned.

## Sequence/utility API

S05 passed native real `colon`, real/complex `linspace`, real `logspace`,
MPFR rounding, `rem`, `mod`, `hypot`, `atan2`, `signbit`, and local MPFR
`eps`. S08 passed native real/complex `sort` and `diff`, including dimension,
direction, one-based indices, NaN placement, stable ties, order-zero copies,
and empty scalar-difference behavior.

## Statistics API

S06 passed real and complex `mean`, `median`, `var`, `std`, `range`, and
`bounds`, including dimensions, `all`, NaN flags, normalization, optional
mean outputs, complex magnitude/phase ordering, stable variance, and stored
precision.

## Graphics boundary

```text
Functions: plot, semilogx, semilogy, loglog, scatter, stem, stairs
Automatic double conversion: only mp data immediately before host graphics
Numerical fallback: NONE
High-range limitation: host graphics may turn very small/large mp values into
  zero/infinity; range-sensitive transforms must be performed in mp first
Grcar plot: PASS, including balance/nobalance overlay
Result: G-S07 and G-S08 graphics gates PASS
```

Axes handles, style strings, property/value pairs, and non-`mp` values are
passed through unchanged. `mesh(mp_matrix)` remains an intentional firewall
stop. The graphics conversion is never reused by a numerical operation.

## Ordinary script corpus

```text
Script A: PASS — linspace, power, sqrt, exp/log, sin/cos, sum, plot
Script B: PASS — comparisons, isfinite, logical indexing, min/max, mean/std
Script C: PASS — like constructors, diag, triu/tril, repmat, flip, cat
Script D: PASS — norm, right division, eig, svd, rank, cond
Script E: PASS — Grcar eig, residual through /, plotting, balance/nobalance
Script F: PASS — negative-domain promotion, complex trig, abs/angle,
  statistics, plot
Unexpected stops: NONE in the required six-script corpus
Intentional stops: mesh/surface graphics, sparse/symbolic/N-D and documented
  unsupported dense forms
```

## Precision

```text
1024: PASS — 2^-700 tails and source-precision canaries
2048: PASS — 2^-1500 tails and source-precision canaries
ambient independence: PASS — changing ambient mpbits does not rewrite values
source precision: PASS — MPFR/MPC operation scopes and native accumulators
```

The established one-operation/one-precision MPFR/MPC contract, explicit
worker-entry scope behavior, and immutable public `mp` value semantics were
reverified by the final wall. No parent-thread TLS propagation is assumed.

## Regression

```text
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex Cgetrf: PASS
N00-N08 numerical regression: PASS
D01R1 package identity/closure checks: PASS
S00-S08 script compatibility regression: PASS
Grcar and graphics smoke: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
Firewall: PASS
Package lifecycle: PASS — clean archive install, list/load, real/complex
  smoke, all test files, help, examples, unload, uninstall, reinstall, and
  second smoke
```

The final `tools/local-ci.sh` run used the exact final source commit and the
installed frozen MPLAPACK/gmpfrxx stack. It ended with `PASS: D00 local CI`.
Known host warnings were limited to the GNU Octave gnuplot toolkit,
non-positive values in log plots, and the intentional singular-matrix test;
the MPLAPACK `pi` unused-parameter warning was non-fatal.

## Final source identity

```text
Name: mplapack-interop
Version: 0.4.0
Freeze commit: 34993eb569bfaa0d7665ae913a3a1f5a97ac2e31
Tag: v0.4.0
Tag target: 34993eb569bfaa0d7665ae913a3a1f5a97ac2e31
Archive: mplapack-interop-0.4.0.tar.gz
Size: 361088 bytes
SHA256 A: 6bc87d42fbda49fa72830db34fbede7b8b9f46b7614b14dc53e7619c7781536c
SHA256 B: 6bc87d42fbda49fa72830db34fbede7b8b9f46b7614b14dc53e7619c7781536c
Hashes identical: YES
Archive placement: /home/docker/src/mplapack-interop-0.4.0.tar.gz
```

The archive has one top-level directory, `mplapack-interop-0.4.0/`, and was
generated twice independently with identical file lists and SHA256. It has
no `.git`, generated object/module/build output, absolute path, report
handoff, or developer-specific installer. The `inst/@mp/private` directory
contains package-internal implementation helpers and is intentionally part
of the public source package; it is not a developer-only artifact.

The archive generated from the exact tagged tree reproduced the same
`6bc87d42...` SHA256 and `361088` byte size.

## Binary handoff

```text
B01 source: mplapack-interop-0.4.0.tar.gz
B01 SHA256: 6bc87d42fbda49fa72830db34fbede7b8b9f46b7614b14dc53e7619c7781536c
D01R1 ABI architecture: GNU Octave 11.1.0, API-v61, Linux x86_64,
  GNU C++ 15.2.0; compatibility key is Octave major/minor + API + OS + arch
Runtime closure: libmplapack_mpfr.so.3, libmpc.so.3, libmpfr.so.6,
  libgmp.so.10, libstdc++.so.6, libm.so.6, libgcc_s.so.1, libc.so.6
B01-ready: YES — architecture remains the later B01 responsibility
```

The final module's `readelf`/`ldd` audit resolved MPLAPACK from
`/home/docker/opt/octave-mplapack-stack/lib` and MPC/MPFR/GMP from the
recorded host prerequisites (`/usr/local/lib`). The final module has no
relative runpath; the current isolated `LD_LIBRARY_PATH` proof is recorded
as a B01 relocation task, not as a final binary artifact.

## Known remaining limitations

- Sparse, symbolic, specialized signal/image, ODE/PDE, optimization, general
  N-D, and surface/matrix graphics APIs remain deferred.
- Graphics conversion is intentionally a builtin-double boundary and has the
  documented range limitation.
- The tested host provides MPFR TLS behavior but no MPC TLS API; no automatic
  MPC TLS or parent-to-worker precision propagation is claimed.
- The exact MPLAPACK dependency is the D01R1-tested source archive at
  `c21a9f5`; D03 did not create or modify a dependency tag.
- No B01-B05 binary artifact, Debian package, PPA upload, Launchpad upload,
  or Octave Packages registry submission was performed.

## Next milestone

```text
D03 PASS — MPLAPACK-INTEROP SCRIPT-COMPAT SOURCE FROZEN
B01-READY
```

Proceed to `B01 — Linux x86_64 binary package` only as a separate goal and
using exactly the D03-frozen source identity above. Do not modify numerical
source in B01. If a source-level defect is found, reopen the freeze rather
than editing the tagged source silently. B01 is not started automatically.

## Gates

```text
G-S00 through G-S08: PASS
G-D03-SOURCE-FREEZE: PASS
G-D03-VERSION: PASS
G-D03-REPRODUCIBLE: PASS
G-D03-FULL-REGRESSION: PASS
G-D03-SCRIPT-CORPUS: PASS
G-D03-PACKAGE-LIFECYCLE: PASS
G-D03-GRAPHICS: PASS
G-D03-RUNTIME-CLOSURE: PASS
G-D03-DOCS: PASS
G-D03-TAG: PASS
G-D03-BINARY-HANDOFF: PASS
```

Final conclusion:

```text
D03 PASS — MPLAPACK-INTEROP SCRIPT-COMPAT SOURCE FROZEN
B01-READY
STOP
```
