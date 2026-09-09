## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} find (@dots{})
## Compute the dense arbitrary-precision reduction or statistic with native MPFR/MPC values and the documented dimension and NaN rules.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function varargout = find (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "find expects an mp value");
  endif
  if (nargout > 3)
    error ("mplapack:mp:OutputCount", "find returns at most three outputs");
  endif
  outputs = cell (1, max (1, nargout));
  [outputs{:}] = __mplapack_core__ ("script_find", value, nargout, varargin{:});
  if (nargout >= 3)
    selected = value;
    selected.payload_ = outputs{3};
    outputs{3} = selected;
  endif
  for index = 1:nargout
    varargout{index} = outputs{index};
  endfor
endfunction
