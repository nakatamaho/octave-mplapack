# SVT12 report

## Result

SVT12: PASS. The private V0.1--V0.3 outward-arithmetic baseline and V4 exact
dyadic serializer/replayer are implemented. Certificate claims are still
disabled until the V1--V3 checkers consume these primitives.

## Implemented paths

```text
examples/svd_tiers/private/svt_v0_contract.m
examples/svd_tiers/private/svt_iv.m
examples/svd_tiers/private/svt_dyadic_encode.m
examples/svd_tiers/private/svt_dyadic_decode.m
examples/svd_tiers/private/svt_dyadic_complex_encode.m
examples/svd_tiers/private/svt_dyadic_complex_decode.m
examples/svd_tiers/svt_v0_selftest.m
```

`svt_v0_contract` enforces q in [64,4096], checks finite nonzero powers and
reciprocal/range identities through the public MP API, and records the audited
MPFR RN contract. `svt_iv` stores lower/upper real MP endpoints, represents
complex values as real/imaginary rectangles, encloses every nonzero real
primitive with the specified `8*2^-q*abs(r)` padding, and fails closed on
unexplained zero, range failure, negative sqrt domain, or denominator intervals
crossing zero. Matrix multiplication is a scalar interval sum, not ordinary
GEMM followed by final padding. Frobenius upper and point-column lower bounds
are propagated through enclosed squares and square roots.

V4 extracts bits using only MP comparisons, subtraction, doubling, and bounded
integer control. It emits canonical positive odd lower-case hexadecimal
mantissas with a base-2 exponent, rejects insufficient decode precision, and
handles real/imaginary components separately. Decimal strings, private
payloads, and binary64 mantissas are not used. Signed-zero provenance is kept
as auxiliary metadata while the canonical zero record remains `sign=0`.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_v0_selftest(); assert(report.ok); disp('SVT12 V0/V4 selftest PASS');"
```

Observed result: `SVT12 V0/V4 selftest PASS` under GNU Octave 11.1.0 with the
recorded MPLAPACK 3.0.1 environment. The gate covered q=64/128/256 contract
checks, cancellation with proven exact zero, signed products, interval
crossing-zero squares, excluded-zero division rejection, perfect square roots,
complex rectangle multiplication/conjugate transpose, scalar matrix bounds,
1/3 and power-of-two exact replay through 2^600, signed zero, complex replay,
and insufficient decode precision.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `19b584351600602edad7894f89d31cec09ba0a84`

Final commit: recorded after this report is committed

Tests: scalar contract, interval/rectangle arithmetic, matrix bounds, exact serializer, and replay PASS

Gate: PASS

Known limitations: V0 primitive padding is proved only under the audited
source/range contract recorded here; V1/V2/V3 proof consumers, canonical
artifact hashes, and replayed certificate jobs remain pending.
