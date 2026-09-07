## SPDX-License-Identifier: BSD-2-Clause

function result = not (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "not expects one mp value");
  endif
  result = __mplapack_core__ ("script_logical", value, "not");
endfunction
