## SPDX-License-Identifier: BSD-2-Clause

## -*- texinfo -*-
## @deftypefn {} {@var{value} =} double (@var{x})
## Explicitly convert @code{mp} value @var{x} to IEEE-754 binary64.
##
## Conversion uses round-to-nearest with ties to even.  Precision may be lost.
## Matrix shape is preserved and each matrix element is converted directly
## from its native MPFR value.
## @end deftypefn

function value = double (input)
  if (nargin != 1 || ! isa (input, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "double expects one mp value");
  endif
  if (__mplapack_core__ ("value_is_matrix", input))
    value = __mplapack_core__ ("matrix_to_double", input);
    return;
  endif

  value = __mplapack_core__ ("scalar_to_double", input);
endfunction
