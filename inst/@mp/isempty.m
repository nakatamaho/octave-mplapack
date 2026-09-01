## SPDX-License-Identifier: BSD-2-Clause

function result = isempty (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "isempty expects one mp value");
  endif
  info = __mplapack_core__ ("value_shape_info", value);
  result = logical (info.is_empty);
endfunction
