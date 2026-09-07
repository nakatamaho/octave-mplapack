## SPDX-License-Identifier: BSD-2-Clause

function result = lt (lhs, rhs)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "mp less-than expects two operands");
  endif
  result = __mplapack_core__ ("script_compare", lhs, rhs, "lt");
endfunction
