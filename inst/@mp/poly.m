## SPDX-License-Identifier: BSD-2-Clause

function result = poly (value)
  if (nargin != 1 || ! isa (value,"mp")), error ("mplapack:mp:InvalidInput", "poly expects an mp vector or square matrix"); endif
  [m,n]=size(value);
  if (m==n && m>1)
    roots_value=eig(value,"vector");
  else
    roots_value=value(:);
  endif
  result=mp (1);
  for k=1:numel(roots_value)
    ## Coefficients are stored in descending powers: (z-r) = [1,-r].
    result=conv(result,[1,-mp_element(roots_value,k)]);
  endfor
  result = result.';
endfunction
