# Tier S/A/V SVD examples

`examples/svd_tiers/` is a reproducible example and verification harness for
difficult dense singular-value problems. It is not another SVD implementation
and it does not add a public package API. The existing `mp`/`svd` path remains
the only numerical solver path; the harness records its actual inputs and
outputs, then applies separate reference and certificate checks.

The suite has three layers:

| Tier | Purpose | What is implemented |
|---|---|---|
| S | Structured difficult inputs | NRO blocks, Jacobi--Stirling, Lah, and DD representations |
| A | Accuracy-oriented families and controls | Pascal, dyadic Vandermonde, bidiagonal, Lauchli, Hadamard, and NRO companion-like inputs |
| V | Self-contained verification baselines | polar/Weyl singular-value inclusions, signed-dilation projectors, compatible factor boxes, and Neumann inverse certificates |

The V methods are conservative baselines for the corresponding claims. They
are not ports of the complete algorithms in the cited papers. In particular,
the implementation does not claim interval-input coverage, sharp componentwise
bounds, or the operation count of those algorithms.

## Quick start

From a configured checkout with `mplapack-interop` loaded:

```octave
pkg load mplapack-interop
addpath (fullfile (pwd (), "examples", "svd_tiers"));

smoke = mp_svd_tiers ("smoke");
demo = mp_svd_tiers ("demo", struct ("tier", "all", ...
                                     "output_dir", fullfile (pwd (), "svt-demo"), ...
                                     "plot", false));
assert (demo.ok);
```

The smoke profile contains 20 cases and exactly 120 measured SVD rows. The
demo profile contains 23 cases and exactly 184 measured rows. References,
inverse solves, and V jobs are reported separately from these SVD rows. Stress
is opt-in and is not part of the default acceptance wall.

The three short top-level examples are:

```text
examples/14_svd_tier_s.m    small dense NRO two-level block
examples/15_svd_tier_a.m    rectangular dyadic-node Vandermonde matrix
examples/16_svd_verified.m  V1 singular-value and V3 inverse certificates
```

Each has a small default problem that runs without an output directory. The
full profile commands above are the authoritative way to obtain all rows and
verification jobs.

## Precision and input identity

The harness keeps four precision roles distinct:

1. `work_bits` is the stored precision of the actual SVD input;
2. construction precision is the precision used while materializing a model;
3. reference precision is used for a separate high-precision SVD of the frozen
   represented input; and
4. evaluation precision is used to widen values for diagnostics and interval
   arithmetic.

An exact model and its represented input are both retained in the fixture
identity. A below-guard diagonally dominant row is explicitly labeled as a
rounded recipe; the ideal model spectrum is never silently imposed on that
rounded input. Native rows are made by one explicit conversion from an exact
model and are frozen for both values-only and economy calls.

The arithmetic and certificate paths use the stored MPFR/MPC values at one
operation precision. A result may be widened for diagnostics, but it is never
recomputed at a higher precision and substituted for the measured result. No
measurement, comparison, or certificate is routed through binary64. Optional
plots are presentation-only conversions and are not fed back into any gate.

## Case inventory

The normative case list is `docs/codex/svt/cases.json`. The smoke cases are:

```text
S1-NRO-TWO       S1-NRO-THREE       S1-NRO-GRADED
S2-JS            S3-LAH
S4-DD-SYM        S4-DD-NONSYM
A1-PASCAL-LOWER  A1-PASCAL-SYM      A2-VAND
A3-BDI-RAW       A3-BDI-MIXED
A4-LAU-TALL      A4-LAU-WIDE
A5-GEO           A5-CLOSE           A5-REPEAT
A5-RANK4        A5-RANK5
A6-NRO-COMPANION
```

The demo adds `A4-LAU-COMPLEX`, `S1-NRO-SCALE-UP`, and
`S1-NRO-SCALE-DOWN`. These controls exercise complex phase handling and
global scale range without changing the solver or precision contract.

## Ordinary diagnostics

For each measured row the writer records the case, tier, family, mode, native
flag, work precision, input identity, timing, and status. Economy rows also
record reconstruction and the two triplet residuals:

```text
rho_rec = ||A-U*S*V'||F / ||A||F
rho_R   = ||A*V-U*S||F / (||A||F*||V||F)
rho_L   = ||A'*U-V*S||F / (||A||F*||U||F)
```

Orthogonality/unitarity, positive ordering, frozen-input error, model error,
zero leakage, and condition diagnostics remain separate fields. Factor signs
and complex phases are not compared column-by-column. Repeated singular values
are checked as subspaces or by a compatible-factor claim.

## Output bundle

When `output_dir` is supplied it must be new and empty. The harness refuses to
overwrite a previous run. It writes:

```text
summary.tsv
singular-values.tsv
verification.tsv
certificates.json
summary.json
inputs-and-factors.json
environment.txt
report.md
plots/                  # only when plot=true
```

The files use schema `svt-v1`. TSV decimal strings are display fields. JSON
certificates and factor records include exact MPFR/MPC V4 dyadic snapshots,
source precision, and canonical SHA-256 bindings. `inputs-and-factors.json`
contains the actual target matrix and factors used by the replay checker; it is
not a decimal-only export.

`svt_replay_snapshots` decodes those snapshots independently before checking
their shapes, values, and canonical hashes. `svt_check_coverage` rejects an
empty, incomplete, or duplicate row set. These are hard structural checks, not
reporting conveniences.

## Tier V jobs

V1A uses method ID `svt_polar_weyl_v1` and encloses every ordered singular
value from the actual stored factors. V1B uses
`svt_dilation_projector_v1` for declared positive clusters, including
structural zero directions in rectangular problems. Internal multiplicity is
allowed; a collapsed external dilation gap produces `INCONCLUSIVE`.

V2 uses `svt_dilation_factor_boxes_v1`. It returns compatible norm-derived
entrywise boxes for separated simple singular pairs and applies one common
sign/phase to the left/right pair. Individual identification of repeated
vectors is explicitly `UNSUPPORTED_MULTIPLICITY`, while the V1 subspace result
remains valid.

V3 uses `svt_neumann_inverse_v1`. It consumes a public solve output and checks
an outward residual bound `r < 1` before returning a positive inverse-norm or
`sigma_min` lower bound. Singular, poor-inverse, and rectangular controls are
recorded as `INCONCLUSIVE` or `UNSUPPORTED_RECTANGULAR`; none is reported as
a singularity proof merely because a sufficient condition failed.

Valid statuses are deliberately distinct:

```text
CERTIFIED
INCONCLUSIVE
UNSUPPORTED
INVALID_DATA
ARITHMETIC_CONTRACT_UNPROVEN
```

Every verification job has a separate `gate_ok` and
`meets_accuracy_target` field. A broad but valid inclusion can therefore be
reported as certified without being advertised as a narrow accuracy result.
All jobs record `paper_algorithm_reproduction=false`.

## Integrated tests

`test/test_svd_tiers.m` and `test/test_svd_verification.m` are run from the
existing `test/run_tests.m` runner. The former covers the Tier S/A constructors,
input identity, measured SVD contract, and all allocated families. The latter
covers V0 arithmetic preconditions, V1 values/projectors, V2 factor boxes, V3
inverse bounds, and adversarial controls. Existing N02 SVD and NEIG tests remain
in the same runner and are not replaced.

`tools/test-doc-examples.sh` runs examples 01--16, including the three SVT
examples, and performs the existing help-text wall. `tools/check-docs.sh`
checks the Texinfo chapter, generated Markdown, API inventory, backend map,
examples, and help coverage. No SVT example changes the installed `mp` API.

## Source and interpretation ledger

The exact source/interpretation ledger is `docs/codex/svt/SOURCES.md`.
The NRO, Jacobi--Stirling, Lah, DD, Pascal, totally-nonnegative, Lauchli, and
verification references motivate the families or claim classes. Dimensions,
dyadic scalings, phase controls, acceptance targets, and the exact replay
format are suite adaptations. They are not reproduced published tables.

The implementation uses the public `mp`, `mpbits`, dense arithmetic, `svd`,
and solve operations. It adds no backend, SVD driver, rounding setter,
dependency, or installed header. See `docs/svd-verification.md` for the
proof-to-code boundary and failure classification.

## Limitations

The default acceptance is smoke/demo, not the opt-in stress profile. Native
binary64 rows are explicit rounded-input comparisons, not high-precision
answers. Repeated individual singular vectors are not uniquely certifiable.
The V methods certify only their stated sufficient conditions; an
`INCONCLUSIVE` result is not evidence of singularity. Plot output, operating
system portability, and binary distribution are outside this example suite.
