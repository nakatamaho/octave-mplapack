## SPDX-License-Identifier: BSD-2-Clause

function [values, first, inverse] = mp_set_unique (value, stable)
  flat = mp_column (value);
  count = numel (flat);
  values = zeros (count, 1, "like", value);
  first = zeros (count, 1);
  inverse = zeros (count, 1);
  unique_count = 0;
  for k = 1:count
    found = 0;
    for j = 1:unique_count
      if (isequal (mp_element (flat,k), mp_element (values,j)))
        found = j;
        break;
      endif
    endfor
    if (found == 0)
      unique_count = unique_count + 1;
      values = mp_put (values,unique_count,1,mp_element (flat,k));
      first(unique_count) = k;
      found = unique_count;
    endif
    inverse(k) = found;
  endfor
  if (unique_count == 0)
    values = zeros (0,1,"like",value);
    first = zeros (0,1);
  else
    values = mp_slice (values, 1:unique_count, 1);
    first = first(1:unique_count);
  endif
  if (! stable && unique_count > 1)
    [values, order] = sort (values);
    old_first = first;
    first = old_first(order);
    for k = 1:count
      for j = 1:unique_count
        if (isequal (mp_element (flat,k), mp_element (values,j)))
          inverse(k) = j;
          break;
        endif
      endfor
    endfor
  endif
endfunction
