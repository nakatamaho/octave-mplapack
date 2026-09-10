# NEIG01 report

Task and milestone: NEIG — difficult nonsymmetric eigensystems; NEIG01 skeleton, exact Hadamard fixture, and precision isolation.

Branch: `main`

Starting commit: `940ebd9e7bbd3da66f59e045fa4719312a9894f0`

Validated implementation commit or uncommitted state: implementation and focused test files are present in the working tree; the report is written before the milestone commit.

Files created/modified:

- `examples/nonsymmetric_eig/mp_eig_suite.m`
- `examples/nonsymmetric_eig/mp_eig_suite_selftest.m`
- `examples/nonsymmetric_eig/private/nes_build.m`
- `examples/nonsymmetric_eig/private/nes_cases.m`
- `examples/nonsymmetric_eig/private/nes_promote.m`
- `examples/nonsymmetric_eig/private/nes_reference.m`
- `test/test_nonsymmetric_eig_suite.m`
- `neig01-report.md`

Environment and executable/module resolution:

- GNU Octave 11.1.0 from `/usr/bin/octave`, executed through `tools/dev-octave.sh`.
- MPLAPACK MPFR dependency was resolved through `/home/docker/opt/octave-mplapack-stack/lib/pkgconfig`; installed headers came from `/home/docker/opt/octave-mplapack-stack/include` and libraries from `/home/docker/opt/octave-mplapack-stack/lib`.
- No dependency repository, dependency header, package public API, or native source was modified.

Commands run:

```text
PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/dev-octave.sh --eval 'run ("test/test_nonsymmetric_eig_suite.m");'
git diff --check
```

Tests and numerical results:

- Hadamard Sylvester construction: PASS for `n=8`, including `H*H' = 8I`.
- Exact MP construction: PASS for the `(n,s)=(8,16)` fixture at 256 bits.
- Exact native comparison: PASS; the native `H*T*H'/n` construction and the MP construction had zero MP Frobenius difference for this exact dyadic fixture.
- Transformed input shape: PASS; the fixture was both nonsymmetric and nontriangular.
- Known integer reference vector `1:8`: PASS as an analytic reference object.  No solver output is substituted by this reference.
- Promotion: PASS for represented values at 1024 and 2048 bits, including nonzero `2^-700` and `2^-1500` values.  The 2048-bit value was checked through MP text rather than a binary64 conversion that would underflow.
- Promotion preserves the original object and restores the ambient default precision: PASS.
- Invalid `family="all"` is rejected explicitly at this stage; no family is silently omitted.
- Public `mp` APIs are the only numerical operations used by the example helpers.  The test file uses no private native entry point.

Gate: PASS

Known limitations:

- NEIG01 intentionally implements only the Hadamard constructor/reference and a validated runner skeleton.  It does not yet claim an eigensolve, matcher, metrics, or the Frank/companion/Forsythe families.
- `mp_eig_suite` returns `ok=false` with `NEIG01_skeleton_only` for its current Hadamard selection; NEIG03 will connect the eigensolve after NEIG02 supplies diagnostics.
- The analytic Hadamard condition-number recurrence and full exactness bound are deferred to NEIG03, as required by the milestone sequence.

Next milestone or minimal blocker reproducer: proceed to NEIG02.

