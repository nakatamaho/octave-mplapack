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
