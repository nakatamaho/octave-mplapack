## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} logical (@dots{})
## Apply the native arbitrary-precision @code{mp} predicate or logical operation without converting numerical data through builtin @code{double}.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function result = logical (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "logical expects one mp value");
  endif
  result = ! __mplapack_core__ ("script_logical", value, "not");
endfunction
