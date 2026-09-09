## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} median (@dots{})
## Compute the dense arbitrary-precision reduction or statistic with native MPFR/MPC values and the documented dimension and NaN rules.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function result = median (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "median expects an mp value");
  endif
  if (nargout > 1)
    error ("mplapack:mp:InvalidOutput", "median returns one output");
  endif
  payload = __mplapack_core__ ("script_statistics", value, "median", varargin{:});
  result = mp_statistic_result (payload);
endfunction
