## SPDX-License-Identifier: BSD-2-Clause

function result = hypot (lhs, rhs)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "hypot expects two operands");
  endif
  result = mp_binary_utility (lhs, rhs, "hypot");
endfunction
