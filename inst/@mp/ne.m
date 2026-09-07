## SPDX-License-Identifier: BSD-2-Clause

function result = ne (lhs, rhs)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "mp inequality expects two operands");
  endif
  result = __mplapack_core__ ("script_compare", lhs, rhs, "ne");
endfunction
