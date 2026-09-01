## SPDX-License-Identifier: BSD-2-Clause

function count = columns (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "columns expects one mp value");
  endif
  info = __mplapack_core__ ("value_shape_info", value);
  count = double (info.columns);
endfunction
