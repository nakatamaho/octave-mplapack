## SPDX-License-Identifier: BSD-2-Clause

function varargout = mesh (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("mesh", args{:});
  else
    [varargout{1:nargout}] = builtin ("mesh", args{:});
  endif
endfunction
