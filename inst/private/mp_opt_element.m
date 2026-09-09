## SPDX-License-Identifier: BSD-2-Clause

function result = mp_opt_element (value, index)
  if (numel (value) == 1)
    result = value;
    return;
  endif
  payload = __mplapack_core__ ("matrix_linear_subscript", value, index);
  result = mp ("0");
  result.payload_ = payload;
endfunction
