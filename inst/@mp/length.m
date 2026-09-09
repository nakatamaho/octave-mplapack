## SPDX-License-Identifier: BSD-2-Clause

function count = length (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{n} =} length (@var{A})
  ## Return the larger matrix dimension of a dense @code{mp} value.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "length expects one mp value");
  endif
  dimensions = size (value);
  count = max (dimensions);
endfunction
