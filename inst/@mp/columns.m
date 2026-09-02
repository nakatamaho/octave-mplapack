## SPDX-License-Identifier: BSD-2-Clause

function count = columns (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{n} =} columns (@var{A})
  ## Return the number of columns in a dense real @code{mp} value.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "columns expects one mp value");
  endif
  info = __mplapack_core__ ("value_shape_info", value);
  count = double (info.columns);
endfunction
