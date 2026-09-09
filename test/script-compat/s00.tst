## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   x = mp ([-2, 0; 3, -4]);
%!   assert (double (abs (x)), [2, 0; 3, 4]);
%!   assert (double (sign (x)), [-1, 0; 1, -1]);
%!   assert (double (angle (x)), [pi, 0; 0, pi], 1e-12);
%!   assert (double (arg (x)), double (angle (x)), 1e-12);
%!   assert (isreal (x));
%!   assert (isfinite (x));
%!   assert (! isnan (x));
%!   assert (! isinf (x));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   z = mp ([1 + 1i, -1 + 1i; -1 - 1i, 0 - 0i]);
%!   assert (double (abs (z)), sqrt (2) * [1, 1; 1, 0], 1e-12);
%!   assert (double (angle (z)), [pi/4, 3*pi/4; -3*pi/4, 0], 1e-12);
%!   expected_sign = double (z) ./ abs (double (z));
%!   expected_sign (2, 2) = 0;
%!   assert (double (sign (z)), expected_sign, 1e-12);
%!   assert (! isreal (z));
%!   assert (isfinite (z));
%!   assert (! isnan (z));
%!   assert (! isinf (z));
%!   zzero = mp ("-0", "-0");
%!   assert (strcmp (char (sign (zzero)), "(0,0)"));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   x = mp ([Inf, -Inf; NaN, 1]);
%!   z = mp (zeros (2));
%!   z(1, 1) = mp ("Inf", "1");
%!   z(1, 2) = mp ("NaN", "0");
%!   z(2, 1) = mp ("1", "-Inf");
%!   z(2, 2) = mp ("2", "3");
%!   assert (isinf (x), logical ([1, 1; 0, 0]));
%!   assert (isnan (x), logical ([0, 0; 1, 0]));
%!   assert (isfinite (x), logical ([0, 0; 0, 1]));
%!   assert (isinf (z), logical ([1, 0; 1, 0]));
%!   assert (isnan (z), logical ([0, 1; 0, 0]));
%!   assert (isfinite (z), logical ([0, 0; 0, 1]));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   a = mp ("1");
%!   b = mp ("1");
%!   n1 = mp ("NaN");
%!   n2 = mp ("NaN");
%!   assert (isequal (a, b));
%!   assert (! isequal (a, n1));
%!   assert (! isequal (n1, n2));
%!   assert (isequaln (n1, n2));
%!   assert (! isequal (a, 1));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for precision = [1024, 2048]
%!     mpbits (precision);
%!     x = mp ("1.23456789012345678901234567890123456789");
%!     y = abs (x);
%!     z = angle (x);
%!     info_y = __mplapack_core__ ("scalar_test_info", y);
%!     info_z = __mplapack_core__ ("scalar_test_info", z);
%!     assert (info_y.precision_bits == precision);
%!     assert (info_z.precision_bits == precision);
%!     mpbits (128);
%!     assert (__mplapack_core__ ("precision_test_mpfr_global_bits") == 128);
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
