## SPDX-License-Identifier: BSD-2-Clause

function varargout = loglog (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("loglog", args{:});
  else
    [varargout{1:nargout}] = builtin ("loglog", args{:});
  endif
endfunction
