% A compact advanced dense workflow: Schur, matrix functions, and polynomials.
if (exist ("mpbits", "file") != 2)
  pkg load mplapack-interop
endif

saved_bits = mpbits ();
unwind_protect
  mpbits (256);
  A = mp ({"0", "1"; "-2", "-3"});
  [U, T] = schur (A);
  assert (double (norm (U' * A * U - T, "fro")) < 1e-45);

  E = expm (A);
  L = logm (E);
  assert (double (norm (expm (L) - E, "fro")) < 1e-35);

  p = mp ({"1", "-3", "2"});
  r = roots (p);
  assert (double (norm (polyval (p, r), "fro")) < 1e-35);

  fprintf ("advanced dense PASS: Schur/matrix functions/polynomials\n");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
