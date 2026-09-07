## SPDX-License-Identifier: BSD-2-Clause

function result = flip (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} flip (@var{value})
  ## @deftypefnx {} {@var{result} =} flip (@var{value}, @var{dim})
  ## Flip a dense two-dimensional @code{mp} value along one dimension.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidArguments", ...
           "flip expects an mp value and an optional dimension");
  endif
  payload = __mplapack_core__ ("script_structure", value, "flip", ...
                               varargin{:});
  result = value;
  result.payload_ = payload;
endfunction
