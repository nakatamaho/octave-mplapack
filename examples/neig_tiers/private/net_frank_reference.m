% Independent Hermite--Jacobi reference for Frank eigenvalues.
function result = net_frank_reference (n, bits)
  if (nargin != 2 || n != fix (n) || n < 2)
    error ("mplapack:neigt:Frank", "invalid Frank reference arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    K = mp (zeros (n, n));
    for j = 1:(n - 1)
      value = sqrt (mp (j));
      K(j, j + 1) = value;
      K(j + 1, j) = value;
    endfor
    [unused, diagonal] = eig (K, "nobalance");
    z = sort (diag (diagonal));
    eigenvalues = mp (zeros (n, 1));
    for j = 1:n
      radical = sqrt (z(j) * z(j) + mp (4));
      if (z(j) >= mp (0))
        root = ((z(j) + radical) / mp (2))^2;
      else
        root = (mp (2) / (radical - z(j)))^2;
      endif
      eigenvalues(j) = root;
    endfor
    central_index = (n + 1) / 2;
    central_exact = false;
    if (mod (n, 2) == 1)
      eigenvalues(central_index) = mp (1);
      central_exact = true;
    endif
    reciprocal_products = mp (zeros (floor (n / 2), 1));
    for j = 1:floor (n / 2)
      reciprocal_products(j) = eigenvalues(j) * eigenvalues(n - j + 1);
    endfor
    result = struct ("reference_status", "hermite_jacobi_independent", ...
      "reference_bits", bits, "K", K, "z", z, ...
      "eigenvalues", eigenvalues, "central_exact", central_exact, ...
      "reciprocal_products", reciprocal_products, ...
      "source", "A2_HERMITE_JACOBI_REFERENCE");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
