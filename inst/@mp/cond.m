## SPDX-License-Identifier: BSD-2-Clause

function result = cond (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{c} =} cond (@var{A})
  ## @deftypefnx {} {@var{c} =} cond (@var{A}, @var{p})
  ## Compute a dense arbitrary-precision condition number.  The default and
  ## p=2 paths use Rgesvd/Cgesvd; p=1 and p=Inf use Rgecon/Cgecon; and the
  ## "fro" spelling uses the singular values at the stored operation
  ## precision.  Results are real arbitrary-precision scalars.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "cond expects one mp value and an optional norm selector");
  endif
  if (nargout > 1)
    error ("mplapack:mp:OutputCount", "mp cond returns one output");
  endif

  option = "two";
  if (nargin == 2)
    request = varargin{1};
    if (ischar (request) || isstring (request))
      request = char (request);
      if (strcmp (request, "fro"))
        option = "frobenius";
      else
        error ("mplapack:mp:InvalidOption", ...
               "cond string option must be \"fro\"");
      endif
    elseif (isnumeric (request) && ! islogical (request)
            && isreal (request) && isscalar (request))
      if (request == 1)
        option = "one";
      elseif (request == 2)
        option = "two";
      elseif (isinf (request) && request > 0)
        option = "infinity";
      else
        error ("mplapack:mp:InvalidOption", ...
               "cond norm must be 1, 2, Inf, or \"fro\"");
      endif
    else
      error ("mplapack:mp:InvalidOption", ...
             "cond norm must be 1, 2, Inf, or \"fro\"");
    endif
  endif

  payload = __mplapack_core__ ("cond", value, option);
  result = mp (0);
  result.payload_ = payload;
endfunction
