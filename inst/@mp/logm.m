## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} logm (@dots{})
## Compute the supported arbitrary-precision result for the supplied @code{mp} inputs using the documented native backend or package-owned algorithm.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function varargout = logm (value)
  ## Principal matrix logarithm using inverse scaling by repeated matrix
  ## square roots followed by the Mercator series.  The square roots and
  ## series terms are arbitrary-precision matrix operations.
  if (nargin != 1 || ! isa (value, "mp")), error ("mplapack:mp:InvalidInput", "logm expects one mp matrix"); endif
  [m,n] = size (value);
  if (m != n), error ("mplapack:mp:InvalidInput", "logm expects a square matrix"); endif
  if (m == 0), result = value; varargout{1} = result; return; endif
  [U,T] = schur (value, "complex");
  I = eye (m,n,"like",T);
  Y = T;
  scale_count = 0;
  while (norm (Y-I, 1) > mp ("0.25"))
    Y = sqrtm (Y);
    scale_count = scale_count + 1;
    if (scale_count > 64)
      error ("mplapack:mp:ConvergenceFailure", "logm inverse scaling did not converge");
    endif
  endwhile
  X = Y-I;
  term = X;
  L = X;
  max_terms = 2 * mpdigits () + 32;
  for k = 2:max_terms
    term = term * X;
    ## k is an exactly representable loop counter, not a numerical result.
    signed_term = term / mp (double (k));
    if (mod (k,2) == 0), L = L - signed_term; else L = L + signed_term; endif
    series_scale = norm (L, 1);
    if (series_scale < mp (1)), series_scale = mp (1); endif
    series_tol = mp (max (m,n)) * eps (series_scale);
    if (norm (signed_term, 1) <= series_tol), break; endif
  endfor
  factor = mp (2)^scale_count;
  result = U * (factor*L) * U';
  if (nargout > 1), varargout{2} = norm (expm (result)-value, "fro"); endif
  varargout{1} = result;
endfunction
