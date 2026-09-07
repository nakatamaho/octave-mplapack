## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   assert (norm (double (mp ("5") / mp ("2")) - 2.5) < 1e-12);
%!   A = mp ([1, 2; 3, 4]);
%!   assert (norm (double (A / mp ("2")) - [1, 2; 3, 4] / 2, "fro") < 1e-12);
%!   Z = mp ([1 + 2i, 2 - 1i; 3, 4 + 3i]);
%!   assert (norm (double (Z / mp ("2")) - double (Z) / 2, "fro") < 1e-12);
%!   B = mp ([1 + 1i; 2 - 1i]);
%!   Bd = double (B);
%!   expected = 2 * ctranspose (Bd) ./ sum (abs (Bd) .^ 2);
%!   assert (norm (double (mp ("2") / B) - expected, "fro") < 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 2; 3, 4]);
%!   B = mp ([2, 1; 1, 3]);
%!   A_before = double (A);
%!   B_before = double (B);
%!   X = A / B;
%!   assert (size (X), [2, 2]);
%!   assert (norm (double (X) - A_before / B_before, "fro") < 1e-12);
%!   assert (norm (double (mrdivide (A, B)) - A_before / B_before, "fro") < 1e-12);
%!   assert (double (A), A_before);
%!   assert (double (B), B_before);
%!   info = __mplapack_core__ ("matrix_test_info", X);
%!   assert (! info.is_complex && info.precision_bits == 256);
%!
%!   Z = mp ([1 + 2i, 2 - 1i; 3, 4 + 3i]);
%!   W = mp ([2 - 1i, 1 + 1i; 1, 3 + 2i]);
%!   Z_before = double (Z);
%!   W_before = double (W);
%!   Y = Z / W;
%!   assert (size (Y), [2, 2]);
%!   assert (norm (double (Y) - Z_before / W_before, "fro") < 1e-12);
%!   assert (double (Z), Z_before);
%!   assert (double (W), W_before);
%!   info = __mplapack_core__ ("matrix_test_info", Y);
%!   assert (info.is_complex && info.precision_bits == 256);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   G = mp (gallery ("grcar", 32));
%!   I = mp (eye (32));
%!   X = I / G;
%!   assert (size (X), [32, 32]);
%!   assert (norm (double (X * G - I), "fro") < 1e-10, ...
%!           "N08 permanent Grcar right-division residual");
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   T = mp ([1, 2; 3, 4]);
%!   B = mp ([1, 2, 3; 0, 1, 1]);
%!   A = T * B;
%!   assert (size (A / B), [2, 2]);
%!   assert (norm (double (A / B) - double (A) / double (B), "fro") < 1e-11);
%!
%!   Tc = mp ([1 + 1i, 2 - 1i; 3 + 2i, 4]);
%!   Bc = mp ([1 + 1i, 2, 3 - 1i; 1i, 1 - 1i, 2]);
%!   Ac = Tc * Bc;
%!   assert (size (Ac / Bc), [2, 2]);
%!   assert (norm (double (Ac / Bc) - double (Ac) / double (Bc), "fro") < 1e-11);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 2; 3, 4]);
%!   B = mp ([1, 2; 2, 4]);
%!   expected = double (A) / double (B);
%!   actual = A / B;
%!   assert (norm (double (actual) - expected, "fro") < 1e-11);
%!
%!   Br = mp ([1, 2, 3; 2, 4, 6]);
%!   Ar = mp ([1, 2, 3]);
%!   assert (size (Ar / Br), [1, 2]);
%!   assert (norm (double (Ar / Br) - double (Ar) / double (Br), "fro") < 1e-11);
%!
%!   Z = mp ([1 + 1i, 2; 3, 4 - 1i]);
%!   W = mp ([1 + 1i, 2; 2 + 2i, 4]);
%!   assert (norm (double (Z / W) - double (Z) / double (W), "fro") < 1e-11);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = [1, 2; 3, 4];
%!   B = mp ([2, 1; 1, 3]);
%!   assert (norm (double (A / B) - A / double (B), "fro") < 1e-12);
%!   Z = mp ([1 + 2i, 2 - 1i; 3, 4 + 3i]);
%!   Bc = [2 - 1i, 1 + 1i; 1, 3 + 2i];
%!   assert (norm (double (Z / Bc) - double (Z) / Bc, "fro") < 1e-12);
%!   assert (norm (double (Bc / Z) - Bc / double (Z), "fro") < 1e-12);
%!   assert (__mplapack_core__ ("matrix_test_info", A / B).precision_bits == 256);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for dimensions = {[0, 0, 0, 0], [0, 2, 3, 2], [2, 0, 3, 0], ...
%!                      [0, 0, 2, 0], [2, 0, 0, 0]}
%!     d = dimensions{1};
%!     A = mp (zeros (d(1), d(2)));
%!     B = mp (zeros (d(3), d(4)));
%!     expected = zeros (d(1), d(3));
%!     actual = A / B;
%!     assert (size (actual), size (expected));
%!   endfor
%!
%!   A = mp (ones (2, 2));
%!   B = mp (ones (3, 1));
%!   caught = false;
%!   try
%!     A / B;
%!   catch exception
%!     caught = true;
%!     assert (strcmp (exception.identifier, "mplapack:mp:DimensionMismatch"));
%!   end_try_catch
%!   assert (caught);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   special_values = {[Inf, 1; 2, 3], [1, 2; 3, Inf], ...
%!                     [NaN, 1; 2, 3]};
%!   for value = special_values
%!     actual = mp (value{1}) / mp (eye (2));
%!     assert (size (actual), [2, 2]);
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for setting = {[1024, 700], [2048, 1500]}
%!     precision = setting{1}(1);
%!     exponent = setting{1}(2);
%!     mpbits (precision);
%!     tail = mp ("1");
%!     for k = 1:exponent
%!       tail = tail ./ mp ("2");
%!     endfor
%!     B = mp (eye (2));
%!     B(1, 1) = tail;
%!     I = mp (eye (2));
%!     mpbits (128);
%!     X = I / B;
%!     info = __mplapack_core__ ("matrix_test_info", X);
%!     assert (info.precision_bits == precision);
%!     assert (__mplapack_core__ ("precision_test_mpfr_global_bits") == 128);
%!     assert (norm (double (X * B - I), "fro") < 1e-12);
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
