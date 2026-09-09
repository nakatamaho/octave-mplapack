## SPDX-License-Identifier: BSD-2-Clause

function result = repmat (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} repmat (@var{value}, @var{m}, @var{n})
  ## @deftypefnx {} {@var{result} =} repmat (@var{value}, [@var{m} @var{n}])
  ## Repeat a dense two-dimensional @code{mp} value while preserving its
  ## native precision and storage kind.
  ## @end deftypefn
  if (nargin < 2 || nargin > 3 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidArguments", ...
           "repmat expects an mp value and one or two repetition dimensions");
  endif
  payload = __mplapack_core__ ("script_structure", value, "repmat", ...
                               varargin{:});
  result = value;
  result.payload_ = payload;
endfunction
