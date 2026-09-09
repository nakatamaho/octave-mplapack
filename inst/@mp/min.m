## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} min (@dots{})
## Compute the dense arbitrary-precision reduction or statistic with native MPFR/MPC values and the documented dimension and NaN rules.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function varargout = min (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "min expects an mp value as the first operand");
  endif
  if (nargout > 2)
    error ("mplapack:mp:InvalidOutput", "min returns at most two outputs");
  endif
  if (nargout > 1)
    [payload, indices] = __mplapack_core__ ("script_extremum", value, "min", "value_index", varargin{:});
  else
    payload = __mplapack_core__ ("script_extremum", value, "min", "value", varargin{:});
  endif
  if (! isnumeric (payload))
    result = mp (0);
    result.payload_ = payload;
  else
    result = payload;
  endif
  varargout{1} = result;
  if (nargout > 1)
    varargout{2} = indices;
  endif
endfunction
