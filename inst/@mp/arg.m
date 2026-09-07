## SPDX-License-Identifier: BSD-2-Clause

function result = arg (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} arg (@var{value})
  ## Alias for the arbitrary-precision @code{angle} operation.
  ## @end deftypefn
  result = angle (value);
endfunction
