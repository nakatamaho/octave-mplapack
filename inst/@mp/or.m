## SPDX-License-Identifier: BSD-2-Clause

function result = or (lhs, rhs)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "mp logical or expects two operands");
  endif
  result = __mplapack_core__ ("script_logical", lhs, "or", rhs);
endfunction
