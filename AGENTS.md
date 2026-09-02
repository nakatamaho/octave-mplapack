# Repository instructions

These rules apply throughout this repository.

## Milestone discipline

1. Work one milestone at a time.
2. Read the active milestone before editing.
3. Do not implement later milestones opportunistically.
4. Every milestone ends with its explicit gate result.
5. A failed gate means the milestone is not complete.

## MPLAPACK boundaries

6. Never modify upstream MPLAPACK from this repository.
7. Never copy MPLAPACK implementation source into this repository.
8. Discover installed MPLAPACK through `pkg-config`.
9. Do not hard-code a developer-specific MPLAPACK path.
10. MPFR is the only numerical backend through M10.
11. Complex arithmetic is out of scope through M10.

## Octave boundaries

12. Do not replace Octave's system BLAS or LAPACK.
13. Do not use `LD_PRELOAD` as the architecture.
14. Public APIs should follow normal Octave syntax.
15. Internal native APIs must not become public accidentally.
16. Inspect the actual installed Octave extension API before committing to
    custom native-value mechanics.

## Precision

17. `docs/precision-semantics.md` is normative.
18. String and double constructors are semantically distinct.
19. Do not silently reduce multiprecision values to `double`.
20. Existing values must not silently change precision when the default
    changes.
21. Mixed-precision semantics must be explicit and tested.

## C++

22. C++ source and comments must be in English.
23. Use RAII.
24. Do not expose raw pointers to Octave code.
25. Do not use integerized pointer handles.
26. Avoid global mutable state except the deliberately defined default
    precision configuration.
27. Numerical code must have automated tests.
28. Memory ownership paths must have QA.

## Numerical backend evidence

29. Every BLAS/LAPACK-backed feature must provide evidence that the intended
    MPLAPACK backend path is exercised.
30. Do not fake backend tests using ordinary Octave double arithmetic.
31. Do not reimplement established MPLAPACK algorithms inside the binding
    merely to avoid linkage problems.

## Build and CI

32. Do not hide failures with `continue-on-error`.
33. Do not claim missing mandatory dependencies as PASS.
34. Use deterministic tests where practical.
35. Keep compatibility code localized.
36. Update documentation whenever public behavior changes.

## Native value invariants

37. Native Octave payloads are immutable.
38. Native storage ownership remains RAII-based with explicit per-object
    precision.
39. Public values must never expose raw native pointers or integerized pointer
    handles.
40. The native module must remain safe and resident while registered native
    type metadata or values may depend on it.
41. Destructive LAPACK calls must use operation-owned copies rather than
    mutate shared public values.
42. Do not represent dense `mp` matrices as arrays or cells of scalar `mp`
    wrapper objects.
43. Dense matrix representation, matrix construction, and matrix shape are
    owned by M07.
44. Bits are the canonical precision unit.
45. There is exactly one project-owned default precision state.
46. Public precision changes affect only subsequently constructed values.
47. Do not use MPFR's global default precision as project semantics.
48. `mpdigits(n)` maps to `ceil(n * log2(10))` bits with no hidden guard bits.
49. A fresh Octave process starts with a 512-bit project default.
50. `char(mp)` must format the native value without converting through
    binary64.
51. Explicit `double(mp)` uses MPFR round-to-nearest, ties-to-even.
52. `disp(mp)` must not silently reduce precision.
53. Scalar formatting uses the object's precision, not the current default.
54. Conversion methods must not mutate an `mp` value or the default precision.
55. Explicit `double(mp)` must not enable implicit arithmetic fallback.
56. Scalar arithmetic never uses the current default precision for result
    selection.
57. Scalar `mp`/`mp` result precision is `max(lhs, rhs)`.
58. Scalar `mp`/`double` result precision is the `mp` operand precision.
59. Arithmetic operands remain immutable, and results must not be constructed
    through text or binary64 round trips.
60. `*` is implemented in M08 only for supported native MPFR scalar, dense
    matrix, and scalar-scaling paths; `Rgesv` remains reserved for M09.
61. A dense `mp` matrix is one native dense payload, never an array or cell of
    scalar `mp` wrappers.
62. Dense matrix storage is contiguous and column-major, with one uniform
    explicit precision for every element.
63. Dense storage must be directly compatible with MPLAPACK MPFR `REAL *`
    without packing or pointer reinterpretation.
64. Dense public payloads remain immutable; destructive native algorithms use
    deep operation-owned copies.
65. Public matrix indexing is not implemented in M07.
66. Nondegenerate dense matrix `*` must use MPLAPACK MPFR `Rgemm` under one
    uniform operation precision; dense square `\` uses `Rgesv` in M09.

## Required final milestone report

End every milestone report with:

```text
Branch:
Starting commit:
Final commit:
Files changed:
Commands run:
Tests:
Gate:
Known limitations:
```
