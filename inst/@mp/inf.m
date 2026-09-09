## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} inf (@dots{})
## Construct dense arbitrary-precision @code{mp} data with the requested shape or special values; template forms preserve the @code{mp} precision.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function result = inf (varargin)
  result = Inf (varargin{:});
endfunction
