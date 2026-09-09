## SPDX-License-Identifier: BSD-2-Clause

function result = isnumeric (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} isnumeric (@var{value})
  ## Report that an @code{mp} scalar or dense matrix is numeric.
  ## @end deftypefn
  result = (nargin == 1 && isa (value, "mp"));
endfunction
