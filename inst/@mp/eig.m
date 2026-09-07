## SPDX-License-Identifier: BSD-2-Clause

function varargout = eig (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{lambda} =} eig (@var{A})
  ## @deftypefnx {} {[@var{V}, @var{D}] =} eig (@var{A})
  ## @deftypefnx {} {[@var{V}, @var{d}] =} eig (@var{A}, "vector")
  ## Compute the structured standard eigenproblem for a dense real symmetric
  ## or complex Hermitian arbitrary-precision @code{mp} matrix through
  ## MPLAPACK @code{Rsyevd} or @code{Cheevd}.  General and generalized
  ## eigenproblems are deliberately deferred to later milestones.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "eig expects one mp value and an optional matrix/vector flag");
  endif
  if (nargout > 2)
    error ("mplapack:mp:OutputCount", ...
           "structured mp eig returns at most two outputs");
  endif

  mode = "matrix";
  if (nargin == 2)
    option = varargin{1};
    if (! ischar (option) && ! isstring (option))
      error ("mplapack:mp:InvalidOption", ...
             "eig option must be \"matrix\" or \"vector\"");
    endif
    mode = char (option);
    if (! strcmp (mode, "matrix") && ! strcmp (mode, "vector"))
      error ("mplapack:mp:InvalidOption", ...
             "eig option must be \"matrix\" or \"vector\"");
    endif
    if (nargout <= 1)
      error ("mplapack:mp:InvalidOption", ...
             "eig's matrix/vector option requires two outputs");
    endif
  endif

  if (nargout <= 1)
    payload = __mplapack_core__ ("eig", value, "values");
    result = mp (0);
    result.payload_ = payload;
    varargout{1} = result;
  else
    [v_payload, d_payload] = __mplapack_core__ ("eig", value, mode);
    v_result = value;
    v_result.payload_ = v_payload;
    d_result = mp (0);
    d_result.payload_ = d_payload;
    varargout{1} = v_result;
    varargout{2} = d_result;
  endif
endfunction
