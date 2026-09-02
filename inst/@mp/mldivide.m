function result = mldivide (lhs, rhs)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} mldivide (@var{lhs}, @var{rhs})
  ## Solve dense real @code{mp} systems with MPLAPACK MPFR.  Square systems
  ## use @code{Rgesv}; full-rank rectangular systems use @code{Rgels}.
  ## Scalar left division uses native MPFR arithmetic.  Rank-deficient,
  ## complex, and sparse systems are not implemented.
  ## @end deftypefn
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", ...
           "mp left division expects exactly two operands");
  endif

  payload = __mplapack_core__ ("mldivide", lhs, rhs);
  result = mp (0);
  result.payload_ = payload;
endfunction
