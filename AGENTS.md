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
