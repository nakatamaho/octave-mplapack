## SPDX-License-Identifier: BSD-2-Clause

function obj = mp (varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{x} =} mp (@var{value})
  ## Construct an arbitrary-precision real or complex scalar or dense matrix.
  ##
  ## @var{value} may be scalar decimal text, a real or complex @code{double}
  ## scalar or matrix, a two-dimensional cell matrix of scalar decimal text,
  ## or an existing @code{mp}.  Text is parsed directly at the current project
  ## precision.  @code{double} input preserves each already-rounded IEEE
  ## binary64 value exactly when transferring it to MPFR.
  ##
  ## The legacy user-class representation is used because Octave 11.1 invokes
  ## @code{saveobj} for this form.  Normal values contain only a native
  ## MPFR/MPC payload; the save hook replaces that payload by the versioned
  ## exact serialization struct before Octave writes the object.
  ## @end deftypefn

  if (nargin == 2)
    if (! ischar (varargin{1}) || ! ischar (varargin{2})
        || isempty (varargin{1}) || isempty (varargin{2})
        || rows (varargin{1}) != 1 || rows (varargin{2}) != 1)
      error ("mplapack:mp:InvalidInput", ...
             "mp expects exactly one scalar input");
    endif
    payload = __mplapack_core__ ("scalar_create_complex_text", ...
                                 varargin{1}, varargin{2});
    obj = class (struct ("payload_", payload), "mp");
    return;
  endif

  if (nargin != 1)
    error ("mplapack:mp:InvalidInput", ...
           "mp expects exactly one scalar input");
  endif
  value = varargin{1};

  if (isa (value, "mp"))
    obj = value;
    return;
  endif

  if (ischar (value))
    if (isempty (value))
      error ("mplapack:mp:InvalidInput", ...
             "mp scalar text must not be empty");
    endif
    if (rows (value) != 1)
      error ("mplapack:mp:MatrixUnsupported", ...
             "text arrays are not implemented before M07");
    endif
    if (value(1) == '(')
      payload = __mplapack_core__ ("scalar_create_complex_text_single", value);
    else
      payload = __mplapack_core__ ("scalar_create_text", value);
    endif
    obj = class (struct ("payload_", payload), "mp");
    return;
  endif

  if (isa (value, "double"))
    if (! isreal (value))
      if (ndims (value) != 2)
        error ("mplapack:mp:MatrixUnsupported", ...
               "only two-dimensional mp matrices are supported");
      endif
      if (numel (value) == 1)
        payload = __mplapack_core__ ("scalar_create_complex_double", value);
      else
        payload = __mplapack_core__ ("matrix_create_complex_double", value);
      endif
      obj = class (struct ("payload_", payload), "mp");
      return;
    endif
    if (ndims (value) != 2)
      error ("mplapack:mp:MatrixUnsupported", ...
             "only two-dimensional mp matrices are supported");
    endif
    if (numel (value) == 1)
      payload = __mplapack_core__ ("scalar_create_double", value);
    else
      payload = __mplapack_core__ ("matrix_create_double", value);
    endif
    obj = class (struct ("payload_", payload), "mp");
    return;
  endif

  if (iscell (value))
    if (ndims (value) != 2)
      error ("mplapack:mp:MatrixUnsupported", ...
             "only two-dimensional mp matrices are supported");
    endif
    if (numel (value) == 1)
      element = value{1};
      if (! ischar (element) || isempty (element) || rows (element) != 1)
        error ("mplapack:mp:InvalidInput", ...
               "a 1x1 cell constructor requires one nonempty text row");
      endif
      if (element(1) == '(')
        payload = __mplapack_core__ ("scalar_create_complex_text_single", element);
      else
        payload = __mplapack_core__ ("scalar_create_text", element);
      endif
    else
      is_complex_text = false;
      for index = 1:numel (value)
        element = value{index};
        if (ischar (element) && ! isempty (element)
            && rows (element) == 1 && element(1) == '(')
          is_complex_text = true;
          break;
        endif
      endfor
      if (is_complex_text)
        payload = __mplapack_core__ ("matrix_create_complex_text_cell", value);
      else
        payload = __mplapack_core__ ("matrix_create_text_cell", value);
      endif
    endif
    obj = class (struct ("payload_", payload), "mp");
    return;
  endif

  if (isnumeric (value) && (! isreal (value)))
    error ("mplapack:mp:InvalidInput", ...
           "unsupported complex input type");
  endif

  error ("mplapack:mp:InvalidInput", ...
         ["mp input must be decimal text, a real double scalar/matrix, ", ...
          "a text cell matrix, or mp"]);
endfunction
