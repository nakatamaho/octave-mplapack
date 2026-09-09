% One- and two-dimensional arbitrary-precision interpolation.
if (exist ("mpbits", "file") != 2)
  pkg load mplapack-interop
endif

saved_bits = mpbits ();
unwind_protect
  mpbits (512);
  x = mp ({"0", "1", "3", "7"});
  y = mp ({"0", "1", "9", "49"});
  q = mp ({"0.5", "2", "5"});
  linear = interp1 (x, y, q, "linear");
  assert (linear(1) == mp ("0.5"));
  assert (linear(2) == mp (5));
  pp = pchip (x, y);
  assert (ppval (pp, mp ("2")) > mp ("1"));

  grid = mp ({"0", "1", "3"});
  z = mp ({"0", "1", "3"; "2", "3", "5"; "5", "6", "8"});
  value = interp2 (grid, grid, z, mp ("0.5"), mp ("0.5"));
  % The four surrounding samples are 0, 1, 2, and 3, so bilinear
  % interpolation at (0.5, 0.5) is exactly 1.5.
  assert (value == mp ("1.5"));
  fprintf ("interpolation PASS: interp1/pchip/interp2\n");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
