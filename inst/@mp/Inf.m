## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} Inf (@dots{})
## Construct dense arbitrary-precision @code{mp} data with the requested shape or special values; template forms preserve the @code{mp} precision.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function result = Inf (varargin)
  if (nargin < 2)
    error ("mplapack:mp:InvalidArguments", ...
           "Inf requires dimensions, \"like\", and an mp template");
  endif
  [template, dimensions] = mp_parse_like_constructor (varargin, "Inf");
  payload = __mplapack_core__ ("script_structure", "like", "inf", ...
                               template, dimensions{:});
  result = template;
  result.payload_ = payload;
endfunction
