## SPDX-License-Identifier: BSD-2-Clause

function varargout = qr (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{R} =} qr (@var{A})
  ## @deftypefnx {} {[@var{Q}, @var{R}] =} qr (@var{A})
  ## @deftypefnx {} {@var{R} =} qr (@var{A}, "econ")
  ## @deftypefnx {} {[@var{Q}, @var{R}] =} qr (@var{A}, "econ")
  ## Compute dense MPFR QR for real or complex input.  One output is R and two outputs are Q,R;
  ## three outputs request column-pivoted QR with a matrix or vector
  ## permutation output.  The numeric 0 option is a deprecated economy
  ## compatibility form.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "qr expects one mp value and an optional econ flag");
  endif
  if (nargout > 3)
    error ("mplapack:mp:OutputCount", ...
           "dense mp qr returns at most Q, R, and a permutation");
  endif

  mode = "full";
  permutation = "matrix";
  if (nargin == 2)
    option = varargin{1};
    if (ischar (option) || isstring (option))
      option = char (option);
      if (strcmp (option, "econ"))
        mode = "econ";
      elseif (strcmp (option, "matrix"))
        permutation = "matrix";
      elseif (strcmp (option, "vector"))
        permutation = "vector";
      else
        error ("mplapack:mp:InvalidOption", ...
               "qr option must be \"econ\", \"matrix\", or \"vector\"");
      endif
    elseif (isnumeric (option) && ! islogical (option)
            && isreal (option) && isscalar (option)
            && option == 0)
      mode = "econ";
      permutation = "vector";
    else
      error ("mplapack:mp:InvalidOption", ...
             "qr option must be \"econ\", \"matrix\", \"vector\", or deprecated numeric 0");
    endif
  endif

  if (nargout <= 2)
    if (nargout <= 1)
      payload = __mplapack_core__ ("qr", value, mode, "r");
      result = value;
      result.payload_ = payload;
      varargout{1} = result;
    else
      [q_payload, r_payload] = __mplapack_core__ ("qr", value, mode, "qr");
      q_result = value;
      q_result.payload_ = q_payload;
      r_result = value;
      r_result.payload_ = r_payload;
      varargout{1} = q_result;
      varargout{2} = r_result;
    endif
  elseif (nargout == 3)
    [q_payload, r_payload, permutation_payload] = __mplapack_core__ (
      "qr_pivoted", value, mode, permutation);
    q_result = value;
    q_result.payload_ = q_payload;
    r_result = value;
    r_result.payload_ = r_payload;
    varargout{1} = q_result;
    varargout{2} = r_result;
    varargout{3} = permutation_payload;
  endif
endfunction
