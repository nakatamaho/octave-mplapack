## SPDX-License-Identifier: BSD-2-Clause

function result = plus (lhs, rhs)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} plus (@var{lhs}, @var{rhs})
  ## Add real scalar @code{mp} values or one @code{mp} and one scalar
  ## @code{double}.  For two @code{mp} operands the result precision is the
  ## greater operand precision.  A mixed @code{double} is converted at the
  ## @code{mp} operand precision.  The current default precision is not used.
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
