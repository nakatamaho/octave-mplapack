## SPDX-License-Identifier: BSD-2-Clause

function result = exp (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "exp expects one mp value");
  endif
  payload = __mplapack_core__ ("script_elementary", value, "exp");
  result = mp (0); result.payload_ = payload;
endfunction
