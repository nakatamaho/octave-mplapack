## SPDX-License-Identifier: BSD-2-Clause

classdef mp
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{x} =} mp (@var{value})
  ## Construct a real multiprecision scalar.
  ##
  ## @var{value} may be scalar decimal text, a real scalar @code{double}, or
  ## an existing scalar @code{mp}.  Decimal text is parsed directly at the
  ## current project precision.  A @code{double} input preserves the exact
  ## numerical value of the already-rounded IEEE binary64 input.
  ##
  ## M06 supports scalars only.  Use @code{mpbits} or @code{mpdigits} to set
  ## the default precision for subsequent values.  Use @code{char},
  ## @code{double}, and @code{disp} for explicit scalar conversion and
  ## display.  Scalar @code{+}, @code{-}, @code{.*}, and @code{./} are
  ## supported.  Matrices, complex values, and matrix operators are not.
  ## @end deftypefn

  properties (Access = private, Hidden = true)
    payload_
  endproperties

  methods
    function obj = mp (varargin)
      if (nargin != 1)
        error ("mplapack:mp:InvalidInput", ...
               "mp expects exactly one scalar input");
      endif
      value = varargin{1};

      if (isa (value, "mp"))
        if (! isscalar (value))
          error ("mplapack:mp:MatrixUnsupported", ...
                 "dense mp matrices are not implemented before M07");
        endif
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
        obj.payload_ = __mplapack_core__ ("scalar_create_text", value);
        return;
      endif

      if (isa (value, "double"))
        if (isempty (value) || ! isscalar (value))
          error ("mplapack:mp:MatrixUnsupported", ...
                 "dense mp matrices are not implemented before M07");
        endif
        if (! isreal (value))
          error ("mplapack:mp:ComplexUnsupported", ...
                 "complex mp values are not supported");
        endif
        obj.payload_ = __mplapack_core__ ("scalar_create_double", value);
        return;
      endif

      if (iscell (value))
        error ("mplapack:mp:MatrixUnsupported", ...
               "cell-based mp matrices are not implemented before M07");
      endif

      if (isnumeric (value) && (! isreal (value)))
        error ("mplapack:mp:ComplexUnsupported", ...
               "complex mp values are not supported");
      endif

      error ("mplapack:mp:InvalidInput", ...
             "mp input must be scalar decimal text, a real double scalar, or mp");
    endfunction
  endmethods
endclassdef
