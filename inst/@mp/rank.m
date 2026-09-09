## SPDX-License-Identifier: BSD-2-Clause

function result = rank (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{r} =} rank (@var{A})
  ## @deftypefnx {} {@var{r} =} rank (@var{A}, @var{tol})
  ## Compute the numerical rank of a dense arbitrary-precision real or complex
  ## matrix from MPFR/MPC singular values.  The default tolerance is
  ## max(size(A))*sigma_max*Rlamch_mpfr("E") at the operation precision.
  ## The structural rank result is returned as an ordinary Octave scalar.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "rank expects one mp value and an optional real tolerance");
  endif
  if (nargout > 1)
    error ("mplapack:mp:OutputCount", "mp rank returns one output");
  endif

  if (nargin == 1)
    result = __mplapack_core__ ("rank", value);
  else
    tol = varargin{1};
    if (isa (tol, "mp"))
      if (! isreal (tol) || ! isscalar (tol))
        error ("mplapack:mp:InvalidOption", ...
               "rank tolerance must be a real scalar");
      endif
    elseif (! isnumeric (tol) || islogical (tol) || ! isreal (tol)
            || ! isscalar (tol))
      error ("mplapack:mp:InvalidOption", ...
             "rank tolerance must be a real scalar");
    endif
    result = __mplapack_core__ ("rank", value, tol);
  endif
endfunction
