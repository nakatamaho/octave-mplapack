## SPDX-License-Identifier: BSD-2-Clause

function result = orth (value, varargin)
  ## Return an arbitrary-precision orthonormal basis for the range of A.
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "orth expects an mp matrix and optional tolerance");
  endif
  [m,n] = size (value);
  [u,s,v] = svd (value, "econ");
  if (nargin == 2)
    tol = varargin{1};
  elseif (min (m,n) == 0)
    tol = [];
  else
    tol = [];
  endif
  if (isempty (tol)), rank_value = rank (value); else, rank_value = rank (value, tol); endif
  result = mp_slice (u, 1:m, 1:double (rank_value));
endfunction
