## SPDX-License-Identifier: BSD-2-Clause

function result = isreal (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} isreal (@var{value})
  ## Return whether an @code{mp} value has a real native payload.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "isreal expects one mp value");
  endif
  result = __mplapack_core__ ("value_is_real", value);
endfunction
