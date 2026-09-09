% SVD of a non-diagonal, ill-conditioned Hilbert matrix.
if (exist ("mpbits", "file") != 2)
  pkg load mplapack-interop
endif

saved_bits = mpbits ();
unwind_protect
  mpbits (512);
  n = 8;
  H = mp (zeros (n, n));
  for i = 1:n
    for j = 1:n
      H(i, j) = mp (1) / mp (i + j - 1);
    endfor
  endfor

  [U, S, V] = svd (H);
  sigma = diag (S);
  residual = norm (H - U * S * V', "fro") / norm (H, "fro");

  disp ("Hilbert singular values:");
  disp (sigma);
  disp ("relative reconstruction residual:");
  disp (residual);
  fprintf ("Hilbert SVD PASS: n=%d, mpbits=%d\n", n, mpbits ());
  assert (double (residual) < 1e-100);
  assert (double (norm (U' * U - mp (eye (n)), "fro")) < 1e-100);
  assert (double (norm (V' * V - mp (eye (n)), "fro")) < 1e-100);
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
