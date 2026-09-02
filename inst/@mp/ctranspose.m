function result = ctranspose (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} ctranspose (@var{value})
  ## Return the precision-preserving conjugate transpose of a real scalar or
  ## dense matrix @code{mp} value.  The current real backend has no imaginary
  ## part, so this has the same numeric result as @code{transpose}.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "ctranspose expects one mp value");
  endif
  payload = __mplapack_core__ ("matrix_transpose", value);
  result = value;
  result.payload_ = payload;
endfunction
