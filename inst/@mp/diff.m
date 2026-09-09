## SPDX-License-Identifier: BSD-2-Clause

function result = diff (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{d} =} diff (@var{A})
  ## @deftypefnx {} {@var{d} =} diff (@var{A}, @var{n})
  ## @deftypefnx {} {@var{d} =} diff (@var{A}, @var{n}, @var{dim})
  ## Compute finite differences using native MPFR/MPC subtraction.
  ## @end deftypefn
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "diff expects an mp value");
  endif
  if (nargout > 1)
    error ("mplapack:mp:OutputCount", "diff returns one output");
  endif

  payload = __mplapack_core__ ("script_diff", value, varargin{:});
  result = value;
  result.payload_ = payload;
endfunction
