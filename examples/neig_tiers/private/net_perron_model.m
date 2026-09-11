% Exact positive non-unitary diagonal similarity of the Markov model.
function result = net_perron_model (n, epsilon_exponent, bits)
  markov = net_markov_model (n, epsilon_exponent, bits);
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    D = mp (zeros (n, n));
    D_inverse = mp (zeros (n, n));
    for i = 1:n
      D(i, i) = net_pow2 (i - 1, bits);
      D_inverse(i, i) = net_pow2 (-(i - 1), bits);
    endfor
    A = mp (zeros (n, n));
    for i = 1:n
      for j = 1:n
        A(i, j) = mp (3) / mp (2) * D(i, i) * markov.P_model(i, j) ...
                  * D_inverse(j, j);
      endfor
    endfor
    result = struct ("family", "perron_positive", "n", n, ...
      "epsilon_exponent", epsilon_exponent, "markov", markov, ...
      "D", D, "D_inverse", D_inverse, "A_model", A, "A_frozen", A, ...
      "native_A", double (A), "perron_scale", mp (3) / mp (2), ...
      "input_status", "exact_model", "source", "A6_POSITIVE_DIAGONAL_SIMILARITY");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
