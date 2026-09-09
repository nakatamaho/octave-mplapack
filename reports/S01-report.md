# S01 report — element-wise power and elementary functions

## Result

```text
S01 PASS — ELEMENT-WISE POWER AND ELEMENTARY FUNCTIONS CLOSED
```

## Public API

```text
power/.^: PASS — real/complex, mixed builtin operands, singleton expansion
mpower/^: PASS — scalar power and integer square-matrix powers
matrix power 0/positive/negative: PASS
sqrt exp expm1 log log1p log10 log2: PASS
sin cos tan asin acos atan: PASS
sinh cosh tanh asinh acosh atanh: PASS
cbrt: PASS — real and complex native paths
```

## Domain and precision contract

Real-domain operations use MPFR directly. `sqrt`, `log`, `log1p`, `asin`,
`acos`, `acosh`, and `atanh` promote a domain-crossing real result to MPC;
complex inputs use MPC directly. All outputs retain the maximum operand
precision, temporary MPC values are protected by `MpfrMpcPrecisionScope`,
and operation-owned storage is returned. No numerical path uses builtin
binary64 arithmetic.

## Tests

```text
test/script-compat/s01.tst: PASS
scalar/matrix/mixed power: PASS
matrix exponentiation by squaring and inverse: PASS
real and complex elementary family: PASS
positive-real asin/acos branch fixtures: PASS
exp(log(x)) and trigonometric family smoke: PASS
1024-bit / 1e-211 tail: PASS
2048-bit / 1e-451 tail: PASS
ambient precision independence: PASS
```

The S01 test uses builtin double only as a low-precision oracle for selected
small fixtures; the implementation under test remains entirely MPFR/MPC.

## Gates

```text
G-S01-POWER: PASS
G-S01-MPOWER: PASS
G-S01-EXPLOG: PASS
G-S01-TRIG: PASS
G-S01-HYPERBOLIC: PASS
G-S01-DOMAIN-PROMOTION: PASS
G-S01-COMPLEX-BRANCH: PASS
G-S01-BROADCAST: PASS
G-S01-PRECISION: PASS
G-S01-REGRESSION: PASS
```

The pre-S01 firewall expectations for unimplemented elementary functions and
power were updated to the now-supported behavior; comparison, logical,
sparse, and other deferred boundaries remain rejected.
