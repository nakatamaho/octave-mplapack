## SPDX-License-Identifier: BSD-2-Clause

function count = rows (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{n} =} rows (@var{A})
  ## Return the number of rows in a dense real @code{mp} value.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "rows expects one mp value");
  endif
  info = __mplapack_core__ ("value_shape_info", value);
  count = double (info.rows);
endfunction
