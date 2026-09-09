## SPDX-License-Identifier: BSD-2-Clause

## -*- texinfo -*-
## @deftypefn {} {@var{Z} =} null (@var{A}, @var{tol})
## Return an arbitrary-precision right-null-space basis selected from native
## singular values. The tolerance is precision-sensitive.
## @seealso{svd, rank, orth}
## @end deftypefn

function result = null (value, varargin)
  ## Compute a right null-space basis from the arbitrary-precision SVD.
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "null expects an mp matrix and optional tolerance");
  endif
  [m,n] = size (value);
  [u,s,v] = svd (value);
  if (nargin == 2)
    tol = varargin{1};
  elseif (min (m,n) == 0)
    tol = [];
  else
    tol = [];
  endif
  if (isempty (tol)), rank_value = rank (value); else, rank_value = rank (value, tol); endif
  rank_value = double (rank_value);
  if (rank_value < n)
    result = mp_slice (v, 1:n, rank_value+1:n);
  else
    result = zeros (n,0, "like", value);
  endif
endfunction
