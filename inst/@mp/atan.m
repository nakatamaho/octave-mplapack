## SPDX-License-Identifier: BSD-2-Clause

function result = atan (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "atan expects one mp value");
  endif
  payload = __mplapack_core__ ("script_elementary", value, "atan");
  result = mp (0); result.payload_ = payload;
endfunction
