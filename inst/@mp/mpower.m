## SPDX-License-Identifier: BSD-2-Clause

function result = mpower (lhs, rhs)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} mpower (@var{lhs}, @var{rhs})
  ## Compute scalar power or integer powers of square dense @code{mp}
  ## matrices. Matrix powers use exponentiation by squaring and the native
  ## MPFR/MPC matrix multiplication and inverse paths.
  ## @end deftypefn
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", ...
           "mp matrix power expects exactly two operands");
  endif
  payload = __mplapack_core__ ("mpower", lhs, rhs);
  result = mp (0);
  result.payload_ = payload;
endfunction
