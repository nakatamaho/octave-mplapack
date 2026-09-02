## SPDX-License-Identifier: BSD-2-Clause

classdef mp
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{x} =} mp (@var{value})
  ## Construct a real multiprecision scalar or dense matrix.
  ##
  ## @var{value} may be scalar decimal text, a real @code{double} scalar or
  ## matrix, a two-dimensional cell matrix of scalar decimal text, or an
  ## existing @code{mp}.  Text is parsed directly at the current project
  ## precision.  @code{double} input preserves each already-rounded IEEE
  ## binary64 value exactly when transferring it to MPFR.
  ##
  ## Empty real matrices retain their two-dimensional shape.  A @code{1x1}
  ## numeric or text-cell input normalizes to the canonical scalar payload.
  ## Dense matrix multiplication uses MPLAPACK MPFR @code{Rgemm} under a
  ## uniform operation-precision scope.  M09 adds square matrix left division
  ## through MPLAPACK MPFR Rgesv. M10 adds read-only matrix indexing,
  ## `double`, and `disp`. M11 adds native element-wise arithmetic with 2-D
  ## singleton expansion. M12 adds read-only transpose, conjugate transpose for
  ## real values, and column-major reshape. M13 adds native horizontal and
  ## vertical concatenation returning one dense `mp` value. M14 adds limited
  ## in-bounds value-semantic indexed assignment; matrix `char` remains
  ## deferred. Complex,
  ## N-dimensional, mixed-cell, and cell-of-@code{mp} inputs are unsupported.
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
        if (! isreal (value))
          if (isscalar (value))
            error ("mplapack:mp:ComplexUnsupported", ...
                   "complex mp values are not supported");
          else
            error ("mplapack:mp:ComplexUnsupported", ...
                   "complex mp matrices are not supported");
          endif
        endif
        if (ndims (value) != 2)
          error ("mplapack:mp:MatrixUnsupported", ...
                 "only two-dimensional mp matrices are supported");
        endif
        if (numel (value) == 1)
          obj.payload_ = __mplapack_core__ ("scalar_create_double", value);
        else
          obj.payload_ = __mplapack_core__ ("matrix_create_double", value);
        endif
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
          obj.payload_ = __mplapack_core__ ("scalar_create_text", element);
        else
          obj.payload_ = __mplapack_core__ ("matrix_create_text_cell", value);
        endif
        return;
      endif

      if (isnumeric (value) && (! isreal (value)))
        error ("mplapack:mp:ComplexUnsupported", ...
               "complex mp values are not supported");
      endif

      error ("mplapack:mp:InvalidInput", ...
             ["mp input must be decimal text, a real double scalar/matrix, ", ...
              "a text cell matrix, or mp"]);
    endfunction
  endmethods
endclassdef
