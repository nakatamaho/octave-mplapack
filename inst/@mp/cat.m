## SPDX-License-Identifier: BSD-2-Clause

function result = cat (dimension, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} cat (@var{dimension}, @var{A}, @var{B}, @dots{})
  ## Concatenate dense two-dimensional @code{mp} values along dimension 1 or 2.
  ## @end deftypefn
  if (nargin < 2 || ! isnumeric (dimension) || ! isreal (dimension)
      || ! isscalar (dimension) || dimension != fix (dimension)
      || (dimension != 1 && dimension != 2))
    error ("mplapack:mp:InvalidDimension", ...
           "cat supports only dimensions 1 and 2");
  endif
  template = [];
  for k = 1:numel (varargin)
    if (isa (varargin{k}, "mp"))
      template = varargin{k};
      break;
    endif
  endfor
  if (isempty (template))
    error ("mplapack:mp:InvalidOperands", ...
           "cat requires at least one mp operand");
  endif
  if (dimension == 1)
    payload = __mplapack_core__ ("matrix_vertcat", varargin{:});
  else
    payload = __mplapack_core__ ("matrix_horzcat", varargin{:});
  endif
  result = template;
  result.payload_ = payload;
endfunction
