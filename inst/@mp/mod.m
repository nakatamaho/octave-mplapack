## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} mod (@dots{})
## Compute the supported arbitrary-precision result for the supplied @code{mp} inputs using the documented native backend or package-owned algorithm.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function result = mod (lhs, rhs)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "mod expects two operands");
  endif
  result = mp_binary_utility (lhs, rhs, "mod");
endfunction
