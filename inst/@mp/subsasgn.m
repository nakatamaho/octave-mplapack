## SPDX-License-Identifier: BSD-2-Clause

function result = subsasgn (value, index, rhs)
  if (! isempty (index) && any (strcmp (index(1).type, {"()", "{}"})))
    error ("mplapack:mp:Immutable", ...
           "dense mp matrix indexed assignment is not supported");
  endif
  result = builtin ("subsasgn", value, index, rhs);
endfunction
