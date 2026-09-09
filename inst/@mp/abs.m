## SPDX-License-Identifier: BSD-2-Clause

function result = abs (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} abs (@var{value})
  ## Return the MPFR absolute value or MPC magnitude of an @code{mp} value.
  ## The result is real @code{mp} storage at the source precision.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "abs expects one mp value");
  endif
  result = mp (0);
  result.payload_ = __mplapack_core__ ("script_unary", value, "abs");
endfunction
