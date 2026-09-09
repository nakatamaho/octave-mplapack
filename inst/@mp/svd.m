## SPDX-License-Identifier: BSD-2-Clause

function varargout = svd (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{s} =} svd (@var{A})
  ## @deftypefnx {} {[@var{U}, @var{S}, @var{V}] =} svd (@var{A})
  ## @deftypefnx {} {[@var{U}, @var{S}, @var{V}] =} svd (@var{A}, "econ")
  ## Compute dense arbitrary-precision real or complex SVD through MPLAPACK
  ## @code{Rgesvd} or @code{Cgesvd}.  The numeric zero option is the
  ## deprecated economy compatibility form.  Singular values are real @code{mp}
  ## values for both real and complex inputs.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "svd expects one mp value and an optional econ flag");
  endif
  if (nargout == 2 || nargout > 3)
    error ("mplapack:mp:OutputCount", ...
           "dense mp svd returns one output or U, S, and V");
  endif

  mode = "full";
  if (nargin == 2)
    option = varargin{1};
    if (ischar (option) || isstring (option))
      option = char (option);
      if (strcmp (option, "econ"))
        mode = "econ";
      else
        error ("mplapack:mp:InvalidOption", ...
               "svd option must be \"econ\" or deprecated numeric 0");
      endif
    elseif (isnumeric (option) && ! islogical (option)
            && isreal (option) && isscalar (option)
            && option == 0)
      mode = "econ";
    else
      error ("mplapack:mp:InvalidOption", ...
             "svd option must be \"econ\" or deprecated numeric 0");
    endif
  endif

  if (nargout <= 1)
    payload = __mplapack_core__ ("svd", value, mode, "values");
    result = mp (0);
    result.payload_ = payload;
    varargout{1} = result;
  else
    [u_payload, s_payload, v_payload] = __mplapack_core__ (
      "svd", value, mode, "factors");
    u_result = value;
    u_result.payload_ = u_payload;
    s_result = mp (0);
    s_result.payload_ = s_payload;
    v_result = value;
    v_result.payload_ = v_payload;
    varargout{1} = u_result;
    varargout{2} = s_result;
    varargout{3} = v_result;
  endif
endfunction
