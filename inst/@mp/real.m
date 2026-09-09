## SPDX-License-Identifier: BSD-2-Clause

function result = real (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} real (@var{value})
  ## Return the real component of an @code{mp} value at its stored precision.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "real expects one mp value");
  endif
  payload = __mplapack_core__ ("value_real", value);
  result = value;
  result.payload_ = payload;
endfunction
