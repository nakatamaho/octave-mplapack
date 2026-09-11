% Exact lazy-cyclic teleportation model.
function result = net_markov_model (n, epsilon_exponent, bits)
  if (nargin != 3 || n != fix (n) || n < 4 || mod (n, 2) != 0 ...
      || epsilon_exponent != fix (epsilon_exponent) || epsilon_exponent < 1 ...
      || bits != fix (bits) || bits < 64)
    error ("mplapack:neigt:Markov", "invalid Markov arguments");
  endif
  h = n / 2;
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    C = mp (zeros (h, h));
    for i = 1:(h - 1)
      C(i, i + 1) = mp (1);
    endfor
    C(h, 1) = mp (1);
    I_h = mp (eye (h));
    Q = mp (zeros (n, n));
    Q(1:h, 1:h) = (mp (3) / mp (4)) * I_h + (mp (1) / mp (4)) * C;
    Q((h + 1):n, (h + 1):n) = (mp (7) / mp (8)) * I_h ...
      + (mp (1) / mp (8)) * C;
    r = mp (zeros (n, 1));
    for i = 1:(n - 1)
      r(i) = net_pow2 (-i, bits);
    endfor
    r(n) = net_pow2 (-(n - 1), bits);
    epsilon = net_pow2 (-epsilon_exponent, bits);
    P = (mp (1) - epsilon) * Q ...
      + epsilon * (mp (ones (n, 1)) * transpose (r));
    result = struct ("family", "markov", "n", n, "h", h, ...
      "epsilon_exponent", epsilon_exponent, "epsilon", epsilon, ...
      "Q", Q, "r", r, "P_model", P, "P_frozen", P, ...
      "native_P", double (P), "input_status", "exact_model", ...
      "source", "A6_LAZY_CYCLIC_TELEPORTATION");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
