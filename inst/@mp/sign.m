## SPDX-License-Identifier: BSD-2-Clause

function result = sign (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} sign (@var{value})
  ## Return the native MPFR/MPC sign of an @code{mp} value.
  ## Complex nonzero values return @code{x ./ abs (x)}.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "sign expects one mp value");
  endif
  result = mp (0);
  result.payload_ = __mplapack_core__ ("script_unary", value, "sign");
endfunction
