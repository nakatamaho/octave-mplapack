## SPDX-License-Identifier: BSD-2-Clause

function result = isinf (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} isinf (@var{value})
  ## Return a builtin logical mask for MPFR/MPC infinite values.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "isinf expects one mp value");
  endif
  result = __mplapack_core__ ("script_predicate", value, "isinf");
endfunction
