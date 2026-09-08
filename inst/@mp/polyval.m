## SPDX-License-Identifier: BSD-2-Clause

function result = polyval (coefficients, x, varargin)
  ## Horner evaluation of an arbitrary-precision coefficient vector.
  if (nargin < 2 || ! isa (coefficients, "mp")), error ("mplapack:mp:InvalidInput", "polyval requires an mp coefficient vector"); endif
  if (nargin > 3), error ("mplapack:mp:InvalidArguments", "unsupported polyval arguments"); endif
  if (numel (coefficients) == 0), result = mp (0); return; endif
  if (! isa (x, "mp")), x = mp (x); endif
  [m,n] = size (x);
  if (m == 1 && n == 1)
    result = mp_element (coefficients, 1);
    for k = 2:numel (coefficients)
      result = result*x + mp_element (coefficients, k);
    endfor
    return;
  endif
  template = x;
  if (! isreal (coefficients)), template = coefficients; endif
  result = zeros (m,n,"like",template);
  for j = 1:n
    for i = 1:m
      xi = mp_element (x,i,j);
      value = mp_element (coefficients, 1);
      for k = 2:numel (coefficients)
        value = value*xi + mp_element (coefficients, k);
      endfor
      result = mp_put (result,i,j,value);
    endfor
  endfor
endfunction
