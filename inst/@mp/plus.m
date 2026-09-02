## SPDX-License-Identifier: BSD-2-Clause

function result = plus (lhs, rhs)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} plus (@var{lhs}, @var{rhs})
  ## Add real scalar or dense matrix @code{mp} values, with 2-D singleton
  ## expansion.  Mixed real @code{double} operands are converted directly at
  ## the operation precision; the current default precision is not used.
  ## @end deftypefn
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", ...
           "mp addition expects exactly two operands");
  endif
  payload = __mplapack_core__ ("scalar_add", lhs, rhs);
  if (isa (lhs, "mp"))
    result = lhs;
  else
    result = rhs;
  endif
  result.payload_ = payload;
endfunction
