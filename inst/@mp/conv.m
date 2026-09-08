## SPDX-License-Identifier: BSD-2-Clause

function result = conv (a, b, varargin)
  if (nargin != 2 || ! isa (a, "mp")), error ("mplapack:mp:InvalidInput", "conv requires an mp first vector"); endif
  if (! isa (b,"mp")), b = mp (b); endif
  if (numel (a) == 0 || numel (b) == 0), result = zeros (0,1,"like",a); return; endif
  template = a; if (!isreal (b)), template=b; endif
  result = zeros (numel(a)+numel(b)-1,1,"like",template);
  for i = 1:numel(a)
    for j = 1:numel(b)
      result = mp_put (result, i+j-1, 1, ...
                       mp_element (result,i+j-1) + mp_element (a, i)*mp_element (b, j));
    endfor
  endfor
  [m,n] = size(a); if (m == 1 && n != 1), result = result.'; endif
endfunction
