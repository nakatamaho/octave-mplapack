## SPDX-License-Identifier: BSD-2-Clause

function result = uminus (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} uminus (@var{value})
  ## Negate an immutable real scalar @code{mp} value at its stored precision.
  ## @end deftypefn
  if (nargin != 1)
    error ("mplapack:mp:InvalidOperands", ...
           "unary mp minus expects exactly one operand");
  endif
  payload = __mplapack_core__ ("scalar_negate", value);
  result = value;
  result.payload_ = payload;
endfunction
