## SPDX-License-Identifier: BSD-2-Clause

## -*- texinfo -*-
## @deftypefn {} {@var{value} =} double (@var{x})
## Explicitly convert scalar @code{mp} value @var{x} to IEEE-754 binary64.
##
## Conversion uses round-to-nearest with ties to even.  Precision may be lost.
## @end deftypefn

function value = double (input)
  if (nargin != 1 || ! isa (input, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "double expects one scalar mp value");
  endif
  if (__mplapack_core__ ("value_is_matrix", input))
    error ("mplapack:mp:MatrixConversionUnsupported", ...
           "double conversion for dense mp matrices is not implemented in M07");
  endif

  value = __mplapack_core__ ("scalar_to_double", input);
endfunction
