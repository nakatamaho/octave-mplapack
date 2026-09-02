## SPDX-License-Identifier: BSD-2-Clause

function result = minus (lhs, rhs)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} minus (@var{lhs}, @var{rhs})
  ## Subtract real scalar or dense matrix @code{mp} values with 2-D singleton
  ## expansion.  Result precision is derived only from the operands and the
  ## operands remain unchanged.
  ## @end deftypefn
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", ...
           "mp subtraction expects exactly two operands");
  endif
  payload = __mplapack_core__ ("scalar_subtract", lhs, rhs);
  if (isa (lhs, "mp"))
    result = lhs;
  else
    result = rhs;
  endif
  result.payload_ = payload;
endfunction
