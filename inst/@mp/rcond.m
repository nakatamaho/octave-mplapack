## SPDX-License-Identifier: BSD-2-Clause

function result = rcond (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{r} =} rcond (@var{A})
  ## Compute the dense arbitrary-precision 1-norm reciprocal condition
  ## estimate through MPLAPACK Rgecon or Cgecon.  The result is a real
  ## arbitrary-precision scalar and the input remains unchanged.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "rcond expects one mp value");
  endif
  if (nargout > 1)
    error ("mplapack:mp:OutputCount", "mp rcond returns one output");
  endif

  payload = __mplapack_core__ ("rcond", value);
  result = mp (0);
  result.payload_ = payload;
endfunction
