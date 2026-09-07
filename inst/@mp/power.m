## SPDX-License-Identifier: BSD-2-Clause

function result = power (lhs, rhs)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} power (@var{lhs}, @var{rhs})
  ## Compute element-wise power for dense arbitrary-precision real or complex
  ## @code{mp} values, including mixed builtin scalar and matrix operands.
  ## Domain crossings promote to MPC at the operation precision.
  ## @end deftypefn
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", ...
           "mp power expects exactly two operands");
  endif
  payload = __mplapack_core__ ("power", lhs, rhs);
  result = mp (0);
  result.payload_ = payload;
endfunction
