## SPDX-License-Identifier: BSD-2-Clause

function result = times (lhs, rhs)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} times (@var{lhs}, @var{rhs})
  ## Multiply real scalar operands with @code{.*}.  Supported combinations
  ## are @code{mp}/@code{mp} and one @code{mp} with one real scalar
  ## @code{double}.  Matrix multiplication @code{*} remains unsupported.
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
