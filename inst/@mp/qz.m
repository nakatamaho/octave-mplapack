## SPDX-License-Identifier: BSD-2-Clause

function varargout = qz (a, b, varargin)
  ## @deftypefn {} {@var{AA} =} qz (@var{A}, @var{B})
  ## @deftypefnx {} {[@var{AA}, @var{BB}, @var{Q}, @var{Z}] =} qz (@var{A}, @var{B}, @var{type})
  ## Compute the arbitrary-precision generalized Schur decomposition.
  ## The returned orientation is Octave's Q*A*Z=AA and Q*B*Z=BB.
  ## A real request uses the real GGES path; the default is complex QZ.
  ## @end deftypefn
  if (nargin < 2 || nargin > 3 || ! isa (a, "mp") || ! isa (b, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "qz expects two mp matrix operands and an optional type");
  endif
  if (nargout > 6)
    error ("mplapack:mp:OutputCount", "mp qz returns at most six outputs");
  endif

  option = "complex";
  if (nargin == 3)
    if (! ischar (varargin{1}) && ! isstring (varargin{1}))
      error ("mplapack:mp:InvalidOption", ...
             "qz option must be \"real\" or \"complex\"");
    endif
    option = char (varargin{1});
    if (! strcmp (option, "real") && ! strcmp (option, "complex"))
      error ("mplapack:mp:InvalidOption", ...
             "qz option must be \"real\" or \"complex\"");
    endif
  endif

  [aa_payload, bb_payload, q_payload, z_payload] = ...
    __mplapack_core__ ("qz", a, b, option);
  aa = mp (0); aa.payload_ = aa_payload;
  bb = mp (0); bb.payload_ = bb_payload;
  q = mp (0); q.payload_ = q_payload;
  z = mp (0); z.payload_ = z_payload;
  if (nargout <= 1)
    varargout{1} = aa;
    return;
  endif
  varargout{1} = aa;
  varargout{2} = bb;
  if (nargout <= 2)
    return;
  endif
  varargout{3} = q;
  if (nargout <= 3)
    return;
  endif
  varargout{4} = z;
  if (nargout > 4)
    ## The existing arbitrary-precision generalized eigensolver supplies
    ## the optional right/left eigenvectors without converting the pencil.
    [v, lambda, w] = eig (a, b, "qz", "vector");
    varargout{5} = v;
    if (nargout == 6)
      varargout{6} = w;
    endif
  endif
endfunction
