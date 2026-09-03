## SPDX-License-Identifier: BSD-2-Clause

function result = imag (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} imag (@var{value})
  ## Return the imaginary component of an @code{mp} value at its stored
  ## precision.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "imag expects one mp value");
  endif
  payload = __mplapack_core__ ("value_imag", value);
  result = value;
  result.payload_ = payload;
endfunction
