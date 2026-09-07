## SPDX-License-Identifier: BSD-2-Clause

function result = floor (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "floor expects one mp value");
  endif
  result = value;
  result.payload_ = __mplapack_core__ ("script_round", value, "floor");
endfunction
