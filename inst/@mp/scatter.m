## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} scatter (@dots{})
## Convert final @code{mp} visualization data at the graphics boundary and call the corresponding Octave graphics routine. Numerical work remains in arbitrary precision until this boundary.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits}
## @end deftypefn

function varargout = scatter (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("scatter", args{:});
  else
    [varargout{1:nargout}] = builtin ("scatter", args{:});
  endif
endfunction
