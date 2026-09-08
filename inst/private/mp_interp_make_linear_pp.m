## SPDX-License-Identifier: BSD-2-Clause

function pp = mp_interp_make_linear_pp (x, y)
  pieces = rows (x) - 1;
  zero = mp_interp_element (y, 1) * 0;
  coefficients = repmat (zero, pieces, 2);
  for index = 1:pieces
    left = mp_interp_element (x, index);
    right = mp_interp_element (x, index + 1);
    left_value = mp_interp_element (y, index);
    slope = (mp_interp_element (y, index + 1) - left_value) ...
            / (right - left);
    coefficients = mp_interp_put (coefficients, index, 1, slope);
    coefficients = mp_interp_put (coefficients, index, 2, left_value);
  endfor
  pp = struct ("form", "pp", "breaks", x, "coefs", coefficients, ...
               "pieces", pieces, "order", 2, "dim", 1, ...
               "method", "linear");
endfunction
