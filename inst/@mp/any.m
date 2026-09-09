## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} any (@dots{})
## Apply the native arbitrary-precision @code{mp} predicate or logical operation without converting numerical data through builtin @code{double}.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function result = any (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "any expects an mp value");
  endif
  result = __mplapack_core__ ("script_any_all", value, "any", varargin{:});
endfunction
