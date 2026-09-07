## SPDX-License-Identifier: BSD-2-Clause

function result = atan2 (y, x)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "atan2 expects two operands");
  endif
  result = mp_binary_utility (y, x, "atan2");
endfunction
