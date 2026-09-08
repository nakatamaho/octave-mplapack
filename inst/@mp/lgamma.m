## SPDX-License-Identifier: BSD-2-Clause

function result = lgamma (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "lgamma expects one real mp value");
  endif
  if (! isreal (value)), error ("mplapack:mp:ComplexUnsupported", "lgamma is implemented for real mp values only"); endif
  result = mp (0); result.payload_ = __mplapack_core__ ("script_elementary", value, "lgamma");
endfunction
