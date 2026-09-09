## SPDX-License-Identifier: BSD-2-Clause

function result = pinv (value, varargin)
  ## @deftypefn {} {@var{X} =} pinv (@var{A})
  ## @deftypefnx {} {@var{X} =} pinv (@var{A}, @var{tol})
  ## Compute the Moore-Penrose inverse with the arbitrary-precision SVD.
  ## The default cutoff is derived from the source precision and matrix scale.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "pinv expects an mp matrix and optional tolerance");
  endif
  [m,n] = size (value);
  [u,s,v] = svd (value, "econ");
  k = min (m,n);
  if (k == 0)
    result = zeros (n,m, "like", value);
    return;
  endif
  if (nargin == 2)
    tol = varargin{1};
    if (isa (tol, "mp"))
      threshold = tol;
    elseif (isnumeric (tol) && isreal (tol) && isscalar (tol) && tol >= 0)
      threshold = mp (tol);
    else
      error ("mplapack:mp:InvalidTolerance", "pinv tolerance must be nonnegative");
    endif
  else
    threshold = [];
  endif
  if (isempty (threshold))
    keep = rank (value);
  else
    keep = rank (value, threshold);
  endif
  if (keep == 0)
    result = zeros (n,m, "like", value);
    return;
  endif
  keep = double (keep);
  if (keep == 1)
    result = mp_slice (v, 1:n, 1) * inv (mp_element (s, 1, 1)) ...
             * mp_slice (u, 1:m, 1)';
  else
    result = mp_slice (v, 1:n, 1:keep) * inv (mp_slice (s, 1:keep, 1:keep)) ...
             * mp_slice (u, 1:m, 1:keep)';
  endif
endfunction
