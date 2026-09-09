## SPDX-License-Identifier: BSD-2-Clause

function varargout = sort (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{s} =} sort (@var{A})
  ## @deftypefnx {} {@var{s} =} sort (@var{A}, @var{dim})
  ## @deftypefnx {} {@var{s} =} sort (@var{A}, @var{direction})
  ## @deftypefnx {} {[@var{s}, @var{idx}] =} sort (@dots{})
  ## Sort a two-dimensional real or complex @code{mp} matrix using native
  ## MPFR/MPC comparisons.  Complex values are ordered by magnitude and then
  ## phase, matching Octave's complex sort ordering.
  ## @end deftypefn
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "sort expects an mp value");
  endif
  if (nargout > 2)
    error ("mplapack:mp:OutputCount", "sort returns at most two outputs");
  endif

  [payload, indices] = __mplapack_core__ ("script_sort", value, varargin{:});
  result = value;
  result.payload_ = payload;
  varargout{1} = result;
  if (nargout > 1)
    varargout{2} = indices;
  endif
endfunction
