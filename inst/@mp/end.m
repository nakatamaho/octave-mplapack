## SPDX-License-Identifier: BSD-2-Clause

function result = end (value, index, number_of_indices)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{n} =} end (@var{A}, @var{k}, @var{nidx})
  ## Provide @code{end} values for supported one- and two-dimensional indexing.
  ## @end deftypefn
  if (nargin != 3 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "end expects an mp value and indexing metadata");
  endif

  info = __mplapack_core__ ("value_shape_info", value);
  if (number_of_indices == 1)
    result = double (info.numel);
  elseif (number_of_indices == 2 && index == 1)
    result = double (info.rows);
  elseif (number_of_indices == 2 && index == 2)
    result = double (info.columns);
  else
    error ("mplapack:mp:IndexingUnsupported", ...
           "only one- and two-dimensional end indexing is supported");
  endif
endfunction
