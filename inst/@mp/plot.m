## SPDX-License-Identifier: BSD-2-Clause

## -*- texinfo -*-
## @deftypefn {} {@var{h} =} plot (@dots{})
## Plot @code{mp} data through Octave's graphics API. Only the final
## visualization data is explicitly converted to builtin @code{double};
## numerical calculations must be completed before this boundary.
## @seealso{plot3, mp}
## @end deftypefn

function varargout = plot (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("plot", args{:});
  else
    [varargout{1:nargout}] = builtin ("plot", args{:});
  endif
endfunction
