## SPDX-License-Identifier: BSD-2-Clause

function result = gammaln (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "gammaln expects one real mp value");
  endif
  if (! isreal (value)), error ("mplapack:mp:ComplexUnsupported", "gammaln is implemented for real mp values only"); endif
  result = mp (0); result.payload_ = __mplapack_core__ ("script_elementary", value, "gammaln");
endfunction
