## SPDX-License-Identifier: BSD-2-Clause

function varargout = setxor (a, b, varargin)
  if (nargin < 2 || ! isa (a, "mp")), error ("mplapack:mp:InvalidInput", "setxor requires mp input"); endif
  if (! isa (b, "mp")), b = mp (b); endif
  stable = mp_set_has_option (varargin, "stable");
  rows_mode = mp_set_has_option (varargin, "rows");
  if (rows_mode)
    [left,left_i]=setdiff(a,b,varargin{:}); [right,right_i]=setdiff(b,a,varargin{:});
    [ml,nl]=size(left); [mr,nr]=size(right);
    combined=zeros(ml+mr,nl,"like",a); if(isreal(a)&&!isreal(b)),combined=zeros(ml+mr,nl,"like",b);endif
    for i=1:ml,for j=1:nl,combined=mp_put(combined,i,j,mp_element(left,i,j));endfor,endfor
    for i=1:mr,for j=1:nr,combined=mp_put(combined,ml+i,j,mp_element(right,i,j));endfor,endfor
    [values,first,inverse]=mp_set_unique_rows(combined,stable);
    varargout{1}=values;
    if(nargout>1),varargout{2}=left_i(first(first<=ml));endif
    if(nargout>2),varargout{3}=right_i(first(first>ml)-ml);endif
  else
    [left,left_i]=setdiff(a,b,varargin{:}); [right,right_i]=setdiff(b,a,varargin{:});
    combined=mp_set_concat_columns(left,right);
    [values,first,inverse]=mp_set_unique(combined,stable);
    [ma,na]=size(a);[mb,nb]=size(b);
    if(ma==1&&na!=1&&mb==1&&nb!=1),values=values.';endif
    varargout{1}=values;
    if(nargout>1),varargout{2}=left_i(first(first<=numel(left)));endif
    if(nargout>2),varargout{3}=right_i(first(first>numel(left))-numel(left));endif
  endif
endfunction
