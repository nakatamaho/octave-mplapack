## SPDX-License-Identifier: BSD-2-Clause

function result = logspace (first, last, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} logspace (@var{first}, @var{last})
  ## @deftypefnx {} {@var{result} =} logspace (@var{first}, @var{last}, @var{n})
  ## Construct a real native MPFR logarithmic row vector.
  ## @end deftypefn
  if (nargin < 2 || nargin > 3)
    error ("mplapack:mp:InvalidArguments", ...
           "logspace expects two endpoints and an optional count");
  endif
  if (isa (first, "mp"))
    template = first;
  elseif (isa (last, "mp"))
    template = last;
  else
    error ("mplapack:mp:InvalidOperands", ...
           "logspace requires an mp endpoint");
  endif
  payload = __mplapack_core__ ("script_logspace", first, last, varargin{:});
  result = template;
  result.payload_ = payload;
endfunction
