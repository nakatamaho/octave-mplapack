## SPDX-License-Identifier: BSD-2-Clause

function count = ndims (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{n} =} ndims (@var{A})
  ## Return two for every supported dense matrix @code{mp} value.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "ndims expects one mp value");
  endif
  count = 2;
endfunction
