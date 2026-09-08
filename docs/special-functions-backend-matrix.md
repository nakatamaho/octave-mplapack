# Special-function backend matrix

This audit records the special-function boundary for the T-series.  The
authoritative numerical backend is the frozen gmpfrxx_mkII 1.4.1 tree at
`32a7fb797202cdf92312ed9d133f96fdbcda590a` (`v1.4.1`).  A backend primitive is
not by itself a public `@mp` implementation: Octave's argument order,
normalization, tails, output count, domain behavior, and complex policy must
also be specified and tested before a wrapper is added.

| Family | Octave-facing API | gmpfrxx / MPFR evidence | Classification | T-series decision and TODO |
|---|---|---|---|---|
| Gamma | `gamma`, `gammaln`, `lgamma` | `gamma`, `lngamma`, `lgamma` | DIRECT-BACKEND | Implemented in T05 through the native precision-scoped bridge. |
| Error function | `erf`, `erfc` | `erf`, `erfc` | DIRECT-BACKEND | Implemented in T05; complex inputs remain explicitly rejected. |
| Digamma | `psi` | `digamma` | DIRECT-BACKEND | Primitive is available, but Octave's `psi` signature and floating-point input contract require a separate public mapping. TODO-T06-PSI. |
| Polygamma | `polygamma` (where available) | No MPFR/gmpfrxx primitive | DEFERRED-BACKEND | No package wrapper and no binary64 fallback. TODO-T06-POLYGAMMA: select and validate an arbitrary-precision algorithm. |
| Beta | `beta` | `beta` wrapping `mpfr_beta` | DIRECT-BACKEND | Primitive is available; public domain and pole semantics are not yet frozen. TODO-T06-BETA. |
| Log beta | `betaln` | No direct wrapper; can be formed from log-gamma | IMPLEMENTABLE-IN-PACKAGE | Feasible using precision-matched log-gamma identities, but requires a dedicated cancellation/domain test. TODO-T06-BETALN. |
| Incomplete gamma | `gammainc` | `gamma_inc` wrapping `mpfr_gamma_inc` | DIRECT-BACKEND | The primitive is not an automatic implementation: Octave's normalized lower/upper definitions and `tail` behavior must be matched exactly. TODO-T06-GAMMAINC. |
| Incomplete beta | `betainc` | No MPFR/gmpfrxx primitive | DEFERRED-BACKEND | Do not substitute complete beta or a double implementation. TODO-T06-BETAINC. |
| Inverse error family | `erfinv`, `erfcinv` | No direct MPFR/gmpfrxx wrapper | IMPLEMENTABLE-IN-PACKAGE | A published arbitrary-precision inverse-error algorithm could be added, with endpoint and signed-domain tests. Not implemented in T06. TODO-T06-INV-ERF. |
| Scaled error family | `erfcx` and related scaled variants | No direct MPFR/gmpfrxx wrapper | DEFERRED-BACKEND | Requires a region-partitioned arbitrary-precision algorithm; no fallback is permitted. TODO-T06-ERFCX. |
| Exponential integral | `expint` | `eint` | DIRECT-BACKEND | MPFR's `eint` primitive is present, but Octave's `expint` argument and branch/domain semantics need a separate mapping. TODO-T06-EXPINT. |
| Zeta | no standard Octave `@mp` mapping in this package | `zeta`, plus `zeta_ui` | DIRECT-BACKEND | Backend capability recorded; no public wrapper is added until an Octave API and domain contract exists. TODO-T06-ZETA. |
| Bessel J | `besselj` | `j0`, `j1` only | DIRECT-BACKEND (partial) | Only orders 0 and 1 exist in the backend surface; general order mapping is deferred. TODO-T06-BESSEL-J. |
| Bessel Y | `bessely` | `y0`, `y1` only | DIRECT-BACKEND (partial) | Only orders 0 and 1 exist in the backend surface; general order mapping is deferred. TODO-T06-BESSEL-Y. |
| Bessel I | `besseli` | No direct wrapper | DEFERRED-BACKEND | No arbitrary-precision backend primitive is available in the frozen dependency. TODO-T06-BESSEL-I. |
| Bessel K | `besselk` | No direct wrapper | DEFERRED-BACKEND | No arbitrary-precision backend primitive is available in the frozen dependency. TODO-T06-BESSEL-K. |
| Hankel | `besselh` | No direct wrapper | DEFERRED-BACKEND | Requires both a general J/Y implementation and a complex branch-cut contract. TODO-T06-HANKEL. |
| Airy | `airy` | `ai` only | DIRECT-BACKEND (partial) | The backend exposes Ai only, while Octave's API includes multiple outputs and Bi. No partial public wrapper is added. TODO-T06-AIRY. |

## Closed boundary

The package currently exposes only the T05 gamma/error-function family from
this matrix.  Calls to deferred or not-yet-mapped special-function APIs with
`mp` operands are rejected by the compatibility firewall; they do not pass
through Octave's binary64 implementation.  T06 therefore closes the audit and
does not add numerical production code.

The direct-backend entries are capability findings, not release claims.  Each
TODO names the semantic audit required before exposing that family through the
package.  In particular, `gamma_inc` is not treated as an implementation of
Octave `gammainc` merely because their names are similar.

## Provenance

The direct-wrapper inventory was audited in:

```text
/home/docker/work/gmpfrxx_mkII/include/gmpfrxx_mkII/detail/mpfr_impl.hpp
```

No raw MPFR call, builtin binary64 fallback, or change to the frozen
gmpfrxx_mkII dependency was made for T06.
