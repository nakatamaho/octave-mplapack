% Verify the interval compatibility equation for an assembled E/Lambda box.
function result = net_v_a1_validate_assembly (A, E_box, Lambda_box, q)
  if (nargin != 4 || ! isa (A, "mp") || ! isstruct (E_box) ...
      || ! isstruct (Lambda_box) || q != fix (q) || q < 64)
    error ("mplapack:neigt:VA1", "invalid assembled-factor arguments");
  endif
  A_box = net_iv_cmatrix_point (A, q);
  residual = net_iv_cmatrix_sub ...
    (net_iv_cmatrix_mul (A_box, E_box, q), ...
     net_iv_cmatrix_mul (E_box, Lambda_box, q), q);
  result = struct ("residual", residual, "encloses_zero", contains_zero (residual), ...
                   "method", "neigt_interval_compatibility_residual_v1");
endfunction

function result = contains_zero (matrix)
  result = all (matrix.rl(:) <= mp (0) & matrix.rh(:) >= mp (0) ...
                & matrix.il(:) <= mp (0) & matrix.ih(:) >= mp (0));
endfunction
