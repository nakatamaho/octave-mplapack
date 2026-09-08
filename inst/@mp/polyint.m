## SPDX-License-Identifier: BSD-2-Clause

function result = polyint (value, varargin)
  if (nargin < 1 || nargin > 2 || ! isa (value,"mp")), error ("mplapack:mp:InvalidInput", "polyint expects an mp coefficient vector and optional constant"); endif
  if (nargin==2), constant=varargin{1}; if (!isa(constant,"mp")), constant=mp(constant); endif; else, constant=mp(0); endif
  result=zeros(numel(value)+1,1,"like",value);
  for k=1:numel(value)
    result=mp_put(result,k,1,mp_element (value,k)/(numel(value)-k+1));
  endfor
  result=mp_put(result,numel(value)+1,1,constant);
  [m,n]=size(value); if (m==1 && n!=1), result=result.'; endif
endfunction
