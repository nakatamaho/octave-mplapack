## SPDX-License-Identifier: BSD-2-Clause

function result = isequal (varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} isequal (@varargin{})
  ## Compare @code{mp} values by exact stored native value and shape.
  ## NaN values are not equal, as in builtin Octave.
  ## @end deftypefn
  if (nargin <= 1)
    result = true;
    return;
  endif
  for k = 2:nargin
    if (! isa (varargin{k-1}, "mp") || ! isa (varargin{k}, "mp"))
      result = false;
      return;
    endif
    if (! __mplapack_core__ ("value_equal", varargin{1}, varargin{k}, ...
                             "isequal"))
      result = false;
      return;
    endif
  endfor
  result = true;
endfunction
