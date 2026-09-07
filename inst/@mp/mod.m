## SPDX-License-Identifier: BSD-2-Clause

function result = mod (lhs, rhs)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "mod expects two operands");
  endif
  result = mp_binary_utility (lhs, rhs, "mod");
endfunction
