% MP unit-circle reference for the nonzero Forsythe cases.
function result = net_forsythe_reference (n, a, reference_bits)
  if (nargin != 3 || n != fix (n) || n < 3 || a != fix (a) || a < 1)
    error ("mplapack:neigt:Forsythe", "invalid Forsythe reference arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (reference_bits);
    radius = net_pow2 (-a, reference_bits);
    pi_value = acos (mp ("-1"));
    unit_roots = mp (zeros (n, 1));
    eigenvalues = mp (zeros (n, 1));
    for k = 0:(n - 1)
      if (k == 0)
        real_part = mp (1);
        imaginary_part = mp (0);
      elseif (mod (n, 2) == 0 && k == n / 2)
        real_part = mp (-1);
        imaginary_part = mp (0);
      else
        angle = mp (2) * pi_value * mp (k) / mp (n);
        real_part = cos (angle);
        imaginary_part = sin (angle);
      endif
      unit_roots(k + 1) = net_mp_complex (real_part, imaginary_part);
      eigenvalues(k + 1) = net_mp_complex (...
        mp (1) + radius * real_part, radius * imaginary_part);
    endfor
    result = struct ("reference_status", "analytic_MP_unit_circle", ...
                     "reference_bits", reference_bits, "radius", radius, ...
                     "unit_roots", unit_roots, "eigenvalues", eigenvalues, ...
                     "source", "S4_CIRCLE_REFERENCE");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
