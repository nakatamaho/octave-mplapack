## SPDX-License-Identifier: BSD-2-Clause

function result = signbit (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "signbit expects one mp value");
  endif
  result = __mplapack_core__ ("script_signbit", value);
endfunction
