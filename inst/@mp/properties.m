## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} properties (@dots{})
## Inspect the public @code{mp} value metadata and stored precision.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function result = properties (value)
  ## The native payload is an implementation detail and is not a public
  ## property of an mp value.
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "properties expects one mp value");
  endif
  result = cell (0, 1);
endfunction
