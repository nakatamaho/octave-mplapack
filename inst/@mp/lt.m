## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} lt (@dots{})
## Apply the native arbitrary-precision @code{mp} predicate or logical operation without converting numerical data through builtin @code{double}.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function result = lt (lhs, rhs)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "mp less-than expects two operands");
  endif
  result = __mplapack_core__ ("script_compare", lhs, rhs, "lt");
endfunction
