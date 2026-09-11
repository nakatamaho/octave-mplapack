% Exact Morimoto--Katori--Shirai model 1 and reduced polynomial.
function result = net_mks_model (n, m, delta, bits)
  if (nargin != 4 || n != fix (n) || m != fix (m) || n < 1 || m < 1 || m > n ...
      || ! isa (delta, "mp") || ! isscalar (delta) || delta <= mp (0) ...
      || bits != fix (bits) || bits < 64)
    error ("mplapack:neigt:MKS", "invalid MKS arguments");
  endif
  ell = floor ((n - 1) / m) + 1;
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    Npower = mp (zeros (n, n));
    for i = 1:(n - m)
      Npower(i, i + m) = mp (1);
    endfor
    A = Npower + delta * (mp (ones (n, 1)) * mp (ones (1, n)));
    q = mp (zeros (1, ell + 1));
    q(1) = mp (1);
    for j = 0:(ell - 1)
      q(j + 2) = -delta * mp (n - m * j);
    endfor
    q_companion = mp (zeros (ell, ell));
    q_companion(1, :) = -q(2:end);
    for i = 2:ell
      q_companion(i, i - 1) = mp (1);
    endfor
    result = struct ("family", "mks", "n", n, "m", m, "ell", ell, ...
      "delta", delta, "A_model", A, "A_frozen", A, "native_A", double (A), ...
      "q_coefficients", q, "q_companion", q_companion, ...
      "zero_algebraic_multiplicity", n - ell, ...
      "zero_geometric_multiplicity", min (m - 1, n - ell), ...
      "input_status", "exact_model", "source", "A5_MKS_EXACT_RANK_ONE_SHIFT");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
