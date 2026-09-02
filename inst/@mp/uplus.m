## SPDX-License-Identifier: BSD-2-Clause

function result = uplus (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} uplus (@var{value})
  ## Return an immutable real scalar or dense matrix @code{mp} value unchanged.
  ## @end deftypefn
  if (nargin != 1)
    error ("mplapack:mp:InvalidOperands", ...
           "unary mp plus expects exactly one operand");
  endif
  result = value;
endfunction
