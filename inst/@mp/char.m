## SPDX-License-Identifier: BSD-2-Clause

## -*- texinfo -*-
## @deftypefn {} {@var{text} =} char (@var{x})
## Return the canonical decimal representation of scalar @code{mp} value
## @var{x}.
##
## The result contains enough digits to reconstruct the same MPFR value when
## parsed at @var{x}'s precision.  It is not necessarily the shortest decimal
## representation or a precision-independent exact serialization.
## @end deftypefn

function text = char (value)
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "char expects one scalar mp value");
  endif
  if (__mplapack_core__ ("value_is_matrix", value))
    error ("mplapack:mp:MatrixConversionUnsupported", ...
           "char conversion for dense mp matrices is not implemented in M10");
  endif

  text = __mplapack_core__ ("scalar_to_canonical_text", value);
endfunction
