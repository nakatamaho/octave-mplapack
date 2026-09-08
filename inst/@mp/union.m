## SPDX-License-Identifier: BSD-2-Clause

function varargout = union (a, b, varargin)
  if (nargin < 2 || ! isa (a, "mp"))
    error ("mplapack:mp:InvalidInput", "union requires an mp first operand");
  endif
  if (! isa (b, "mp")), b = mp (b); endif
  stable = mp_set_has_option (varargin, "stable");
  rows_mode = mp_set_has_option (varargin, "rows");
  if (rows_mode)
    [ma,na] = size (a); [mb,nb] = size (b);
    if (na != nb), error ("mplapack:mp:InvalidInput", "union rows require matching columns"); endif
    combined = zeros (ma+mb,na,"like",a);
    if (isreal (a) && !isreal (b)), combined=zeros(ma+mb,na,"like",b); endif
    for i=1:ma, for j=1:na, combined=mp_put(combined,i,j,mp_element(a,i,j)); endfor, endfor
    for i=1:mb, for j=1:nb, combined=mp_put(combined,ma+i,j,mp_element(b,i,j)); endfor, endfor
    [values, first, inverse] = mp_set_unique_rows (combined, stable);
    na_index = ma;
  else
    combined = mp_set_concat_columns (a,b);
    [values, first, inverse] = mp_set_unique (combined, stable);
    na_index = numel (a);
  endif
  [ma,na] = size (a); [mb,nb] = size (b);
  if (! rows_mode && ma == 1 && na != 1 && mb == 1 && nb != 1)
    values = values.';
  endif
  varargout{1} = values;
  if (nargout > 1)
    varargout{2} = first(first <= na_index);
  endif
  if (nargout > 2)
    varargout{3} = first(first > na_index) - na_index;
  endif
endfunction
