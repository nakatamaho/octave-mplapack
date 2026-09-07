## SPDX-License-Identifier: BSD-2-Clause

function result = xor (lhs, rhs)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "mp logical xor expects two operands");
  endif
  result = __mplapack_core__ ("script_logical", lhs, "xor", rhs);
endfunction
