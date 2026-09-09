## SPDX-License-Identifier: BSD-2-Clause

function result = norm (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{y} =} norm (@var{x})
  ## @deftypefnx {} {@var{y} =} norm (@var{x}, @var{p})
  ## Compute arbitrary-precision vector and dense matrix norms through the
  ## MPFR/MPC MPLAPACK backend.  Vectors support 0, 1, 2, Inf, -Inf, fro, and
  ## positive finite p values; matrices support 1, 2, Inf, and fro.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "norm expects one mp value and an optional p or fro flag");
  endif

  if (nargin == 1)
    request = 2;
  else
    request = varargin{1};
    if ((ischar (request) || isstring (request))
        && ! strcmp (char (request), "fro"))
      error ("mplapack:mp:InvalidOption", ...
             "norm string option must be \"fro\"");
    endif
    if (! ischar (request) && ! isstring (request)
        && (! isnumeric (request) || islogical (request)
            || ! isreal (request) || ! isscalar (request)))
      error ("mplapack:mp:InvalidOption", ...
             "norm p must be a real scalar or \"fro\"");
    endif
  endif

  payload = __mplapack_core__ ("norm", value, request);
  result = mp (0);
  result.payload_ = payload;
endfunction
