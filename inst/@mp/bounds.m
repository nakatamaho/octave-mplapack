## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} bounds (@dots{})
## Compute the dense arbitrary-precision reduction or statistic with native MPFR/MPC values and the documented dimension and NaN rules.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function varargout = bounds (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "bounds expects an mp value");
  endif
  if (nargout > 2)
    error ("mplapack:mp:InvalidOutput", "bounds returns at most two outputs");
  endif
  [lower_payload, upper_payload] = __mplapack_core__ ("script_statistics", value, "bounds", varargin{:});
  varargout{1} = mp_statistic_result (lower_payload);
  if (nargout > 1)
    varargout{2} = mp_statistic_result (upper_payload);
  endif
endfunction
