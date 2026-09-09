## SPDX-License-Identifier: BSD-2-Clause

function result = mp_set_has_option (arguments, option)
  result = false;
  for k = 1:numel (arguments)
    if ((ischar (arguments{k}) || isstring (arguments{k})) ...
        && strcmp (char (arguments{k}), option))
      result = true;
      return;
    endif
  endfor
endfunction
