## SPDX-License-Identifier: BSD-2-Clause

function result = fliplr (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} fliplr (@var{value})
  ## Flip a dense two-dimensional @code{mp} value from left to right.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "fliplr expects one mp value");
  endif
  payload = __mplapack_core__ ("script_structure", value, "flip", 2);
  result = value;
  result.payload_ = payload;
endfunction
