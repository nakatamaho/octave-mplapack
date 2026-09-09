## SPDX-License-Identifier: BSD-2-Clause

function result = isfinite (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} isfinite (@var{value})
  ## Return a builtin logical mask for finite MPFR/MPC values.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "isfinite expects one mp value");
  endif
  result = __mplapack_core__ ("script_predicate", value, "isfinite");
endfunction
