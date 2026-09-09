## SPDX-License-Identifier: BSD-2-Clause

## -*- texinfo -*-
## @deftypefn {} {@var{h} =} plot3 (@dots{})
## Plot three-dimensional @code{mp} data through Octave's graphics API.
## Only final visualization data is converted to builtin @code{double}; no
## numerical operation uses this graphics conversion.
## @seealso{plot, mp}
## @end deftypefn

function varargout = plot3 (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("plot3", args{:});
  else
    [varargout{1:nargout}] = builtin ("plot3", args{:});
  endif
endfunction
