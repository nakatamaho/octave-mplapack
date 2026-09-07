## SPDX-License-Identifier: BSD-2-Clause

function result = logical (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "logical expects one mp value");
  endif
  result = ! __mplapack_core__ ("script_logical", value, "not");
endfunction
