## SPDX-License-Identifier: BSD-2-Clause

function result = conj (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} conj (@var{value})
  ## Return the complex conjugate of an @code{mp} value at its stored
  ## precision.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "conj expects one mp value");
  endif
  payload = __mplapack_core__ ("value_conj", value);
  result = value;
  result.payload_ = payload;
endfunction
