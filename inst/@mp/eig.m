## SPDX-License-Identifier: BSD-2-Clause

function varargout = eig (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{lambda} =} eig (@var{A})
  ## @deftypefnx {} {[@var{V}, @var{D}] =} eig (@var{A})
  ## @deftypefnx {} {[@var{V}, @var{D}, @var{W}] =} eig (@var{A}, @var{B})
  ## @deftypefnx {} {[@var{V}, @var{d}] =} eig (@var{A}, "vector")
  ## Compute dense arbitrary-precision standard and generalized eigenproblems
  ## through the corresponding MPLAPACK MPFR/MPC drivers.  A generalized
  ## problem accepts the Octave-compatible "chol" and "qz" algorithm options;
  ## an exactly symmetric/Hermitian positive-definite pair selects the
  ## Cholesky-definite path by default and otherwise uses the QZ path.
  ## @end deftypefn
  if (nargin < 1 || nargin > 4 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "eig expects an mp value and at most three options/operands");
  endif
  if (nargout > 3)
    error ("mplapack:mp:OutputCount", ...
           "mp eig returns at most three outputs");
  endif

  is_generalized = (nargin >= 2 && isa (varargin{1}, "mp"));
  mode = "matrix";

  if (is_generalized)
    other = varargin{1};
    algorithm = "auto";
    algorithm_seen = false;
    mode_seen = false;
    for k = 2:numel (varargin)
      option = varargin{k};
      if (! ischar (option) && ! isstring (option))
        error ("mplapack:mp:InvalidOption", ...
               "generalized eig option must be \"chol\", \"qz\", \"matrix\", or \"vector\"");
      endif
      option = char (option);
      if (strcmp (option, "chol") || strcmp (option, "qz"))
        if (algorithm_seen)
          error ("mplapack:mp:InvalidOption", ...
                 "generalized eig algorithm options are mutually exclusive");
        endif
        algorithm = option;
        algorithm_seen = true;
      elseif (strcmp (option, "matrix") || strcmp (option, "vector"))
        if (mode_seen)
          error ("mplapack:mp:InvalidOption", ...
                 "generalized eig output options may be specified only once");
        endif
        mode = option;
        mode_seen = true;
      else
        error ("mplapack:mp:InvalidOption", ...
               "generalized eig option must be \"chol\", \"qz\", \"matrix\", or \"vector\"");
      endif
    endfor

    if (nargout <= 1)
      if (strcmp (mode, "matrix") && mode_seen)
        output_mode = "diagonal";
      else
        output_mode = "values";
      endif
      [payload] = __mplapack_core__ ("geig", value, other, output_mode, algorithm);
      result = mp (0);
      result.payload_ = payload;
      varargout{1} = result;
    elseif (nargout == 3)
      if (strcmp (mode, "vector"))
        output_mode = "left-vector";
      else
        output_mode = "left";
      endif
      [v_payload, d_payload, w_payload] = __mplapack_core__ (
        "geig", value, other, output_mode, algorithm);
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
      if (strcmp (mode, "vector"))
        output_mode = "vector";
      else
        output_mode = "matrix";
      endif
      [v_payload, d_payload] = __mplapack_core__ (
        "geig", value, other, output_mode, algorithm);
      v_result = mp (0);
      v_result.payload_ = v_payload;
      d_result = mp (0);
      d_result.payload_ = d_payload;
      varargout{1} = v_result;
      varargout{2} = d_result;
    endif
    return;
  endif

  balance_mode = "auto";
  mode_seen = false;
  balance_seen = false;
  for k = 1:numel (varargin)
    option = varargin{k};
    if (! ischar (option) && ! isstring (option))
      error ("mplapack:mp:InvalidOption", ...
             "eig option must be \"matrix\", \"vector\", \"balance\", or \"nobalance\"");
    endif
    option = char (option);
    if (strcmp (option, "matrix") || strcmp (option, "vector"))
      if (mode_seen)
        error ("mplapack:mp:InvalidOption", ...
               "eig output options may be specified only once");
      endif
      mode = option;
      mode_seen = true;
    elseif (strcmp (option, "balance") || strcmp (option, "nobalance"))
      if (balance_seen)
        error ("mplapack:mp:InvalidOption", ...
               "eig balance options may be specified only once");
      endif
      balance_mode = option;
      balance_seen = true;
    else
      error ("mplapack:mp:InvalidOption", ...
             "eig option must be \"matrix\", \"vector\", \"balance\", or \"nobalance\"");
    endif
  endfor

  if (nargout <= 1)
    if (strcmp (mode, "matrix") && mode_seen)
      output_mode = "diagonal";
    else
      output_mode = "values";
    endif
    [payload] = __mplapack_core__ ("eig", value, output_mode, balance_mode);
    result = mp (0);
    result.payload_ = payload;
    varargout{1} = result;
  elseif (nargout == 3)
    if (strcmp (mode, "vector"))
      output_mode = "left-vector";
    else
      output_mode = "left";
    endif
    [v_payload, d_payload, w_payload] = __mplapack_core__ (
      "eig", value, output_mode, balance_mode);
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
    if (strcmp (mode, "vector"))
      output_mode = "vector";
    else
      output_mode = "matrix";
    endif
    [v_payload, d_payload] = __mplapack_core__ (
      "eig", value, output_mode, balance_mode);
    v_result = mp (0);
    v_result.payload_ = v_payload;
    d_result = mp (0);
    d_result.payload_ = d_payload;
    varargout{1} = v_result;
    varargout{2} = d_result;
  endif
endfunction
