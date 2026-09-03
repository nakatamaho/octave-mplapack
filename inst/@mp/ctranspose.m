function result = ctranspose (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} ctranspose (@var{value})
  ## Return the precision-preserving conjugate transpose of a scalar or dense
  ## matrix @code{mp} value.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "ctranspose expects one mp value");
  endif
  payload = __mplapack_core__ ("matrix_ctranspose", value);
  result = value;
  result.payload_ = payload;
endfunction
