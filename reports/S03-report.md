# S03 report — comparisons, logicals, and logical indexing

## Result

```text
S03 PASS — COMPARISONS, LOGICALS, AND LOGICAL INDEXING CLOSED
```

Implementation commits: `a71c13f` (native bridge) and `5714787` (public
wrappers).

## Public API

```text
real comparisons: PASS — ==, ~=, <, <=, >, >= with scalar expansion
complex equality: PASS — == and ~= compare native MPFR real/imag components
complex ordered comparison: PASS — rejected with an explicit compatibility error
logical conversion: PASS — native MPFR/MPC zero/nonzero classification
logical operators: PASS — &, |, xor, and unary ~
logical reductions: PASS — any/all with dimensions and "all"
find: PASS — linear, row/column, three-output, count, and first/last forms
numeric linear indexing: PASS — vector reads and assignments
logical indexing: PASS — reads and value-semantic assignments
```

## Precision and implementation

Comparison and logical operands are converted into operation-owned MPFR/MPC
storage only when a builtin operand must be introduced. Stored `mp` values are
read directly at their native precision, and mixed complex operations use the
maximum participating `mp` precision. The result of a comparison or logical
operation is a builtin logical array, as required by ordinary Octave scripts;
selected `find` values remain native `mp` values.

Complex equality tests both MPFR components and treats NaN as unequal. Complex
ordered comparisons are deliberately rejected because MPC has no Octave
ordering relation. Logical truth is native zero/nonzero classification, so
NaN is true and a complex value is true when either component is nonzero.
Index selection follows column-major ordering and assignments retain copied
MPFR/MPC value semantics.

No S03 path routes real operations through a complex kernel and no path uses
builtin binary64 arithmetic as a numerical fallback.

## Tests and gates

```text
test/script-compat/s03.tst: PASS
real comparisons/logicals/indexing: PASS
complex equality/logicals/find: PASS
complex ordered-comparison firewall: PASS
numeric vector indexing and assignment: PASS
1024-bit canary: PASS
2048-bit canary: PASS
ambient precision isolation: PASS
```

```text
G-S03-COMPARE: PASS
G-S03-COMPLEX-EQUALITY: PASS
G-S03-ORDER-FIREWALL: PASS
G-S03-LOGICAL: PASS
G-S03-ANY-ALL: PASS
G-S03-FIND: PASS
G-S03-INDEX: PASS
G-S03-ASSIGNMENT: PASS
G-S03-PRECISION: PASS
G-S03-REGRESSION: PASS
```

The active package metadata remains `0.4.0-dev`; D03 owns the final source
version freeze. The immutable `v0.3.1` source and frozen dependency stack are
unchanged.
