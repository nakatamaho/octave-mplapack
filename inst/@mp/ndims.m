## SPDX-License-Identifier: BSD-2-Clause

function count = ndims (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "ndims expects one mp value");
  endif
  count = 2;
endfunction
