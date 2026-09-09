## SPDX-License-Identifier: BSD-2-Clause

function [values, first, inverse] = mp_set_unique_rows (value, stable)
  [row_count, column_count] = size (value);
  values = zeros (row_count, column_count, "like", value);
  first = zeros (row_count, 1);
  inverse = zeros (row_count, 1);
  unique_count = 0;
  for row = 1:row_count
    found = 0;
    for candidate = 1:unique_count
      if (mp_rows_equal (value,row,values,candidate))
        found = candidate;
        break;
      endif
    endfor
    if (found == 0)
      unique_count = unique_count + 1;
      for column = 1:column_count
        values = mp_put (values,unique_count,column,mp_element (value,row,column));
      endfor
      first(unique_count) = row;
      found = unique_count;
    endif
    inverse(row) = found;
  endfor
  values = mp_slice (values,1:unique_count,1:column_count);
  first = first(1:unique_count);
  if (! stable && unique_count > 1)
    order = 1:unique_count;
    for i = 1:unique_count-1
      selected = i;
      for j = i+1:unique_count
        if (mp_row_less (values,order(j),values,order(selected)))
          selected = j;
        endif
      endfor
      if (selected != i)
        temporary = order(i); order(i) = order(selected); order(selected) = temporary;
      endif
    endfor
    sorted = zeros (unique_count,column_count,"like",value);
    old_first = first;
    for i = 1:unique_count
      for column = 1:column_count
        sorted = mp_put (sorted,i,column,mp_element (values,order(i),column));
      endfor
      first(i) = old_first(order(i));
    endfor
    values = sorted;
    for row = 1:row_count
      for candidate = 1:unique_count
        if (mp_rows_equal (value,row,values,candidate))
          inverse(row) = candidate;
          break;
        endif
      endfor
    endfor
  endif
endfunction

function result = mp_row_less (lhs, row_lhs, rhs, row_rhs)
  [~, columns] = size (lhs);
  for column = 1:columns
    left = mp_element (lhs,row_lhs,column);
    right = mp_element (rhs,row_rhs,column);
    if (isequal (left,right)), continue; endif
    result = mp_order_less (left,right);
    return;
  endfor
  result = false;
endfunction
