## SPDX-License-Identifier: BSD-2-Clause

function result = rem (lhs, rhs)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "rem expects two operands");
  endif
  result = mp_binary_utility (lhs, rhs, "rem");
endfunction
