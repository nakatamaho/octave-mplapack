## SPDX-License-Identifier: BSD-2-Clause

function result = cbrt (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "cbrt expects one mp value");
  endif
  payload = __mplapack_core__ ("script_elementary", value, "cbrt");
  result = mp (0); result.payload_ = payload;
endfunction
