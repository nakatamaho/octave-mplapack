% Neumann inverse witness for a point matrix, using explicit interval products.
function result = net_iv_inverse_residual (X, inverse_candidate, q)
  net_iv_q (q);
  if (nargin != 3 || ! isa (X, "mp") || ! isa (inverse_candidate, "mp") ...
      || rows (X) != columns (X) || ! isequal (size (X), size (inverse_candidate)))
    error ("mplapack:neigt:Inverse", "invalid square inverse witness");
  endif
  n = rows (X);
  residual = net_iv_cmatrix_sub (net_iv_cmatrix_eye (n, q), ...
    net_iv_cmatrix_mul (net_iv_cmatrix_point (inverse_candidate, q), ...
                        net_iv_cmatrix_point (X, q), q), q);
  e = net_iv_cmatrix_inf_upper (residual, q);
  result = struct ("residual", residual, "e", e, "nonsingular", e < mp (1), ...
                   "method", "neigt_neumann_inverse_v1");
endfunction
