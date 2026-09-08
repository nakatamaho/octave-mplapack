## SPDX-License-Identifier: BSD-2-Clause

function result = erf (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "erf expects one real mp value");
  endif
  if (! isreal (value)), error ("mplapack:mp:ComplexUnsupported", "erf is implemented for real mp values only"); endif
  result = mp (0); result.payload_ = __mplapack_core__ ("script_elementary", value, "erf");
endfunction
