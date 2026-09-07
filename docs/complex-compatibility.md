# Complex compatibility and limits

The tested public runtime is GNU Octave 11.1.0 with the dense `mp` class and
the controlled reference `mplapack_mpfr` backend. Supported syntax follows
the forms listed in [`complex-api.md`](complex-api.md).

Mixed operations promote when at least one operand is an `mp` value and any
complex participant selects the MPC implementation. A builtin complex double
may participate in mixed arithmetic, multiplication, solve, concatenation,
and assignment; it is converted into the operation precision. A pair of raw
builtin complex doubles remains an Octave operation and is outside this
package's arbitrary-precision contract.

The following complex operations are intentionally rejected by the package's
compatibility firewall. They must fail cleanly without conversion to a
binary64 result, crash, or recursive dispatch:

- `eig`, `svd`, `det`, `inv`, `rank`, and `cond`;
- `sin`, `exp`, `sqrt`, and other unimplemented transcendentals;
- power (`^` and `.^`), ordered comparisons, equality/logical operations,
  sparse conversion, and right division;
- sparse matrices, N-dimensional matrices, growth/deletion assignment, and
  unsupported cell/text matrix forms.

The package does not claim identical error text to builtin Octave. It does
claim stable package-owned rejection behavior for the audited unsupported
surface and no implicit binary64 fallback. Public LU follows real M21 and has
no separate status output; native `Cgetrf INFO` is checked, and singular
partial factors are preserved.

N00 adds arbitrary-precision `norm` for real and complex vectors and dense
matrices. Supported forms and deferred matrix p/options are documented in
[`norm.md`](norm.md); the implementation uses MPFR/MPC-native absolute values,
`Rlange`/`Clange`, `Rnrm2`/`RCnrm2`, and `Rgesvd`/`Cgesvd`.

## Lifecycle

The native module is locked while public values or registered native types are
live. Public values remain valid across ordinary clear and package unload/
reload tests. Reinstallation is tested with the same real and complex smoke
operations. The controlled installation uses only the reference MPFR backend;
optimized complex workers are not claimed.
