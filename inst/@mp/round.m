## SPDX-License-Identifier: BSD-2-Clause

function result = round (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "round expects one mp value");
  endif
  result = value;
  result.payload_ = __mplapack_core__ ("script_round", value, "round");
endfunction
