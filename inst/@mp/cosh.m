## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} cosh (@dots{})
## Compute the supported arbitrary-precision result for the supplied @code{mp} inputs using the documented native backend or package-owned algorithm.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function result = cosh (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "cosh expects one mp value");
  endif
  payload = __mplapack_core__ ("script_elementary", value, "cosh");
  result = mp (0); result.payload_ = payload;
endfunction
