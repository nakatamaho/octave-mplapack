## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   increasing = mp ("0.1"):mp ("0.2"):mp ("0.5");
%!   assert (size (increasing), [1, 3]);
%!   assert (double (increasing), [0.1, 0.3, 0.5], 1e-15);
%!   decreasing = mp ("5"):-mp ("2"):mp ("1");
%!   assert (double (decreasing), [5, 3, 1]);
%!   empty_up = mp ("5"):mp ("1");
%!   empty_down = mp ("1"):-mp ("1"):mp ("5");
%!   assert (isempty (empty_up) && isempty (empty_down));
%!   rejected = false;
%!   try
%!     mp ("1"):mp ("0"):mp ("2");
%!   catch
%!     rejected = true;
%!   end_try_catch
%!   assert (rejected);
%!   precise_step = mp ("0.1"):mp ("0.1"):mp ("0.3");
%!   assert (isequal (precise_step (1), mp ("0.1")));
%!   assert (isequal (precise_step (3), mp ("0.3")));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = linspace (mp ("0.1"), mp ("0.5"), 5);
%!   assert (size (A), [1, 5]);
%!   assert (isequal (A (1), mp ("0.1")));
%!   assert (isequal (A (5), mp ("0.5")));
%!   B = linspace (mp ("1"), mp ("2"), 1);
%!   assert (isequal (B, mp ("2")));
%!   assert (isempty (linspace (mp ("1"), mp ("2"), 0)));
%!   Z = linspace (mp (1 + 2i), mp (3 + 4i), 3);
%!   assert (double (Z), [1 + 2i, 2 + 3i, 3 + 4i], 1e-12);
%!   assert (! __mplapack_core__ ("value_is_real", Z));
%!   L = logspace (mp ("0"), mp ("2"), 3);
%!   assert (double (L), [1, 10, 100], 1e-12);
%!   LP = logspace (mp ("1"), pi, 3);
%!   assert (double (LP (1)), 10, 1e-12);
%!   assert (double (LP (3)), pi, 1e-12);
%!   assert (columns (logspace (mp ("0"), mp ("1"))), 50);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([-1.7, -1.5, 1.5, 1.7]);
%!   assert (double (floor (A)), [-2, -2, 1, 1]);
%!   assert (double (ceil (A)), [-1, -1, 2, 2]);
%!   assert (double (fix (A)), [-1, -1, 1, 1]);
%!   assert (double (round (A)), [-2, -2, 2, 2]);
%!   assert (double (rem (mp ([-5, 5]), mp ([3, -3]))), [-2, 2]);
%!   assert (double (mod (mp ([-5, 5]), mp ([3, -3]))), [1, -1]);
%!   assert (double (hypot (mp ([3, 5]), mp ([4, 12]))), [5, 13]);
%!   assert (double (atan2 (mp ([1, -1]), mp ([0, 0]))), ...
%!           [pi / 2, -pi / 2], 1e-12);
%!   assert (signbit (mp ({"-0", "0"})), [true, false]);
%!   e = eps (mp ("1"));
%!   assert (isequal (e, mp ("2") ^ -255));
%!   info = __mplapack_core__ ("value_shape_info", e);
%!   assert (info.precision_bits == 256);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for precision = [1024, 2048]
%!     mpbits (precision);
%!     exponent = (precision == 1024) * -700 ...
%!                + (precision == 2048) * -1500;
%!     x = mp ("2") ^ exponent;
%!     y = linspace (x, x + eps (x), 2);
%!     assert (isequal (y (1), x));
%!     assert (isequal (y (2), x + eps (x)));
%!     assert (__mplapack_core__ ("value_shape_info", y).precision_bits == precision);
%!     mpbits (128);
%!     assert (__mplapack_core__ ("precision_test_mpfr_global_bits") == 128);
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!error <complex colon ranges are not supported>
%! mp (1 + 1i):mp (2 + 2i);

%!error <real mp values only>
%! floor (mp (1 + 2i));

%!error <complex logspace endpoints are not supported>
%! logspace (mp (1 + 1i), mp (2 + 2i));
