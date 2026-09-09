## SPDX-License-Identifier: BSD-2-Clause

function result = isequaln (varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} isequaln (@varargin{})
  ## Compare @code{mp} values by exact stored native value and shape, treating
  ## corresponding NaNs as equal.
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
                             "isequaln"))
      result = false;
      return;
    endif
  endfor
  result = true;
endfunction
