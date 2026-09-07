## SPDX-License-Identifier: BSD-2-Clause

function result = and (lhs, rhs)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "mp logical and expects two operands");
  endif
  result = __mplapack_core__ ("script_logical", lhs, "and", rhs);
endfunction
