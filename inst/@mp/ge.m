## SPDX-License-Identifier: BSD-2-Clause

function result = ge (lhs, rhs)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "mp greater-than-or-equal expects two operands");
  endif
  result = __mplapack_core__ ("script_compare", lhs, rhs, "ge");
endfunction
