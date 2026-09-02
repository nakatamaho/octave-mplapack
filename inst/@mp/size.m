## SPDX-License-Identifier: BSD-2-Clause

function varargout = size (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{dims} =} size (@var{A})
  ## Return the two-dimensional shape of a dense real @code{mp} value.
  ## @end deftypefn
  if (! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "size expects an mp value");
  endif
  if (numel (varargin) > 1)
    error ("mplapack:mp:InvalidInput", "size accepts at most one dimension");
  endif

  info = __mplapack_core__ ("value_shape_info", value);
  dimensions = [double(info.rows), double(info.columns)];
  if (numel (varargin) == 1)
    dimension = varargin{1};
    if (! isnumeric (dimension) || ! isreal (dimension)
        || ! isscalar (dimension) || ! isfinite (dimension)
        || dimension != fix (dimension) || dimension < 1)
      error ("mplapack:mp:InvalidDimension", ...
             "size dimension must be a positive integer scalar");
    endif
    if (dimension <= 2)
      varargout{1} = dimensions(dimension);
    else
      varargout{1} = 1;
    endif
    return;
  endif

  if (nargout <= 1)
    varargout{1} = dimensions;
  else
    for index = 1:nargout
      if (index <= 2)
        varargout{index} = dimensions(index);
      else
        varargout{index} = 1;
      endif
    endfor
  endif
endfunction
