## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} waterfall (@dots{})
## Convert final @code{mp} visualization data at the graphics boundary and call the corresponding Octave graphics routine. Numerical work remains in arbitrary precision until this boundary.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function varargout = waterfall (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("waterfall", args{:});
  else
    [varargout{1:nargout}] = builtin ("waterfall", args{:});
  endif
endfunction
