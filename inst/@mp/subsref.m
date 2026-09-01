## SPDX-License-Identifier: BSD-2-Clause

function result = subsref (value, index)
  if (! isempty (index) && any (strcmp (index(1).type, {"()", "{}"})))
    error ("mplapack:mp:IndexingUnsupported", ...
           "dense mp matrix indexing is not implemented in M07");
  endif
  result = builtin ("subsref", value, index);
endfunction
