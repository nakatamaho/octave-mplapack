## SPDX-License-Identifier: BSD-2-Clause

function result = vertcat (varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{C} =} vertcat (@var{A}, @var{B}, @dots{})
  ## Concatenate dense real or complex @code{mp} values vertically.
  ## @end deftypefn
  if (nargin < 1)
    error ("mplapack:mp:InvalidOperands", ...
           "mp vertical concatenation expects at least one operand");
  endif
  payload = __mplapack_core__ ("matrix_vertcat", varargin{:});
  result = varargin{1};
  if (! isa (result, "mp"))
    for k = 2:nargin
      if (isa (varargin{k}, "mp"))
        result = varargin{k};
        break;
      endif
    endfor
  endif
  result.payload_ = payload;
endfunction
