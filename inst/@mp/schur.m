## SPDX-License-Identifier: BSD-2-Clause

function varargout = schur (value, varargin)
  ## @deftypefn {} {@var{S} =} schur (@var{A})
  ## @deftypefnx {} {[@var{U}, @var{S}] =} schur (@var{A}, @var{type})
  ## Compute an unordered arbitrary-precision Schur decomposition.  The
  ## type is "real" (the default for real input) or "complex".  The result
  ## satisfies S = U'*A*U; real Schur output can contain 2-by-2 blocks.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "schur expects one mp value and an optional real/complex flag");
  endif
  if (nargout > 2)
    error ("mplapack:mp:OutputCount", "mp schur returns S or U,S");
  endif

  option = "real";
  if (nargin == 2)
    if (! ischar (varargin{1}) && ! isstring (varargin{1}))
      error ("mplapack:mp:InvalidOption", ...
             "schur option must be \"real\" or \"complex\"");
    endif
    option = char (varargin{1});
    if (! strcmp (option, "real") && ! strcmp (option, "complex"))
      error ("mplapack:mp:InvalidOption", ...
             "schur option must be \"real\" or \"complex\"");
    endif
  elseif (isreal (value) == 0)
    option = "complex";
  endif

  [u_payload, s_payload] = __mplapack_core__ ("schur", value, option);
  u = mp (0);
  u.payload_ = u_payload;
  s = mp (0);
  s.payload_ = s_payload;
  if (nargout <= 1)
    varargout{1} = s;
  else
    varargout{1} = u;
    varargout{2} = s;
  endif
endfunction
