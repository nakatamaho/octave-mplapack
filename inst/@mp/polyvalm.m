## SPDX-License-Identifier: BSD-2-Clause

function result = polyvalm (coefficients, value)
  if (nargin != 2 || ! isa (coefficients, "mp") || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "polyvalm expects mp coefficients and an mp square matrix");
  endif
  [m,n] = size (value);
  if (m != n), error ("mplapack:mp:InvalidInput", "polyvalm expects a square matrix"); endif
  if (numel (coefficients) == 0), result = zeros (m,n,"like",value); return; endif
  result = mp_element (coefficients, 1) * eye (m,n,"like",value);
  for k = 2:numel (coefficients)
    result = result*value + mp_element (coefficients, k)*eye (m,n,"like",value);
  endfor
endfunction
