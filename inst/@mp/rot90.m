## SPDX-License-Identifier: BSD-2-Clause

function result = rot90 (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} rot90 (@var{value})
  ## @deftypefnx {} {@var{result} =} rot90 (@var{value}, @var{k})
  ## Rotate a dense two-dimensional @code{mp} value counterclockwise.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidArguments", ...
           "rot90 expects an mp value and an optional count");
  endif
  payload = __mplapack_core__ ("script_structure", value, "rot90", ...
                               varargin{:});
  result = value;
  result.payload_ = payload;
endfunction
