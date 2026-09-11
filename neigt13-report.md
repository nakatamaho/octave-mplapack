# NEIGT13 report

Task and milestone: NEIGT — audited outward arithmetic and exact serialization.

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `138511fe1f2e1f14fffc8632783435d3fb9af85d`

## Implemented

- Added q=64..4096 validation and the per-primitive MPFR round-to-nearest
  enclosure required by `ARITHMETIC.md`: `t=8*2^-q*abs(r)` followed by two
  independently rounded endpoints.  Exact zero witnesses are required for a
  zero result; unexpected zero, nonfinite values, denominator intervals
  containing zero, negative square-root domains, and the declared range are
  rejected closed.
- Added real interval addition, subtraction, multiplication, division, square
  and square root.  Squares crossing zero have a proved zero lower endpoint.
- Added complex rectangular arithmetic, conjugation with reversed imaginary
  endpoints, division with a zero-excluding squared denominator, modulus
  bounds, explicit complex matrix products, conjugate transpose, matrix
  subtraction, induced infinity/Frobenius upper norms, and Neumann inverse
  residual witnesses.  Matrix products enumerate interval products and sums;
  no padded ordinary GEMM is used.
- Added public-MP-only binary extraction to normalized lowercase hexadecimal
  odd mantissas and exact binary exponents.  Matrix records preserve shape,
  column-major order, stored precision, schema/method version, and a canonical
  SHA-256 content hash.  Decode rejects a destination precision below the
  recorded mantissa requirement.
- Added a small self-contained JSON reader/writer for the fixed witness schema.
  Fresh reads recompute the canonical hash; tampered content is rejected.

## Source contract audit

The local source audit found explicit `MPFR_RNDN` calls for the MPFR real
primitive path in `src/mp_script_compat.cc` and explicit `MPC_RND(MPFR_RNDN,
MPFR_RNDN)` calls in the complex paths.  No global MPFR exponent-limit or
rounding-mode setter was added or used by this milestone.  The interval layer
therefore records the source-level assumption that q scalar real operations
are MPFR round-to-nearest operations; it does not claim directed rounding.

## Gate

NEIGT13: **PASS** — scalar adversarial and exact rational-bound checks,
complex rectangle/conjugation checks, explicit 2×2 interval matrix products,
verified infinity/Frobenius norms, inverse residual nonsingularity, q=64/128/256
tests, 2^-1500 retention, range/domain rejection, canonical JSON hash replay,
tamper rejection, and insufficient-destination-precision rejection all pass.

## Commands and results

```text
PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
timeout 300s octave-cli --no-gui --quiet --no-init-file \
  --path /tmp/neigt-work2/inst --path /tmp/neigt-work2/src \
  --eval 'run("/tmp/neigt-work2/test/test_neigt13.m");'
exit 0
PASS: NEIGT13 outward primitives, complex rectangles, range checks, and replay hash
```

The first implementation attempt exposed two resolved defects: repeated range
constant construction caused a timeout, and a square interval lower bound was
allowed to become negative.  q-keyed cached constants and the explicit square
zero crossing rule fixed both without weakening the proof margin.  A test
comparison initially mixed MP and builtin logical operands; it was replaced by
exact structural re-encoding rather than decimal comparison.

## Files changed

`examples/neig_tiers/private/net_iv_q.m`, `net_iv_real.m`, `net_iv_point.m`,
`net_iv_round.m`, `net_iv_primitive.m`, `net_iv_real_add.m`,
`net_iv_real_sub.m`, `net_iv_real_mul.m`, `net_iv_real_div.m`,
`net_iv_real_sqrt.m`, `net_iv_real_square.m`, `net_iv_real_neg.m`,
`net_iv_minmax.m`, `net_iv_complex.m`, `net_iv_complex_point.m`,
`net_iv_complex_add.m`, `net_iv_complex_sub.m`, `net_iv_complex_mul.m`,
`net_iv_complex_div.m`, `net_iv_complex_neg.m`, `net_iv_complex_conj.m`,
`net_iv_complex_abs.m`, `net_iv_cmatrix_point.m`, `net_iv_cmatrix_mul.m`,
`net_iv_cmatrix_add.m`, `net_iv_cmatrix_sub.m`, `net_iv_cmatrix_neg.m`,
`net_iv_cmatrix_conjtrans.m`, `net_iv_cmatrix_eye.m`,
`net_iv_cmatrix_inf_upper.m`, `net_iv_cmatrix_fro_upper.m`,
`net_iv_inverse_residual.m`, `net_mp_integer_hex.m`, `net_hex_bit_length.m`,
`net_dyadic_encode_scalar.m`, `net_dyadic_decode_scalar.m`,
`net_dyadic_encode_matrix.m`, `net_dyadic_decode_matrix.m`,
`net_dyadic_canonical.m`, `net_dyadic_write_json.m`,
`net_dyadic_read_json.m`, `test/test_neigt13.m`, and this report.

Final commit: pending NEIGT13 commit.

## Limitations and next milestone

This is the conservative baseline specified by `ARITHMETIC.md`, not a claim of
directed-rounding APIs or a full paper algorithm.  Certificate-specific
similarity, graph, SVD, Schur, pencil and Perron checkers remain pending and
must consume these primitives.  Stress and plotting were not run.

Next milestone: NEIGT14 — V-S1 counted all-spectrum certificates.
