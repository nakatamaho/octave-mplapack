## SPDX-License-Identifier: BSD-2-Clause

function result = log10 (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "log10 expects one mp value");
  endif
  payload = __mplapack_core__ ("script_elementary", value, "log10");
  result = mp (0); result.payload_ = payload;
endfunction
