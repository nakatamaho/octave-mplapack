## SPDX-License-Identifier: BSD-2-Clause

function result = subsref (value, index)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{B} =} subsref (@var{A}, @var{index})
  ## Implement dense @code{mp} indexing while preserving native value semantics.
  ## @end deftypefn
  if (isempty (index))
    result = value;
    return;
  endif

  if (strcmp (index(1).type, "{}"))
    error ("mplapack:mp:IndexingUnsupported", ...
           "dense mp cell indexing is not supported");
  endif

  if (strcmp (index(1).type, "()"))
    if (! __mplapack_core__ ("value_is_matrix", value))
      error ("mplapack:mp:IndexingUnsupported", ...
             "scalar mp indexing is not supported");
    endif

    subs = index(1).subs;
    if (numel (subs) == 1)
      payload = __mplapack_core__ ("matrix_linear_subscript", value, ...
                                   subs{1});
    elseif (numel (subs) == 2)
      payload = __mplapack_core__ ("matrix_subscript", value, ...
                                   subs{1}, subs{2});
    else
      error ("mplapack:mp:IndexingUnsupported", ...
             "only one- and two-dimensional indexing is supported");
    endif

    result = mp (0);
    result.payload_ = payload;
    if (numel (index) > 1)
      result = subsref (result, index(2:end));
    endif
    return;
  endif

  result = builtin ("subsref", value, index);
endfunction
