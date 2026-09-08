## SPDX-License-Identifier: BSD-2-Clause

function varargout = surf (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("surf", args{:});
  else
    [varargout{1:nargout}] = builtin ("surf", args{:});
  endif
endfunction
