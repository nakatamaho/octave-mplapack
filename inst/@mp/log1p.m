## SPDX-License-Identifier: BSD-2-Clause

function result = log1p (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "log1p expects one mp value");
  endif
  payload = __mplapack_core__ ("script_elementary", value, "log1p");
  result = mp (0); result.payload_ = payload;
endfunction
