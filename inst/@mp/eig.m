## SPDX-License-Identifier: BSD-2-Clause

function varargout = eig (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{lambda} =} eig (@var{A})
  ## @deftypefnx {} {[@var{V}, @var{D}] =} eig (@var{A})
  ## @deftypefnx {} {[@var{V}, @var{d}] =} eig (@var{A}, "vector")
  ## Compute dense arbitrary-precision eigenproblems through MPLAPACK
  ## @code{Rsyevd}/@code{Cheevd} for structured inputs and
  ## @code{Rgeevx}/@code{Cgeevx} for general inputs.  The explicit balance
  ## controls select the corresponding expert-driver path.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "eig expects one mp value and an optional output/balance flag");
  endif
  if (nargout > 3)
    error ("mplapack:mp:OutputCount", ...
           "mp eig returns at most three outputs");
  endif

  mode = "matrix";
  balance_mode = "auto";
  if (nargin == 2)
    option = varargin{1};
    if (! ischar (option) && ! isstring (option))
      error ("mplapack:mp:InvalidOption", ...
             "eig option must be \"matrix\", \"vector\", \"balance\", or \"nobalance\"");
    endif
    option = char (option);
    if (strcmp (option, "matrix") || strcmp (option, "vector"))
      mode = option;
    elseif (strcmp (option, "balance") || strcmp (option, "nobalance"))
      balance_mode = option;
    else
      error ("mplapack:mp:InvalidOption", ...
             "eig option must be \"matrix\", \"vector\", \"balance\", or \"nobalance\"");
    endif
    if ((strcmp (option, "matrix") || strcmp (option, "vector")) ...
        && nargout <= 1)
      error ("mplapack:mp:InvalidOption", ...
             "eig's matrix/vector option requires two outputs");
    endif
    if (nargout == 3 && strcmp (option, "vector"))
      error ("mplapack:mp:InvalidOption", ...
             "eig's vector option is not available with left eigenvectors");
    endif
  endif

  if (nargout <= 1)
    payload = __mplapack_core__ ("eig", value, "values", balance_mode);
    result = mp (0);
    result.payload_ = payload;
    varargout{1} = result;
  elseif (nargout == 3)
    [v_payload, d_payload, w_payload] = __mplapack_core__ (
      "eig", value, "left", balance_mode);
    v_result = mp (0);
    v_result.payload_ = v_payload;
    d_result = mp (0);
    d_result.payload_ = d_payload;
    w_result = mp (0);
    w_result.payload_ = w_payload;
    varargout{1} = v_result;
    varargout{2} = d_result;
    varargout{3} = w_result;
  else
    [v_payload, d_payload] = __mplapack_core__ (
      "eig", value, mode, balance_mode);
    v_result = mp (0);
    v_result.payload_ = v_payload;
    d_result = mp (0);
    d_result.payload_ = d_payload;
    varargout{1} = v_result;
    varargout{2} = d_result;
  endif
endfunction
