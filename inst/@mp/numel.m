## SPDX-License-Identifier: BSD-2-Clause

function count = numel (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{n} =} numel (@var{A})
  ## Return the number of stored elements in a dense real @code{mp} value.
  ## @end deftypefn
  if (! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "numel expects an mp value");
  endif
  if (! isempty (varargin))
    error ("mplapack:mp:IndexingUnsupported", ...
           "dense mp matrix indexing is not implemented in M07");
  endif
  info = __mplapack_core__ ("value_shape_info", value);
  count = double (info.numel);
endfunction
