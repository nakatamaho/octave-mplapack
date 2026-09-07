## SPDX-License-Identifier: BSD-2-Clause

function result = atanh (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "atanh expects one mp value");
  endif
  payload = __mplapack_core__ ("script_elementary", value, "atanh");
  result = mp (0); result.payload_ = payload;
endfunction
