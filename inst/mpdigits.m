## -*- texinfo -*-
## @deftypefn  {} {@var{digits} =} mpdigits ()
## @deftypefnx {} {@var{digits} =} mpdigits (@var{n})
## Return or set the default precision in complete base-10 significant digits.
##
## @code{mpdigits (@var{n})} selects
## @code{ceil (@var{n} * log2 (10))} bits for subsequently created
## @code{mp} values, with no hidden guard bits.  Existing values are unchanged.
## With an output, the setter returns the resulting guaranteed digit count.
## @end deftypefn
function value = mpdigits (varargin)
  if (nargin > 1)
    error ("mplapack:mpdigits:InvalidPrecision", ...
           "mpdigits accepts zero or one precision argument");
  endif

  if (nargin == 0)
    value = __mplapack_core__ ("precision_get_digits");
  else
    value = __mplapack_core__ ("precision_set_digits", varargin{1});
  endif
endfunction
