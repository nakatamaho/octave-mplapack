## SPDX-License-Identifier: BSD-2-Clause

function result = roots (value)
  if (nargin != 1 || ! isa (value,"mp")), error ("mplapack:mp:InvalidInput", "roots expects an mp coefficient vector"); endif
  p=value(:); while (numel(p)>1 && mp_element (p,1)==0), p=mp_slice (p,2:numel(p),1); endwhile
  if (numel(p)<=1), result=zeros(0,1,"like",value); return; endif
  result=eig(compan(p),"vector");
endfunction
