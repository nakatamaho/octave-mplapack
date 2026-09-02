## SPDX-License-Identifier: BSD-2-Clause

function varargout = lu (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{Y} =} lu (@var{A})
  ## @deftypefnx {} {[@var{L}, @var{U}] =} lu (@var{A})
  ## @deftypefnx {} {[@var{L}, @var{U}, @var{P}] =} lu (@var{A})
  ## @deftypefnx {} {[@var{L}, @var{U}, @var{p}] =} lu (@var{A}, "vector")
  ## Compute dense real MPFR LU through MPLAPACK @code{Rgetrf}.  One output
  ## is the packed LAPACK factor.  Two outputs absorb row permutation into
  ## L so that A = L*U; three outputs return P so that P*A = L*U.  The
  ## @code{"vector"} option returns the final 1-based row permutation vector.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "lu expects one mp value and an optional vector flag");
  endif
  if (nargout > 3)
    error ("mplapack:mp:OutputCount", ...
           "dense mp lu returns at most three outputs");
  endif

  vector_option = false;
  if (nargin == 2)
    option = varargin{1};
    if (! ischar (option) && ! isstring (option))
      error ("mplapack:mp:InvalidOption", ...
             "lu option must be \"vector\"");
    endif
    option = char (option);
    if (! strcmp (option, "vector"))
      error ("mplapack:mp:InvalidOption", ...
             "lu option must be \"vector\"");
    endif
    vector_option = true;
  endif

  if (nargout <= 1)
    payload = __mplapack_core__ ("lu", value, "packed");
    result = value;
    result.payload_ = payload;
    varargout{1} = result;
  elseif (nargout == 2)
    [l_payload, u_payload] = __mplapack_core__ ("lu", value, "two");
    l_result = value;
    l_result.payload_ = l_payload;
    u_result = value;
    u_result.payload_ = u_payload;
    varargout{1} = l_result;
    varargout{2} = u_result;
  else
    mode = "matrix";
    if (vector_option)
      mode = "vector";
    endif
    [l_payload, u_payload, permutation] = __mplapack_core__ (
      "lu", value, mode);
    l_result = value;
    l_result.payload_ = l_payload;
    u_result = value;
    u_result.payload_ = u_payload;
    varargout{1} = l_result;
    varargout{2} = u_result;
    varargout{3} = permutation;
  endif
endfunction
