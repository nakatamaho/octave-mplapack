# T06 TODO — remaining special-function families

This document is the re-entry record for every deferred `TODO-T06-*` entry
in `docs/special-functions-backend-matrix.md`.

## Common fields

- **Scope:** expose the named Octave special-function family for dense MP
  values.
- **Why deferred:** a backend primitive alone does not establish Octave
  argument order, normalization, tails, output count, domains, branches, or
  complex behavior.
- **Current evidence:** T05 `gamma`, `gammaln`, `lgamma`, `erf`, and `erfc`
  are closed; all other listed families remain firewall-rejected and have no
  binary64 fallback.
- **Required dependency/algorithm:** use the frozen gmpfrxx/MPFR primitive
  where its semantics match, or add a reviewed arbitrary-precision algorithm;
  raw double implementations are forbidden.
- **Public API target:** Octave-compatible wrapper with explicit real/complex
  and domain semantics for each family.
- **Precision requirements:** one-operation/one-precision MPFR/MPC scope,
  p-aware stopping/error estimates, and 1024/2048-bit canaries where useful.
- **Test requirements:** signature/output count, domains, poles, NaN/Inf,
  signed zero, branch cuts, high precision, ambient scope, and sanitizers.
- **Re-entry milestone:** a future special-functions milestone after T06;
  none is part of T00–T14.

## Family-specific contracts

### `psi` — `TODO-T06-PSI`

Map Octave's `psi` signatures to the native `digamma` wrapper, including
integer/order forms if exposed by Octave, real poles, complex policy, and
output precision.

### `polygamma` — `TODO-T06-POLYGAMMA`

Select a reviewed arbitrary-precision recurrence/asymptotic or backend
dependency for arbitrary order and validate poles and complex arguments.

### `beta` — `TODO-T06-BETA`

Define public domain/pole behavior and cancellation-safe native evaluation for
the available `mpfr_beta` primitive.

### `betaln` — `TODO-T06-BETALN`

Use precision-matched log-gamma identities with tests for cancellation,
negative arguments, poles, and Octave output conventions.

### `gammainc` — `TODO-T06-GAMMAINC`

Map `gamma_inc` to normalized lower/upper incomplete gamma semantics and
Octave's `tail` option; do not equate names without these tests.

### `betainc` — `TODO-T06-BETAINC`

Choose and validate a native arbitrary-precision incomplete-beta algorithm,
including complement and endpoint stability.

### `erfinv`/`erfcinv` — `TODO-T06-INV-ERF`

Add a reviewed inverse-error algorithm with endpoint, signed-domain, and
complex-domain policy tests.

### `erfcx` — `TODO-T06-ERFCX`

Add a region-partitioned scaled-error algorithm stable in both tails.

### `expint` — `TODO-T06-EXPINT`

Map MPFR `eint` to Octave's argument, branch, and domain semantics.

### `zeta` — `TODO-T06-ZETA`

Define a public Octave mapping and real/complex domain contract for `zeta` and
`zeta_ui`.

### Bessel J/Y — `TODO-T06-BESSEL-J`, `TODO-T06-BESSEL-Y`

Extend the available order-0/order-1 primitives or select a reviewed
general-order arbitrary-precision algorithm.

### Bessel I/K — `TODO-T06-BESSEL-I`, `TODO-T06-BESSEL-K`

Provide and validate arbitrary-precision modified-Bessel algorithms; no
binary64 bridge is acceptable.

### Hankel — `TODO-T06-HANKEL`

Define general J/Y composition and complex branch-cut behavior.

### Airy — `TODO-T06-AIRY`

Define whether Ai-only backend support is sufficient; otherwise implement the
full Octave output/Bi contract at arbitrary precision.
