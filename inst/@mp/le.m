## SPDX-License-Identifier: BSD-2-Clause

function result = le (lhs, rhs)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "mp less-than-or-equal expects two operands");
  endif
  result = __mplapack_core__ ("script_compare", lhs, rhs, "le");
endfunction
