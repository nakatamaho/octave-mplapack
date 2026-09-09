## SPDX-License-Identifier: BSD-2-Clause

function result = mp_rows_equal (a, row_a, b, row_b)
  [~, columns_a] = size (a);
  [~, columns_b] = size (b);
  if (columns_a != columns_b), result = false; return; endif
  result = true;
  for column = 1:columns_a
    if (! isequal (mp_element (a,row_a,column), mp_element (b,row_b,column)))
      result = false;
      return;
    endif
  endfor
endfunction
