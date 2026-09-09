## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} ne (@dots{})
## Apply the native arbitrary-precision @code{mp} predicate or logical operation without converting numerical data through builtin @code{double}.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function result = ne (lhs, rhs)
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", "mp inequality expects two operands");
  endif
  result = __mplapack_core__ ("script_compare", lhs, rhs, "ne");
endfunction
