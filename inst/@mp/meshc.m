## SPDX-License-Identifier: BSD-2-Clause

function varargout = meshc (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("meshc", args{:});
  else
    [varargout{1:nargout}] = builtin ("meshc", args{:});
  endif
endfunction
