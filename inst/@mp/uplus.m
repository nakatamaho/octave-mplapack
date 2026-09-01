## SPDX-License-Identifier: BSD-2-Clause

function result = uplus (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} uplus (@var{value})
  ## Return an immutable real scalar @code{mp} value unchanged.
  ## @end deftypefn
  if (nargin != 1)
    error ("mplapack:mp:InvalidOperands", ...
           "unary mp plus expects exactly one operand");
  endif
  if (__mplapack_core__ ("value_is_matrix", value))
    error ("mplapack:mp:MatrixUnsupported", ...
           "dense mp matrix arithmetic is not implemented in M07");
  endif
  result = value;
endfunction
