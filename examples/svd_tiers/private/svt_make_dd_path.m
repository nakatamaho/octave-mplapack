## SPDX-License-Identifier: BSD-2-Clause

function result = svt_make_dd_path (case_id, parameters, work_bits)
  ## Construct the symmetric or nonsymmetric diagonally-dominant path pair.
  if (nargin != 3 || ! ischar (case_id) || ! isstruct (parameters))
    error ("mplapack:svt:InvalidDdRequest", "invalid DD path request");
  endif
  required_fields = {"n", "b", "rho_num", "rho_den"};
  for index = 1:numel (required_fields)
    if (! isfield (parameters, required_fields{index}))
      error ("mplapack:svt:InvalidDdParameters", ...
             "DD parameters lack field %s", required_fields{index});
    endif
  endfor
  n = parameters.n;
  b = parameters.b;
  rho_num = parameters.rho_num;
  rho_den = parameters.rho_den;
  if (! isnumeric (n) || ! isscalar (n) || n != fix (n) || n < 2 ...
      || ! isnumeric (b) || ! isscalar (b) || b != fix (b) || b < 1 ...
      || ! isnumeric (rho_num) || ! isscalar (rho_num) || rho_num <= 0 ...
      || ! isnumeric (rho_den) || ! isscalar (rho_den) || rho_den <= 0 ...
      || work_bits != fix (work_bits))
    error ("mplapack:svt:InvalidDdParameters", "invalid DD integer parameters");
  endif
  required_bits = b + 2;
  below_guard = work_bits < required_bits;
  allow_below_guard = isfield (parameters, "allow_below_guard") ...
                      && parameters.allow_below_guard;
  if (below_guard && ! allow_below_guard)
    error ("mplapack:svt:InsufficientConstructionPrecision", ...
           "DD path is below its exact tau guard");
  endif

  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (work_bits);
  tau = svt_pow2 (-b);
  rho = mp (rho_num) / mp (rho_den);
  represented = svt_dd_matrix (n, tau, rho);
  represented_tau = represented(1, 1) - mp (1);
  represented_tau_lost = (represented_tau == mp (0));

  model_bits = max ([work_bits, required_bits]);
  mpbits (model_bits);
  exact_tau = svt_pow2 (-b);
  exact_rho = mp (rho_num) / mp (rho_den);
  model = svt_dd_matrix (n, exact_tau, exact_rho);
  symmetric = rho_num == rho_den;
  analytic_values = [];
  if (symmetric)
    pi_value = acos (mp (-1));
    analytic_values = mp (zeros (n, 1));
    for index = 1:n
      k = index - 1;
      if (k == 0)
        analytic_values(index) = exact_tau;
      else
        angle = mp (k) * pi_value / (mp (2) * mp (n));
        sine = sin (angle);
        analytic_values(index) = exact_tau + mp (4) * sine * sine;
      endif
    endfor
  endif
  tau0_leading = mp (ones (n - 1, 1));
  tau0_full = mp (0);
  if (symmetric)
    kind = "symmetric";
  else
    kind = "nonsymmetric";
  endif
  exactness = "exact_dyadic";
  if (below_guard)
    exactness = "rounded_tau_loss_at_declared_guard";
  endif
  notes = ["DD path ", kind, "; nonsymmetric path does not identify tau as sigma_min"];
  identity = svt_case_identity (case_id, "dd_path", model, represented, ...
                                work_bits, exactness, notes);
  result = struct ("id", case_id, "tier", "S", "family", "dd_path", ...
                   "parameters", parameters, "n", n, "b", b, ...
                   "rho", rho, "tau", exact_tau, "represented_tau", represented_tau, ...
                   "model", model, "A", represented, "analytic_values", analytic_values, ...
                   "rank", n, "full_rank", true, "det_model", [], ...
                   "symmetric", symmetric, "construction_guard_bits", required_bits, ...
                   "below_guard", below_guard, "allow_below_guard", allow_below_guard, ...
                   "represented_tau_lost", represented_tau_lost, ...
                   "tau0_leading_principal_determinants", tau0_leading, ...
                   "tau0_full_determinant", tau0_full, "identity", identity, ...
                   "status", "CONSTRUCTED");
  if (below_guard && represented_tau_lost)
    result.represented_rank_proof = "tau=0 tridiagonal recurrence: leading minors 1, full determinant 0";
  else
    result.represented_rank_proof = "not applicable: represented tau retained";
  endif
  clear cleanup;
endfunction

function matrix = svt_dd_matrix (n, tau, rho)
  one = mp (1);
  matrix = mp (zeros (n, n));
  matrix(1, 1) = one + tau;
  matrix(1, 2) = -one;
  for index = 2:(n - 1)
    matrix(index, index - 1) = -rho;
    matrix(index, index) = one + rho + tau;
    matrix(index, index + 1) = -one;
  endfor
  matrix(n, n - 1) = -rho;
  matrix(n, n) = rho + tau;
endfunction
