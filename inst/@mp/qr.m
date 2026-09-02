## SPDX-License-Identifier: BSD-2-Clause

function varargout = qr (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{R} =} qr (@var{A})
  ## @deftypefnx {} {[@var{Q}, @var{R}] =} qr (@var{A})
  ## @deftypefnx {} {@var{R} =} qr (@var{A}, "econ")
  ## @deftypefnx {} {[@var{Q}, @var{R}] =} qr (@var{A}, "econ")
  ## Compute a non-pivoted dense real MPFR QR factorization.  A single
  ## output is R; two outputs are Q and R.  The numeric 0 option is accepted
  ## as a deprecated economy alias for compatibility with Octave.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "qr expects one mp value and an optional econ flag");
  endif
  if (nargout > 2)
    error ("mplapack:mp:OutputCount", ...
           "dense mp qr returns at most Q and R");
  endif

  mode = "full";
  if (nargin == 2)
    option = varargin{1};
    if (ischar (option) || isstring (option))
      option = char (option);
      if (! strcmp (option, "econ"))
        error ("mplapack:mp:InvalidOption", ...
               "qr option must be \"econ\" (pivoted options are unsupported)");
      endif
      mode = "econ";
    elseif (isnumeric (option) && ! islogical (option)
            && isreal (option) && isscalar (option)
            && option == 0)
      mode = "econ";
    else
      error ("mplapack:mp:InvalidOption", ...
             "qr option must be \"econ\" or deprecated numeric 0");
    endif
  endif

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
endfunction
