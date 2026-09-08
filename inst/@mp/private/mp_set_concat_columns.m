## SPDX-License-Identifier: BSD-2-Clause

function result = mp_set_concat_columns (a, b)
  template = a;
  if (isreal (a) && ! isreal (b)), template = b; endif
  result = zeros (numel (a) + numel (b), 1, "like", template);
  ac = mp_column (a);
  bc = mp_column (b);
  for k = 1:numel (ac), result = mp_put (result,k,1,mp_element (ac,k)); endfor
  for k = 1:numel (bc), result = mp_put (result,numel (ac)+k,1,mp_element (bc,k)); endfor
endfunction
