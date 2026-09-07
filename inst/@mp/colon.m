## SPDX-License-Identifier: BSD-2-Clause

function result = colon (varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} colon (@var{a}, @var{b})
  ## @deftypefnx {} {@var{result} =} colon (@var{a}, @var{s}, @var{b})
  ## Construct a real arbitrary-precision range without a binary64 loop.
  ## @end deftypefn
  if (nargin != 2 && nargin != 3)
    error ("mplapack:mp:InvalidArguments", ...
           "colon expects two endpoints or an endpoint, step, and endpoint");
  endif
  template = [];
  for k = 1:nargin
    if (isa (varargin{k}, "mp"))
      template = varargin{k};
      break;
    endif
  endfor
  if (isempty (template))
    error ("mplapack:mp:InvalidOperands", ...
           "colon requires an mp endpoint or step");
  endif
  payload = __mplapack_core__ ("script_range", varargin{:});
  result = template;
  result.payload_ = payload;
endfunction
