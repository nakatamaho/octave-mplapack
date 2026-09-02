## SPDX-License-Identifier: BSD-2-Clause

function result = rdivide (lhs, rhs)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} rdivide (@var{lhs}, @var{rhs})
  ## Divide real scalar or dense matrix operands element by element with
  ## @code{./} and 2-D singleton expansion.  Division by zero and special
  ## values follow MPFR round-to-nearest semantics.  Matrix right division
  ## @code{/} remains unsupported.
  ## @end deftypefn
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", ...
           "mp element-wise division expects exactly two operands");
  endif
  payload = __mplapack_core__ ("scalar_divide", lhs, rhs);
  if (isa (lhs, "mp"))
    result = lhs;
  else
    result = rhs;
  endif
  result.payload_ = payload;
endfunction
