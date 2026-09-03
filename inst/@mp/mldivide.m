function result = mldivide (lhs, rhs)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} mldivide (@var{lhs}, @var{rhs})
  ## Solve dense @code{mp} systems with MPLAPACK.  Real square systems use
  ## @code{Rgesv}; complex square systems use @code{Cgesv}; rectangular real
  ## systems use the rank-revealing @code{Rgelss} driver.  Scalar left
  ## division uses native MPFR or MPC arithmetic.  Sparse systems are not
  ## implemented.
  ## @end deftypefn
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", ...
           "mp left division expects exactly two operands");
  endif

  payload = __mplapack_core__ ("mldivide", lhs, rhs);
  result = mp (0);
  result.payload_ = payload;
endfunction
