## SPDX-License-Identifier: BSD-2-Clause

function result = diag (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} diag (@var{value})
  ## @deftypefnx {} {@var{result} =} diag (@var{value}, @var{k})
  ## Extract or construct a dense two-dimensional @code{mp} diagonal matrix.
  ## The source precision and real/complex storage kind are preserved.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidArguments", ...
           "diag expects an mp value and an optional offset");
  endif
  if (nargin == 1)
    payload = __mplapack_core__ ("script_structure", value, "diag");
  else
    payload = __mplapack_core__ ("script_structure", value, "diag", ...
                                 varargin{1});
  endif
  result = value;
  result.payload_ = payload;
endfunction
