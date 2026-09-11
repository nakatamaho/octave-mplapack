% Stable MP analytic reference for S3 Toeplitz eigenvalues and vectors.
function result = net_toeplitz_reference (n, b, reference_bits)
  if (nargin != 3 || ! isnumeric (n) || ! isscalar (n) || n != fix (n) ...
      || n < 2 || ! isnumeric (b) || ! isscalar (b) || b != fix (b) ...
      || b < 1)
    error ("mplapack:neigt:Toeplitz", "invalid Toeplitz reference arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (reference_bits);
    pi_value = acos (mp ("-1"));
    scale = net_pow2 (1 - b, reference_bits);
    eigenvalues = mp (zeros (n, 1));
    right_vectors = mp (zeros (n, n));
    left_vectors = mp (zeros (n, n));
    condition_numbers = mp (zeros (n, 1));
    overlaps = mp (zeros (n, 1));
    for k = 1:n
      theta = pi_value * mp (k) / mp (n + 1);
      eigenvalues(k) = mp (3) + scale * cos (theta);
      for j = 1:n
        sine = sin (mp (j) * theta);
        right_vectors(j, k) = net_pow2 (b * (j - 1), reference_bits) * sine;
        left_vectors(j, k) = net_pow2 (-b * (j - 1), reference_bits) * sine;
      endfor
      overlaps(k) = ctranspose (left_vectors(:, k)) * right_vectors(:, k);
      condition_numbers(k) = norm (right_vectors(:, k)) ...
                             * norm (left_vectors(:, k)) / abs (overlaps(k));
    endfor
    result = struct (...
      "reference_status", "analytic_MP_sine_cosine", ...
      "reference_bits", reference_bits, "eigenvalues", eigenvalues, ...
      "right_vectors", right_vectors, "left_vectors", left_vectors, ...
      "condition_numbers", condition_numbers, "overlaps", overlaps, ...
      "overlap_target", mp (n + 1) / mp (2), ...
      "source", "S3_CLOSED_FORM_REFERENCE");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
