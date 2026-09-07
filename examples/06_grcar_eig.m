% High-precision eigenvalue residual for the standard Grcar matrix.
%
% gallery("grcar", 32) is intentionally used as the documented Octave matrix
% fixture.  The resulting binary64 entries are transferred once into native
% MPFR storage; all eig and residual arithmetic after that is multiprecision.
pkg load mplapack-interop

previous_bits = mpbits ();
unwind_protect
  mpbits (1024);
  G = mp (gallery ("grcar", 32));
  [V, D] = eig (G, "nobalance");
  residual = norm (G * V - V * D, "fro");
  fprintf ("Grcar(32) eig residual at %d bits: %s\n",
           mpbits (), char (residual));
  disp ("The residual is computed by native MPFR/MPC operations.");
unwind_protect_cleanup
  mpbits (previous_bits);
end_unwind_protect
