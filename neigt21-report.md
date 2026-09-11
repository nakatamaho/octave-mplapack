# NEIGT21 report — positive Perron root and normalized pair

NEIGT21 implements the conservative baselines
`neigt_collatz_wielandt_v1` and `neigt_positive_pair_contraction_v1`.
The mandatory matrices are checked as real MP inputs.  Their strict positive
entry graph proves irreducibility directly; no observed dominant eigenvalue
is used as a structural argument.

For a computed positive trial vector, interval ratios `(A*x)_i/x_i` give the
outward Collatz--Wielandt root interval.  Independently, the normalized
nonlinear system

```text
F(x,lambda) = [A*x-lambda*x; sum(x)-1]
```

is enclosed on a real box.  A public solve supplies the point inverse of the
Jacobian, and the fixed four-trial dyadic schedule checks
`upper(||R*F(y0)||inf + ||I-R*J(Y)||inf*t) < t`, contraction, and strict
positivity.  The resulting fixed point proves a positive normalized Perron
pair.  The Collatz interval and pair lambda interval must intersect.

Left eigenvectors are prepared independently from `eig(A')`, normalized by
`w'*x=1`, and their original-A residual is recorded.  For stochastic jobs an
additional independently normalized linear solve records the nontrivial
stationary vector; this is especially important for the P′ right vector.

## NEIGT21 gate

Command:

```text
timeout 1800s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private --path test \
  --eval 'test_neigt21();' |& tee /tmp/neigt21-gate-5.log
```

Result:

```text
PASS: NEIGT21 positive graph, Collatz--Wielandt, Perron pair, stationary vector, and fail-closed negatives
```

The negative gate cases include a negative entry, a reducible nonnegative
matrix, a nonpositive trial vector, and a doubled otherwise-valid Jacobian
inverse candidate.  All fail closed without a positive-pair claim.

## Measured smoke jobs

Source/evaluation precision was 256/768 bits.  The four jobs produced:

| Job | status | Collatz lower | Collatz width | pair | left residual upper | independent stationary |
|---|---|---:|---:|---|---:|---|
| VA3-01 P | `CERTIFIED_PERRON_PAIR` | `1` | `1.1828559e-76` | pass | `3.5928853e-76` | pass |
| VA3-02 P′ | `CERTIFIED_PERRON_PAIR` | `1` | `2.5181083e-76` | pass | `2.0929375e-76` | pass |
| VA3-03 PERRON_POS | `CERTIFIED_PERRON_PAIR` | `1.5` | `1.4645644e-75` | pass | `1.6761898e-74` | not applicable |
| VA3-04 PERRON_POS′ | `CERTIFIED_PERRON_PAIR` | `1.5` | `9.5872076e-76` | pass | `4.8792336e-75` | not applicable |

All four inputs were strictly positive and irreducible by the positive-entry
graph, all pair boxes had strict positive components, all root intervals had
positive lower endpoints and passed the fixed `2^-64` width target, and all
left residual bounds passed the same target.  P/P′ stationary vectors were
independently normalized and had residuals below the 256-bit `2^-64` target.

## V-A integration

The final all-V-A integration command and its complete 10-job result are
recorded in `/tmp/neigt21-integration-1.log`:

```text
status=COMPLETE ok=1 jobs=10 implemented=10 va1=3 va1complete=1 va2=3 va2complete=1 va3=4 va3complete=1
VA1-01..03: pass=1
VA2-01..03: pass=1
VA3-01..04: pass=1
```

NEIGT21 is the first point at which VA1, VA2, and VA3 are all implemented;
the runner therefore reports `COMPLETE`, `ok=1`, and `implemented=10`.

## Implementation and provenance

Files changed:

```text
examples/neig_tiers/private/net_v_a3_collatz.m
examples/neig_tiers/private/net_v_a3_pair.m
examples/neig_tiers/private/net_v_a3_job.m
examples/neig_tiers/private/net_v_a3_collatz.m
examples/neig_tiers/private/net_v_a3_pair.m
examples/neig_tiers/mp_neig_verify_examples.m
test/test_neigt21.m
neigt21-report.md
```

No dependency headers, MPLAPACK, MPFR/MPC, public `mp` API, compiler
semantics, or binary64 fallback changed.  Stress: NOT_RUN.  Plotting:
NOT_RUN.  Push, merge, tag, and publication: NOT_PERFORMED.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `423ab12` (NEIGT20 report-record state)
Final implementation commit: `69a10a6`
Gate: PASS
VA3: PASS, 4/4
V-A integration: PASS, complete 10/10 jobs

Known limitation: this is the specified conservative positive-Perron baseline;
it does not certify a second eigenvalue or spectral gap.  That remains a
separate V-S1 claim and no Perron-only observation is promoted to such a
claim.
