## SPDX-License-Identifier: BSD-2-Clause

function result = mtimes (lhs, rhs)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} mtimes (@var{lhs}, @var{rhs})
  ## Multiply supported real @code{mp} scalars and dense matrices.  Dense
  ## matrix multiplication uses the native MPFR MPLAPACK reference @code{Rgemm}
  ## path; scalar scaling remains native MPFR arithmetic.  A real double
  ## scalar or matrix may be mixed with an @code{mp} operand and is converted
  ## directly from its binary64 value at the operation precision.
  ## @end deftypefn
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", ...
           "mp multiplication expects exactly two operands");
  endif

  payload = __mplapack_core__ ("mtimes", lhs, rhs);
  result = mp (0);
  result.payload_ = payload;
endfunction
