## SPDX-License-Identifier: BSD-2-Clause

function result = subsasgn (value, index, rhs)
  if (isempty (index))
    result = value;
    return;
  endif

  if (strcmp (index(1).type, "{}"))
    error ("mplapack:mp:Immutable", ...
           "cell-style assignment is not supported for mp values");
  endif

  if (strcmp (index(1).type, "()"))
    if (numel (index) != 1)
      error ("mplapack:mp:AssignmentUnsupported", ...
             "chained indexed assignment is not supported");
    endif

    subs = index(1).subs;
    if (numel (subs) == 1)
      payload = __mplapack_core__ ("matrix_linear_subsasgn", value, ...
                                   subs{1}, rhs);
    elseif (numel (subs) == 2)
      payload = __mplapack_core__ ("matrix_subsasgn", value, ...
                                   subs{1}, subs{2}, rhs);
    else
      error ("mplapack:mp:IndexingUnsupported", ...
             "only one- and two-dimensional assignment is supported");
    endif

    result = value;
    result.payload_ = payload;
    return;
  endif

  result = builtin ("subsasgn", value, index, rhs);
endfunction
