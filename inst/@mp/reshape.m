## SPDX-License-Identifier: BSD-2-Clause

function result = reshape (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} reshape (@var{value}, @var{m}, @var{n})
  ## @deftypefnx {} {@var{result} =} reshape (@var{value}, [@var{m} @var{n}])
  ## Reshape a real scalar or dense matrix @code{mp} value while preserving
  ## its column-major element order and stored precision.  One @code{[]} may
  ## be used for an inferred dimension.
  ## @end deftypefn
  if (nargin != 2 && nargin != 3)
    error ("mplapack:mp:InvalidArguments", ...
           "reshape expects a value and one or two dimensions");
  endif
  if (! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "reshape expects an mp value");
  endif

  if (numel (varargin) == 1)
    payload = __mplapack_core__ ("matrix_reshape", value, varargin{1});
  else
    payload = __mplapack_core__ ("matrix_reshape", value, varargin{1}, ...
                                 varargin{2});
  endif
  result = value;
  result.payload_ = payload;
endfunction
