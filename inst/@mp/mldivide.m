function result = mldivide (lhs, rhs)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} mldivide (@var{lhs}, @var{rhs})
  ## Solve dense real @code{mp} systems with MPLAPACK MPFR.  Square systems
  ## use @code{Rgesv}; rectangular systems use the rank-revealing
  ## @code{Rgelss} driver and return minimum-norm least-squares solutions.
  ## Scalar left division uses native MPFR arithmetic.  Complex and sparse
  ## systems are not implemented.
  ## @end deftypefn
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", ...
           "mp left division expects exactly two operands");
  endif

  payload = __mplapack_core__ ("mldivide", lhs, rhs);
  result = mp (0);
  result.payload_ = payload;
endfunction
