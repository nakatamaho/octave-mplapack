## SPDX-License-Identifier: BSD-2-Clause

function result = mp_interp_element (value, row, column)
  if (! __mplapack_core__ ("value_is_matrix", value))
    result = value;
    return;
  endif
  if (nargin == 2)
    payload = __mplapack_core__ ("matrix_linear_subscript", value, row);
  else
    payload = __mplapack_core__ ("matrix_subscript", value, row, column);
  endif
  result = mp ("0");
  result.payload_ = payload;
endfunction
