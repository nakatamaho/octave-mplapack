## SPDX-License-Identifier: BSD-2-Clause

function result = mp_interp_put (value, row, column, replacement)
  payload = __mplapack_core__ ("matrix_subsasgn", value, row, column, replacement);
  result = mp ("0");
  result.payload_ = payload;
endfunction
