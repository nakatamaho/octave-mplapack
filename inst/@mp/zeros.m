## SPDX-License-Identifier: BSD-2-Clause

function result = zeros (varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} zeros (@var{dims}, "like", @var{A})
  ## Construct a zero @code{mp} array using the precision and storage kind of
  ## @var{A}.  This method deliberately supports the explicit @code{"like"}
  ## form only.
  ## @end deftypefn
  [template, dimensions] = mp_parse_like_constructor (varargin, "zeros");
  payload = __mplapack_core__ ("script_structure", "like", "zeros", ...
                               template, dimensions{:});
  result = template;
  result.payload_ = payload;
endfunction
