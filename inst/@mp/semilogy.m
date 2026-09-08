## SPDX-License-Identifier: BSD-2-Clause

function varargout = semilogy (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("semilogy", args{:});
  else
    [varargout{1:nargout}] = builtin ("semilogy", args{:});
  endif
endfunction
