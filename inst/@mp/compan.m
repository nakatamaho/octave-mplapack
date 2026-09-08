## SPDX-License-Identifier: BSD-2-Clause

function result = compan (value)
  if (nargin != 1 || ! isa (value,"mp")), error ("mplapack:mp:InvalidInput", "compan expects an mp coefficient vector"); endif
  p=value(:); n=numel(p)-1;
  if (n < 1), result=zeros(0,0,"like",value); return; endif
  if (mp_element (p,1)==0), error ("mplapack:mp:InvalidInput", "compan requires a nonzero leading coefficient"); endif
  result=zeros(n,n,"like",value);
  for i=2:n, result=mp_put(result,i,i-1,1); endfor
  for j=1:n, result=mp_put(result,1,j,-mp_element (p,j+1)/mp_element (p,1)); endfor
endfunction
