% High-precision Hilbert matrix inverse using the public mp API.
%
% The inverse is intentionally computed as H \ I.  The public package does
% not provide inv(mp), and solving for all identity columns uses the same
% MPLAPACK-backed left-division path without converting through binary64.
pkg load mplapack-interop

previous_bits = mpbits ();
unwind_protect
  mpbits (1024);
  n = 6;

  % Build 1/(i+j-1) from decimal MP values.  This avoids hilb(n), whose
  % builtin implementation first creates a binary64 matrix.
  H = mp (zeros (n, n));
  for j = 1:n
    for i = 1:n
      H(i, j) = mp ("1") ./ mp (sprintf ("%d", i + j - 1));
    endfor
  endfor

  I = mp (eye (n));
  Hinv = H \ I;
  residual = H * Hinv - I;

  disp ("H^(-1) computed at 1024 bits:");
  disp (Hinv);
  disp ("H * H^(-1) - I:");
  disp (residual);

  % norm/abs are not part of the public mp API.  Explicit conversion is used
  % only for a compact binary64 residual diagnostic.
  residual_double = double (residual);
  fprintf ("binary64 residual infinity norm: %.3e\n",
           norm (residual_double, inf));
unwind_protect_cleanup
  mpbits (previous_bits);
end_unwind_protect
