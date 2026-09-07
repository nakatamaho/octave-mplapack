## SPDX-License-Identifier: BSD-2-Clause

function result = mp_binary_utility (lhs, rhs, operation)
  if (isa (lhs, "mp"))
    result = lhs;
  elseif (isa (rhs, "mp"))
    result = rhs;
  else
    error ("mplapack:mp:InvalidOperands", ...
           "%s requires at least one mp operand", operation);
  endif
  payload = __mplapack_core__ ("script_binary_utility", lhs, rhs, operation);
  result.payload_ = payload;
endfunction
