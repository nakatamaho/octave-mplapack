# Verified SVD baselines

This document describes the finite-arithmetic verification layer used by the
SVT example suite. It defines what the result means and what it does not mean.
The code is under `examples/svd_tiers/private/`; no verifier is installed as a
public package function.

## Boundary and precision roles

The checker receives the actual `mp` target and the actual factors returned by
the public `svd` call. It does not invoke `svd` to manufacture a reference
factorization. A separate high-precision reference is useful for diagnostics,
but reference agreement is not a certificate.

Inputs, factors, interval endpoints, and replay snapshots stay in MPFR/MPC
arithmetic. Exact widening is used only to evaluate a stored result at the
declared evaluation precision. No value is converted to binary64 on a
mathematical or acceptance path. `double` conversion is reserved for optional
presentation plots.

The private interval layer checks its supported contract before operating:

```text
64 <= q <= 4096
finite MPFR/MPC point data
valid matrix dimensions and compatible shapes
domain/range preconditions for every elementary operation
```

Invalid data fails closed. A failed sufficient inequality is classified as
`INCONCLUSIVE`, not as proof that the input is singular or that no factor
exists.

## V1A: all singular values

For an economy factorization

```text
A = U*S*V'
```

the implementation forms interval enclosures for the target, the two Gram
defects, and the reconstruction defect. The method ID is
`svt_polar_weyl_v1`. A conservative factor perturbation radius `epsilon` is
then applied to each diagonal singular value:

```text
max(0, s_j - epsilon) <= sigma_j(A) <= s_j + epsilon
```

The calculation binds the enclosure to the same `A`, `U`, `S`, and `V` that
were measured. It checks finite data, economy shapes, diagonal/nonnegative/
descending `S`, and valid Gram defects before making the inclusion claim.

The singular-value target is resolved only when the lower endpoint is positive.
For a positive value, the width is compared relatively. A zero or unresolved
component uses the declared scale-aware absolute rule instead. A certified
interval may be broad; `CERTIFIED` and `meets_accuracy_target` are separate.

## V1B: cluster projectors

For a declared cluster of positive singular indices, the checker applies a
signed dilation argument. It considers both `+sigma` and `-sigma` and, for a
rectangular target, the structural zero eigenvalues of the dilation. It does
not divide by an internal cluster gap. Thus a repeated target group is valid
when the external signed-dilation separation is sufficient.

The method ID is `svt_dilation_projector_v1`. It returns separate left/right
projector radii and the certified external lower gap. A permutation or a
common orthogonal rotation inside a repeated group leaves the claim valid. A
rotation that mixes a target group with an exterior value must not receive a
certified result.

The full-space square branch is explicit: when the selected cluster exhausts
the dilation complement, the complementary bound is the zero interval rather
than an artificial division by zero.

## V2: compatible factor boxes

The method ID is `svt_dilation_factor_boxes_v1`. For positive, separated,
simple singular pairs it combines a factorization residual with the signed
dilation separation to produce conservative entrywise rectangles around the
left and right vectors. The implementation reports a common phase/sign
choice for a pair, because `u_j` and `v_j` may be changed together without
changing `u_j*s_j*v_j'`.

Changing only one side's phase is treated as incompatible. An exactly repeated
singular value does not receive an individual-vector certificate and is
reported as `UNSUPPORTED_MULTIPLICITY`; its cluster remains covered by V1B.
The boxes are norm-derived sufficient bounds, not the full componentwise
algorithm from the motivating literature.

## V3: inverse and spectral norm bound

The method ID is `svt_neumann_inverse_v1`. For a square target `A` and a public
solve output `X`, the checker forms an outward enclosure of

```text
R = I - A*X
```

and requires a certified norm upper bound `r < 1`. It also obtains a certified
upper bound for a norm of `X`. The Neumann argument then yields a finite
inverse-norm upper bound and the positive lower bound

```text
sigma_min(A) >= (1-r) / ||X||_upper
```

The exact norm constants and matrix-bound operations are implemented in the
private interval layer and are included in the certificate JSON. A zero or
poor approximate inverse cannot pass. Rectangular inverse requests return
`UNSUPPORTED_RECTANGULAR` because this baseline does not prove a pseudoinverse
claim.

## Exact replay and artifact binding

`svt_serialize_mp_array` writes every finite MPFR/MPC entry as exact signed
dyadic data with shape, precision, real/imaginary components, and a canonical
byte digest. `svt_dyadic_decode` reconstructs the value without decimal
round-tripping. `svt_replay_snapshots` checks the digest and reproduces the
stored target/factor records independently of the profile runner.

The required output files are versioned as `svt-v1`. Certificates contain the
method ID, status, preconditions, interval fields, target/factor identity, and
`paper_algorithm_reproduction=false`. The writer also emits display TSVs and
an environment record, but display decimals are not proof endpoints.

Coverage is checked independently by `svt_check_coverage`: every expected
`(case_id, mode, native, work_bits)` key must occur exactly once, and the row
count must equal the manifest calculation. Empty, missing, and duplicate rows
are rejection tests.

## Adversarial controls

The self-tests cover malformed shapes, negative or unordered singular values,
non-orthogonal factors, invalid cluster indices, external-gap collapse,
single-sided phase corruption, repeated factors, singular targets, poor
inverses, rectangular inverse requests, invalid interval domains, and exact
dyadic round trips. These controls exercise rejection paths; they do not
weaken the positive gate.

## Claim boundary

The verifier establishes only the finite inequalities represented by its
implemented baselines for the represented point matrix and factors. It does
not port all algorithms from Rump--Lange, Rump--Ogita, or Rump, does not claim
interval-input robustness beyond the point enclosures implemented here, and
does not certify an unresolved singular value as zero. See
`docs/codex/svt/VERIFICATION.md` for the normative formulas and
`docs/codex/svt/SOURCES.md` for source attribution.
