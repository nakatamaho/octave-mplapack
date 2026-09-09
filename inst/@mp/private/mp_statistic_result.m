## SPDX-License-Identifier: BSD-2-Clause

function result = mp_statistic_result (payload)
  if (isnumeric (payload))
    result = payload;
  else
    result = mp (0);
    result.payload_ = payload;
  endif
endfunction
