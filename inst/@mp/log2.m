## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} log2 (@dots{})
## Compute the supported arbitrary-precision base-2 logarithm for one @code{mp} value.
## Real inputs use MPFR @code{log2}; complex inputs use the gmpfrxx MPC
## @code{mpfrxx::log2} compatibility wrapper. The operation follows the
## stored-precision and @code{mpbits} contract and never falls back to builtin
## binary64 arithmetic. See the user manual for supported forms, precision,
## and principal-branch behavior.
## @seealso{mp, mpbits}
## @end deftypefn

function result = log2 (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "log2 expects one mp value");
  endif
  payload = __mplapack_core__ ("script_elementary", value, "log2");
  result = mp (0); result.payload_ = payload;
endfunction
