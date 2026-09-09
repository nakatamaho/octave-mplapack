## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} sqrtm (@dots{})
## Compute the supported arbitrary-precision result for the supplied @code{mp} inputs using the documented native backend or package-owned algorithm.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function varargout = sqrtm (value)
  ## Principal matrix square root via a complex Schur form and triangular
  ## recurrence.  All matrix arithmetic remains in mp storage.
  if (nargin != 1 || ! isa (value, "mp")), error ("mplapack:mp:InvalidInput", "sqrtm expects one mp matrix"); endif
  [m,n] = size (value);
  if (m != n), error ("mplapack:mp:InvalidInput", "sqrtm expects a square matrix"); endif
  if (m == 0)
    result = value;
    if (nargout > 1), varargout{2} = mp (0); endif
    varargout{1} = result;
    return;
  endif
  [U,T] = schur (value, "complex");
  R = zeros (m,n, "like", T);
  for i = 1:m
    R = mp_put (R,i,i,sqrt (mp_element (T, i, i)));
  endfor
  for j = 2:n
    for i = j-1:-1:1
      correction = mp_element (T, i, j);
      for k = i+1:j-1
        correction = correction - mp_element (R, i, k)*mp_element (R, k, j);
      endfor
      denominator = mp_element (R, i, i) + mp_element (R, j, j);
      if (denominator == 0)
        error ("mplapack:mp:ConvergenceFailure", ...
               "sqrtm triangular recurrence encountered a singular branch");
      endif
      R = mp_put (R,i,j,correction / denominator);
    endfor
  endfor
  result = U * R * U';
  if (nargout > 1)
    varargout{2} = norm (result*result-value, "fro");
  endif
  varargout{1} = result;
endfunction
