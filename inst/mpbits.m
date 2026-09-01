## -*- texinfo -*-
## @deftypefn  {} {@var{bits} =} mpbits ()
## @deftypefnx {} {@var{bits} =} mpbits (@var{n})
## Return or set the default precision, in bits, for subsequently created
## @code{mp} values.
##
## The initial default is 512 bits.  Setting the default does not alter or
## re-round existing values.  With an output, the setter returns the resulting
## current default.
## @end deftypefn
function value = mpbits (varargin)
  if (nargin > 1)
    error ("mplapack:mpbits:InvalidPrecision", ...
           "mpbits accepts zero or one precision argument");
  endif

  if (nargin == 0)
    value = __mplapack_core__ ("precision_get_bits");
  else
    value = __mplapack_core__ ("precision_set_bits", varargin{1});
  endif
endfunction
