## SPDX-License-Identifier: BSD-2-Clause

function varargout = ismember (a, b, varargin)
  if (nargin < 2 || ! isa (a, "mp")), error ("mplapack:mp:InvalidInput", "ismember requires an mp first operand"); endif
  if (! isa (b, "mp")), b = mp (b); endif
  rows_mode = mp_set_has_option (varargin, "rows");
  if (rows_mode)
    [ma,na]=size(a); [mb,nb]=size(b);
    if (na != nb), error ("mplapack:mp:InvalidInput", "ismember rows require matching columns"); endif
    tf=false(ma,1); location=zeros(ma,1);
    for i=1:ma
      for j=1:mb
        if (mp_rows_equal(a,i,b,j)), tf(i)=true; location(i)=j; break; endif
      endfor
    endfor
  else
    tf = false (numel (a), 1); location = zeros (numel (a), 1);
    af = mp_column (a); bf = mp_column (b);
    for i = 1:numel (af)
      for j = 1:numel (bf)
        if (isequal (mp_element (af,i), mp_element (bf,j)))
          tf(i) = true; location(i) = j; break;
        endif
      endfor
    endfor
    [m,n] = size (a);
    if (m == 1 && n != 1), tf = tf.'; location = location.'; endif
  endif
  varargout{1} = tf;
  if (nargout > 1), varargout{2} = location; endif
endfunction
