# M20 RESULT

Repository: https://github.com/nakatamaho/octave-mplapack
Remote: origin (https://github.com/nakatamaho/octave-mplapack.git)
Branch: topic/m20-complex-architecture
Starting commit: f76af221684880ff377bbc2865b985734db3a01e
Final commit: 301116d (audit/design/probe; report commit follows)
PR: #21 — https://github.com/nakatamaho/octave-mplapack/pull/21

## Baseline

- M19 accepted base: f76af221684880ff377bbc2865b985734db3a01e
- M19 implementation commit: 36cb203
- MPLAPACK dependency: 1cf03d1a1aa2afecde5f1840fbe9663ecfc31e57
- Fresh real project default: 512 bits

## Complex scalar backend

- Exact C++ type: `mpfrxx::mpc_class`
- Namespace: `mpfrxx`
- Header: `mpcxx_mkII.h` / installed `gmpfrxx_mkII/detail/mpc_impl.hpp`
- Underlying representation: MPC `mpc_t value_`, containing MPFR real/imag values
- Real component type: MPFR `mpfr_t` exposed through `mpfrxx::mpfr_class`
- Imag component type: MPFR `mpfr_t` exposed through `mpfrxx::mpfr_class`
- Default construction: thread-local MPC defaults, inheriting the MPFR default when no MPC override is active
- Explicit precision construction: `with_precision(p)` and two-component overload
- Copy precision: source real/imag precisions and represented value are preserved
- Move behavior: initialized values are exchanged with `mpc_swap`
- Vector storage: contiguous `std::vector<mpc_class>` is safe; installed static assertions cover size/alignment
- COMPLEX* compatibility: direct `mpc_class*` compatibility verified by headers and Cgemm probe
- Special values: zero/Inf/NaN values survive copy; current MPC copy normalizes a negative imaginary zero (C00 issue)

## Precision model

- One complex object one precision: required; public values forbid mixed component precision
- Real component precision: `p`
- Imag component precision: `p`
- TLS dependency: MPFR and MPC defaults/overrides are thread-local in the audited wrapper
- MPC/global default state: no process-global default found; thread-local MPC precision and rounding overrides exist
- Thread independence: worker set to 2048 bits did not change main-thread 128-bit default
- Rounding policy: future project policy is round-to-nearest for both components
- Non-TLS limitations: future workers must establish `p_op`; explicit MPC overrides must be controlled or rejected

## Complex matrix architecture

- Proposed storage class: `MpfrComplexMatrixStorage`
- Contiguous: yes, column-major `std::vector<mpfrxx::mpc_class>`
- Uniform precision: one matrix precision; both components of every element use it
- Explicit precision allocation: preferred via `with_precision(p)` (or a composed scope when required)
- Public payload kind: separate checked complex scalar and complex dense matrix kinds
- Direct MPLAPACK compatibility: `COMPLEX*` direct pointer, no packing
- Real storage retained separately: yes; existing `MpfrMatrixStorage` and real calls remain unchanged

## Public class architecture

- Public class: one `mp`
- Real scalar payload: existing `MpfrScalarStorage`
- Real matrix payload: existing `MpfrMatrixStorage`
- Complex scalar payload: future `mpc_class` storage
- Complex matrix payload: future `MpfrComplexMatrixStorage`
- Complex->real implicit demotion: forbidden
- Real->complex promotion: exact real component plus exact `+0` imaginary component at `p_op`
- Mixed result policy: any complex participant gives a complex result; precision is the maximum operand precision

## Constructor / conversion design

- complex double -> mp: future direct binary64 real/imag conversion at participating mp precision
- real double -> mp: existing direct binary64 real conversion; future real-to-complex promotion adds `+0i`
- text complex constructor: future explicit real/imag pair or one canonical unambiguous grammar; not implemented
- char complex scalar: future locale-independent, source-precision round-trip-safe component grammar
- double complex: future component-wise MPFR round-to-nearest conversion to builtin complex double
- real(): future real `mp`, same precision and shape
- imag(): future real `mp`, same precision and shape
- conj(): future complex `mp`, same precision with exact imaginary sign negation

## Transpose semantics

- transpose .': transpose only
- ctranspose ': transpose plus complex conjugation
- Real compatibility: M12 real behavior remains unchanged
- Future complex behavior: use Octave conjugate-transpose semantics; no TRANS optimization is required

## MPLAPACK complex backend audit

### GEMM

- Routine: `Cgemm`
- Signature: installed `Cgemm(const char*, const char*, mplapackint, mplapackint, mplapackint, mpc_class, mpc_class*, mplapackint, mpc_class*, mplapackint, mpc_class, mpc_class*, mplapackint)`
- Library: `libmplapack_mpfr.so.3`
- Precision POC: 1024-bit `2^-700` and 2048-bit `2^-1500` identity cases pass
- Worker audit: pinned reference loop has no OpenMP/pthread/std::thread regions

### Square solve

- Routine: `Cgesv`
- Signature: installed `Cgesv(..., mpc_class*, ..., mplapackint*, mpc_class*, ..., mplapackint&)`
- Precision POC: one-by-one solve passes at 1024 and 2048-bit probe precision

### Cholesky

- Routine: `Cpotrf`
- Signature: installed `Cpotrf(const char*, mplapackint, mpc_class*, mplapackint, mplapackint&)`
- Selected-triangle semantics: future Hermitian selected-triangle contract; no implementation yet
- Precision POC: one-by-one factorization passes at 1024 and 2048-bit probe precision

### QR

- Factor routine: `Cgeqrf`
- Q-generation routine: `Cungqr`
- Pivoted routine: `Cgeqp3` (installed; future audit only)
- Precision POC: Cgeqrf/Cungqr 1024 and 2048-bit calls pass

### Rectangular solve

- Available rank-revealing candidates: `Cgelss`, `Cgelsy`, `Cgelsd`
- Preferred future audit target: `Cgelsy`, then `Cgelss`, then `Cgelsd`, with complex REAL work at one `p_op`

## Packaging

- Complex backend library: same `libmplapack_mpfr.so.3` as real symbols
- SONAME: `libmplapack_mpfr.so.3`
- pkg-config: `mplapack_mpfr`; complex symbols are exported by that package
- Extra dependencies: `libmpc.so.3`, `libmpfr.so.6`, `libgmp.so.10`
- MPC dependency: system MPC, LGPL-3-or-later
- PPA impact: no real-only blocker found
- Real-only package can later gain complex without rename: yes, based on current SONAME/dependency closure
- License inventory: project/MPLAPACK BSD-2-Clause-compatible terms; MPFR LGPL-3-or-later; GMP GPL-2-or-later/LGPL-3-or-later; system metadata remains P01 work

## Design decisions

| Decision | Selected approach | Rejected alternatives | Reason | Evidence | Future milestone |
|---|---|---|---|---|---|
| scalar | installed `mpfrxx::mpc_class` | local pair wrapper | direct backend ABI | header and probe | C00 |
| matrix | contiguous uniform `vector<mpc_class>` | scalar-wrapper arrays; split public real/imag | direct `COMPLEX*`, one precision | layout assertions/probe | C00/C02 |
| public type | one `mp` with four payload kinds | `cmp`/`mpc` class | preserves real syntax | M02--M19 architecture | C00 |
| precision | one equal component precision and one `p_op` | mixed components; ambient default | uniform MPLAPACK contract | constructor audit | C01 |
| promotion | complex at max precision, exact `+0i` | implicit demotion; text/double round trip | value preservation | existing real policy | C03/C11 |
| GEMM | direct `Cgemm` | four real GEMMs | backend fidelity | installed symbol/probe | C05 |
| transpose | `.'` transpose, `'` conjugate transpose | treating both as transpose | Octave semantics | M12 boundary | C03 |
| packaging | same package update | complex package split | same SONAME closure | `pkg-config`/`ldd`/`readelf` | PPA series |

## Rejected alternatives

- A second public `cmp` class: rejected because it would split normal Octave
  syntax and duplicate dispatch.
- A matrix of scalar wrapper objects: rejected because it breaks contiguous
  MPLAPACK pointer compatibility and uniform storage ownership.
- Per-component or per-element precision: rejected because MPLAPACK calls need
  one uniform operation precision.
- Converting complex values through text or binary64: rejected because it
  loses represented tails and special-value state.
- Routing real operations through complex kernels: rejected to preserve M00--M19
  real performance and backend semantics.

## Open issues

| Issue | Severity | Blocks PPA v0.1? | Blocks complex v0.2? | Proposed investigation |
|---|---|---|---|---|
| MPC override can diverge from MPFR scope | medium | no | yes | C00/C01 scope and override policy |
| Complex text grammar/display | medium | no | yes | C01/C02 constructor/display audit |
| Optimized complex worker precision | high | no | yes | audit each enabled optimized DSO before C05 |
| Complex rank-revealing workspace/threshold | high | no | yes | C07 `Cgelsy/Cgelss/Cgelsd` comparison |
| System dependency license metadata | low | no | no | P01 Debian review |
| Special values and ordered comparisons | medium | no | yes | C03/C04 Octave differential tests |

## Real-only PPA decision

REAL-PPA-GO

Reason: complex symbols are in the existing MPLAPACK MPFR library and no
representation, ABI, or dependency issue blocks the real-only package. Public
complex support remains unimplemented.

## Post-M20 real roadmap

- M21: real LU factorization
- M22: real API/release closure
- M23: v0.1 feature freeze
- PPA1: MPLAPACK Debian packaging
- PPA2: octave-mplapack Debian packaging
- PPA3: Launchpad staging build
- PPA4: public real-only v0.1 PPA

## Complex roadmap

- C00: complex scaffold / native storage
- C01: complex scalar constructor and conversion
- C02: complex dense matrix storage/indexing/display
- C03: real/imag/conj/transpose/ctranspose
- C04: complex element-wise arithmetic
- C05: complex GEMM
- C06: complex square solve
- C07: complex rank-revealing rectangular solve
- C08: Hermitian Cholesky
- C09: non-pivoted complex QR
- C10: pivoted complex QR
- C11: mixed real/complex closure
- C12: complex package/regression release

## QA

- Native complex probes: `test/m20_complex_probe.cc` passes Cgemm, Cgesv,
  Cpotrf, Cgeqrf/Cungqr, precision tails, layout assertions, zero/Inf/NaN
  copy checks, and TLS scope restoration at 1024/2048 bits; it records that
  the current MPC copy path normalizes a negative imaginary zero
- Thread/TLS probes: worker 2048-bit default remains independent from main 128-bit default
- ASan: pass through existing M00--M19 sanitizer suite; complex probe is clean
- UBSan: pass through existing M00--M19 sanitizer suite; complex probe is clean
- LSan: pass through existing M00--M19 sanitizer suite; complex probe is clean
- Existing M00-M19 real regression: `tools/local-ci.sh` PASS, including build/install/reinstall QA
- git diff --check: PASS

## Gates

- G20-TYPE: PASS
- G20-PRECISION: PASS
- G20-PUBLIC: PASS (design decision; no public complex implementation)
- G20-BACKEND: PASS
- G20-PACKAGING: PASS
- G20-REAL-REGRESSION: PASS
- G20-RELEASE: PASS

M20 PASS — REAL-PPA-GO

## Code changes

Documentation and test-only audit probe changes only; no public complex
payload, operator, or MPLAPACK source implementation was added.

## Files changed

- `docs/complex-architecture.md`
- `docs/milestones/M20-complex-architecture.md`
- `test/m20_complex_probe.cc`
- `docs/architecture.md`
- `docs/packaging.md`
- `docs/milestones/README.md`
- `README.md`
- `NEWS.md`
- `tools/check-tree.sh`
- `tools/check-format.sh`
- `tools/local-ci.sh`
- `m20-report.md`

## Commits

- M20 audit/design/probe commit: 301116d
- M20 report commit: 31ace39
- M20 package-archive QA adjustment: 2e396a3
- M20 special-value audit commit: cfa9f17

## Push

- Push: pushed to `origin/topic/m20-complex-architecture`
- Remote tip: 337cb4ca1e55da8bb3673528c3c112df564518d2
- Local tip: 337cb4ca1e55da8bb3673528c3c112df564518d2 (report metadata commit follows)
- GitHub CI: PR #21 structural-checks PASS

## Known unresolved complex issues

- Public complex implementation has not started.
- MPC override/scope composition requires an explicit C00/C01 policy.
- Complex optimized-worker precision requires a per-library audit.
- The current MPC copy path normalizes a negative imaginary zero; C00 must
  choose an explicit sign-preserving policy if required by the public contract.
- Complex text grammar, special-value display, comparison policy, and
  rank-revealing rectangular driver remain future design/QA work.

## Recommended next action

Proceed to M21 real LU factorization, followed by real API/release closure and
the PPA packaging series. Do not begin complex implementation automatically.

Branch: topic/m20-complex-architecture
Starting commit: f76af221684880ff377bbc2865b985734db3a01e
Final commit: 301116d (audit/design/probe; report commit follows)
Files changed: documentation, test/m20_complex_probe.cc, and QA script updates
Commands run: `tools/check-tree.sh`; `tools/check-format.sh`; controlled `tools/local-ci.sh`; `pkg-config`; `ldd -r`; `readelf -d`; `nm -D -C`; native complex probe
Tests: native complex probe PASS; M00-M19 ASan/UBSan/LSan and installed package regression PASS
Gate: M20 PASS — REAL-PPA-GO
Known limitations: no public complex support; complex C00-C12 and real M21+ remain future milestones
