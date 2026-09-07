## SPDX-License-Identifier: BSD-2-Clause

function result = flipud (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} flipud (@var{value})
  ## Flip a dense two-dimensional @code{mp} value from up to down.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "flipud expects one mp value");
  endif
  payload = __mplapack_core__ ("script_structure", value, "flip", 1);
  result = value;
  result.payload_ = payload;
endfunction
