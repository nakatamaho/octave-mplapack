## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} expm (@dots{})
## Compute the supported arbitrary-precision result for the supplied @code{mp} inputs using the documented native backend or package-owned algorithm.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function result = expm (value)
  ## Matrix exponential by arbitrary-precision scaling and squaring with a
  ## precision-adaptive Taylor series.  This is distinct from element-wise
  ## exp and avoids a fixed-degree approximant at high MPFR precision.
  if (nargin != 1 || ! isa (value, "mp")), error ("mplapack:mp:InvalidInput", "expm expects one mp matrix"); endif
  [m,n] = size (value);
  if (m != n), error ("mplapack:mp:InvalidInput", "expm expects a square matrix"); endif
  if (m == 0), result = value; return; endif
  I = eye (m, n, "like", value);
  A = value;
  half = mp ("0.5");
  scale_count = 0;
  while (norm (A, 1) > half)
    A = A * half;
    scale_count = scale_count + 1;
  endwhile
  result = I;
  term = I;
  max_terms = 2 * mpdigits () + 32;
  for k = 1:max_terms
    ## k is an exactly representable loop counter, not a numerical result.
    term = (term * A) * (mp (1) / mp (double (k)));
    result = result + term;
    series_scale = norm (result, 1);
    if (series_scale < mp (1)), series_scale = mp (1); endif
    series_tol = mp (max (m,n)) * eps (series_scale);
    if (norm (term, 1) <= series_tol), break; endif
  endfor
  if (k == max_terms && norm (term, 1) > series_tol)
    error ("mplapack:mp:ConvergenceFailure", ...
           "expm Taylor series did not converge at source precision");
  endif
  for k = 1:scale_count
    result = result * result;
  endfor
endfunction
