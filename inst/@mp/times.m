## SPDX-License-Identifier: BSD-2-Clause

function result = times (lhs, rhs)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} times (@var{lhs}, @var{rhs})
  ## Multiply real scalar or dense matrix operands with @code{.*}, including
  ## 2-D singleton expansion.  Matrix multiplication @code{*} remains the
  ## separate MPLAPACK Rgemm operation.
  ## @end deftypefn
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", ...
           "mp element-wise multiplication expects exactly two operands");
  endif
  payload = __mplapack_core__ ("scalar_multiply", lhs, rhs);
  if (isa (lhs, "mp"))
    result = lhs;
  else
    result = rhs;
  endif
  result.payload_ = payload;
endfunction
