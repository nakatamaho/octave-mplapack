## SPDX-License-Identifier: BSD-2-Clause

function result = mtimes (lhs, rhs)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} mtimes (@var{lhs}, @var{rhs})
  ## Multiply supported @code{mp} scalars and dense matrices.  Real-only
  ## matrix multiplication uses the native MPFR MPLAPACK reference
  ## @code{Rgemm} path.  A complex participant uses the native MPC MPLAPACK
  ## @code{Cgemm} path, with scalar scaling remaining native MPC arithmetic.
  ## Real or complex double operands may be mixed with an @code{mp} operand
  ## and are converted directly from their binary64 components at the
  ## operation precision.
  ## @end deftypefn
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", ...
           "mp multiplication expects exactly two operands");
  endif

  payload = __mplapack_core__ ("mtimes", lhs, rhs);
  result = mp (0);
  result.payload_ = payload;
endfunction
