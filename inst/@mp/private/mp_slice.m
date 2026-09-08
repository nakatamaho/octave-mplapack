## SPDX-License-Identifier: BSD-2-Clause

function result = mp_slice (value, rows, columns)
  payload = __mplapack_core__ ("matrix_subscript", value, rows, columns);
  result = mp (0);
  result.payload_ = payload;
endfunction
