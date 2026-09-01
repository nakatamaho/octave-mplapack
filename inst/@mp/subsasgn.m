## SPDX-License-Identifier: BSD-2-Clause

function result = subsasgn (value, index, rhs)
  if (! isempty (index) && any (strcmp (index(1).type, {"()", "{}"})))
    error ("mplapack:mp:IndexingUnsupported", ...
           "dense mp matrix indexed assignment is not implemented in M07");
  endif
  result = builtin ("subsasgn", value, index, rhs);
endfunction
