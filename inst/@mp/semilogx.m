## SPDX-License-Identifier: BSD-2-Clause

function varargout = semilogx (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("semilogx", args{:});
  else
    [varargout{1:nargout}] = builtin ("semilogx", args{:});
  endif
endfunction
