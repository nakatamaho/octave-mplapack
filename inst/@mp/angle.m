## SPDX-License-Identifier: BSD-2-Clause

function result = angle (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} angle (@var{value})
  ## Return the MPFR/MPC argument of an @code{mp} value.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "angle expects one mp value");
  endif
  result = mp (0);
  result.payload_ = __mplapack_core__ ("script_unary", value, "angle");
endfunction
