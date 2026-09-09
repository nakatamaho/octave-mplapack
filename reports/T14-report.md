# T14 report — optimization core

## Result

`T14 PASS — OPTIMIZATION CORE CLOSED`

`fminbnd PASS`
`fminsearch PASS`
`fminunc DEFERRED`

## Implementation

`fminbnd` is a bounded MP golden-section minimizer with p-aware defaults and
MP objective/coordinate arithmetic.  `fminsearch` is a practical MPFR
Nelder-Mead implementation with Octave-style result metadata and common
termination options.  No builtin binary64 callback or optimizer fallback is
used.

The focused QA covered a quadratic, the Rosenbrock valley, a badly scaled
two-variable objective, and a 512-bit bounded optimum at `1 + 2^-700`, which
converts to the same binary64 value as `1`.

## Scope

Real scalar objectives are required.  Complex objectives, builtin double
callback results, output callbacks, and plot callbacks are rejected.  The
gradient-based `fminunc` design is deferred and recorded in
`docs/todo/T14-fminunc.md`.

## Controller metadata

| Field | Value |
|---|---|
| Repository / branch | `octave-mplapack` / `topic/t00-t14-continuation` |
| Starting commit | `3f878016dea4d7de372c83d0f5554f6c64a48c93` |
| Implementation / tip | `ec3275a305dbc1c25cc8041d887a95d8e9f2e5e7`; report `11bb012a285884ecd90cd9dbe32f400d5d34d703`; CI `246f9dafe3a1576172315c7b6667aeb44a3a1e4e` |
| D03 baseline | `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31` / `v0.4.0` |
| Dependencies / Octave | gmpfrxx `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1`; MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`; GNU Octave 11.1.0 |
| API / backend | `fminbnd`, `fminsearch`; MPFR golden-section and Nelder–Mead |
| Precision / behavior | coordinates, objectives, steps, tolerances, and stopping are MPFR; real objectives only, no binary64 fallback |
| Octave QA / 1024-2048 | quadratic, Rosenbrock, badly scaled, options/metadata, and `1+2^-700`; controller canaries PASS |
| Sanitizers / previous regression | ASan/UBSan/LSan PASS; T00–T13 and D03 walls retained |
| Status / TODO | PASS; `fminunc`: `docs/todo/T14-fminunc.md` |
