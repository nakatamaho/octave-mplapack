## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 2; 3, 4]);
%!   A_before = double (A);
%!   d = det (A);
%!   assert (double (d), -2, 1e-12);
%!   assert (__mplapack_core__ ("scalar_test_info", d).precision_bits == 256);
%!   X = inv (A);
%!   assert (size (X), [2, 2]);
%!   assert (double (X), [-2, 1; 1.5, -0.5], 1e-12);
%!   assert (double (A), A_before);
%!   assert (__mplapack_core__ ("matrix_test_info", X).precision_bits == 256);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   Z = mp ([1 + 1i, 2; 3, 4 - 1i]);
%!   d = det (Z);
%!   assert (double (d), -1 + 3i, 1e-12);
%!   X = inv (Z);
%!   expected = [-0.7 - 1.1i, 0.2 + 0.6i; ...
%!               0.3 + 0.9i, 0.2 - 0.4i];
%!   assert (double (X), expected, 1e-12);
%!   assert (! isreal (d) && ! isreal (X));
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
%!       tail = tail ./ 2;
%!     endfor
%!     reciprocal = mp ("1");
%!     for k = 1:exponent
%!       reciprocal = reciprocal .* 2;
%!     endfor
%!     A = mp ([1, 0; 0, 1]);
%!     A(1, 1) = tail;
%!     mpbits (128);
%!     d = det (A);
%!     X = inv (A);
%!     assert (strcmp (char (d), char (tail)));
%!     assert (strcmp (char (X(1, 1)), char (reciprocal)));
%!     assert (mpbits () == 128);
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! mpbits (256);
%! singular = mp ([1, 2; 2, 4]);
%! assert (double (det (singular)), 0);
%! caught = false;
%! try
%!   inv (singular);
%! catch exception
%!   caught = true;
%!   assert (strcmp (exception.identifier, "mplapack:mp:SingularMatrix"));
%! end_try_catch
%! assert (caught);
%! complex_singular = mp ([1 + 0i, 2; 2, 4 + 0i]);
%! assert (double (det (complex_singular)), 0);
%! caught = false;
%! try
%!   inv (complex_singular);
%! catch exception
%!   caught = true;
%!   assert (strcmp (exception.identifier, "mplapack:mp:SingularMatrix"));
%! end_try_catch
%! assert (caught);

%!test
%! A = mp ([1, 2; 3, 4]);
%! nonsquare = mp ([1, 2, 3]);
%! fail ("det (nonsquare)", "square");
%! fail ("inv (nonsquare)", "square");
%! fail ("[d, c] = det (A)", "too many outputs");
%! fail ("[x, y] = inv (A)", "too many outputs");

%!test
%! empty = mp (zeros (0, 0));
%! assert (double (det (empty)), 1);
%! inverse = inv (empty);
%! assert (size (inverse), [0, 0]);
