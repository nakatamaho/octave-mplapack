## SPDX-License-Identifier: BSD-2-Clause

function result = erfc (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "erfc expects one real mp value");
  endif
  if (! isreal (value)), error ("mplapack:mp:ComplexUnsupported", "erfc is implemented for real mp values only"); endif
  result = mp (0); result.payload_ = __mplapack_core__ ("script_elementary", value, "erfc");
endfunction
