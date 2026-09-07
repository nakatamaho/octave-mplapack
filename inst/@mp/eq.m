## SPDX-License-Identifier: BSD-2-Clause

function result = eq (lhs, rhs)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "mp equality expects two operands");
  endif
  result = __mplapack_core__ ("script_compare", lhs, rhs, "eq");
endfunction
