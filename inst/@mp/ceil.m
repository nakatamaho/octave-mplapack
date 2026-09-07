## SPDX-License-Identifier: BSD-2-Clause

function result = ceil (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "ceil expects one mp value");
  endif
  result = value;
  result.payload_ = __mplapack_core__ ("script_round", value, "ceil");
endfunction
