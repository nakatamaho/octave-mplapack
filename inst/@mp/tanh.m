## SPDX-License-Identifier: BSD-2-Clause

function result = tanh (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "tanh expects one mp value");
  endif
  payload = __mplapack_core__ ("script_elementary", value, "tanh");
  result = mp (0); result.payload_ = payload;
endfunction
