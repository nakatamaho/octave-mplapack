## SPDX-License-Identifier: BSD-2-Clause

function result = mp_opt_vertex (simplex, column)
  [dimension, unused] = size (simplex);
  result = repmat (mp_opt_element (simplex, 1) * 0, dimension, 1);
  for row = 1:dimension
    result = mp_solver_put (result, row, 1, ...
                            mp_opt_element (simplex, (column - 1) * dimension + row));
  endfor
endfunction
