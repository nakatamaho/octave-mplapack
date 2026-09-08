## SPDX-License-Identifier: BSD-2-Clause

function result = mp_quad_element (value, index)
  if (! isa (value, "mp"))
    error ("mplapack:quad:Internal", "quadrature element requires mp data");
  endif
  if (numel (value) == 1)
    result = value;
    return;
  endif
  payload = __mplapack_core__ ("matrix_linear_subscript", value, index);
  result = mp ("0");
  result.payload_ = payload;
endfunction
