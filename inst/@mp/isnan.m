## SPDX-License-Identifier: BSD-2-Clause

function result = isnan (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} isnan (@var{value})
  ## Return a builtin logical mask for MPFR/MPC NaN values.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "isnan expects one mp value");
  endif
  result = __mplapack_core__ ("script_predicate", value, "isnan");
endfunction
