function result = mldivide (lhs, rhs)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} mldivide (@var{lhs}, @var{rhs})
  ## Solve supported dense real @code{mp} systems with MPLAPACK MPFR
  ## @code{Rgesv}.  Scalar left division uses native MPFR arithmetic.
  ## Rectangular, complex, and sparse systems are not implemented.
  ## @end deftypefn
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", ...
           "mp left division expects exactly two operands");
  endif

  payload = __mplapack_core__ ("mldivide", lhs, rhs);
  result = mp (0);
  result.payload_ = payload;
endfunction
