function result = transpose (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} transpose (@var{value})
  ## Return the precision-preserving non-conjugating transpose of a real
  ## scalar or dense matrix @code{mp} value.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "transpose expects one mp value");
  endif
  payload = __mplapack_core__ ("matrix_transpose", value);
  result = value;
  result.payload_ = payload;
endfunction
