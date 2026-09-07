## SPDX-License-Identifier: BSD-2-Clause

function result = linspace (first, last, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} linspace (@var{first}, @var{last})
  ## @deftypefnx {} {@var{result} =} linspace (@var{first}, @var{last}, @var{n})
  ## Construct a native MPFR/MPC row vector with exact endpoints.
  ## @end deftypefn
  if (nargin < 2 || nargin > 3)
    error ("mplapack:mp:InvalidArguments", ...
           "linspace expects two endpoints and an optional count");
  endif
  if (isa (first, "mp"))
    template = first;
  elseif (isa (last, "mp"))
    template = last;
  else
    error ("mplapack:mp:InvalidOperands", ...
           "linspace requires an mp endpoint");
  endif
  payload = __mplapack_core__ ("script_linspace", first, last, varargin{:});
  result = template;
  result.payload_ = payload;
endfunction
