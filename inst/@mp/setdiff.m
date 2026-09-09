## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} setdiff (@dots{})
## Perform the supported dense arbitrary-precision polynomial or set operation with package-owned @code{mp} values and documented conditioning/ordering rules.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function varargout = setdiff (a, b, varargin)
  if (nargin < 2 || ! isa (a, "mp")), error ("mplapack:mp:InvalidInput", "setdiff requires mp input"); endif
  if (! isa (b, "mp")), b = mp (b); endif
  stable = mp_set_has_option (varargin, "stable");
  rows_mode = mp_set_has_option (varargin, "rows");
  if (rows_mode)
    [ma,na] = size(a); [mb,nb] = size(b);
    if (na != nb), error ("mplapack:mp:InvalidInput", "setdiff rows require matching columns"); endif
    [candidate, first] = mp_set_unique_rows(a,stable);
    keep=true(rows(candidate),1);
    for i=1:rows(candidate)
      for j=1:mb
        if (mp_rows_equal(candidate,i,b,j)), keep(i)=false; break; endif
      endfor
    endfor
    varargout{1}=mp_slice(candidate,find(keep),1:na);
  else
    [candidate, first] = mp_set_unique (a, stable);
    candidate_column=mp_column(candidate); bc=mp_column(b);
    keep=true(numel(candidate_column),1);
    for i=1:numel(candidate_column)
      for j=1:numel(bc)
        if (isequaln(mp_element(candidate_column,i),mp_element(bc,j))), keep(i)=false; break; endif
      endfor
    endfor
    varargout{1}=mp_slice(candidate_column,find(keep),1);
    [ma,na]=size(a); if (ma==1 && na!=1), varargout{1}=varargout{1}.'; endif
  endif
  if (nargout > 1), varargout{2}=first(keep); endif
endfunction
