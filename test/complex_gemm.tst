## SPDX-License-Identifier: BSD-2-Clause

%!function assert_matrix_info (value, expected_rows, expected_columns, ...
%!                              expected_precision)
%!  info = __mplapack_core__ ("matrix_test_info", value);
%!  assert (info.rows, uint64 (expected_rows));
%!  assert (info.columns, uint64 (expected_columns));
%!  assert (info.precision_bits, uint64 (expected_precision));
%!  assert (info.is_complex && info.all_elements_same_precision);
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ([1 + 2i, 5 + 6i; 3 + 4i, 7 + 8i]);
%!   B = mp ([1 + 0i, 2 - 1i; 0 + 1i, 1 + 2i]);
%!   A_before = double (A);
%!   B_before = double (B);
%!   C = A * B;
%!   assert_matrix_info (C, 2, 2, 512);
%!   assert (double (C), [-5 + 7i, -3 + 19i; -5 + 11i, 1 + 27i]);
%!   assert (! isreal (C));
%!   assert (double (A), A_before);
%!   assert (double (B), B_before);
%!   clear A B;
%!   assert (double (C), [-5 + 7i, -3 + 19i; -5 + 11i, 1 + 27i]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   R = mp ([1, 3; 2, 4]);
%!   mpbits (512);
%!   Z = mp ([1 + 2i, 3 + 4i; 5 + 6i, 7 + 8i]);
%!   scale = mp ("2", "-1");
%!   mpbits (1024);
%!   RZ = R * Z;
%!   ZR = Z * R;
%!   assert_matrix_info (RZ, 2, 2, 512);
%!   assert_matrix_info (ZR, 2, 2, 512);
%!   assert (double (RZ), [16 + 20i, 24 + 28i; ...
%!                         22 + 28i, 34 + 40i]);
%!   assert (double (ZR), [7 + 10i, 15 + 22i; ...
%!                         19 + 22i, 43 + 50i]);
%!   assert (mpbits (), uint64 (1024));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (1024));
%!   I = complex (eye (2), zeros (2));
%!   builtin_result = Z * I;
%!   assert_matrix_info (builtin_result, 2, 2, 512);
%!   assert (double (builtin_result), double (Z));
%!   scaled = Z * scale;
%!   assert_matrix_info (scaled, 2, 2, 512);
%!   assert (double (scaled), [4 + 3i, 10 + 5i; ...
%!                             16 + 7i, 22 + 9i]);
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
%!     tail = mp ("1", "1");
%!     for k = 1:exponent
%!       tail = tail ./ mp ("2");
%!     endfor
%!     A = mp (complex (zeros (1, 2), zeros (1, 2)));
%!     A(1, 1) = tail;
%!     B = mp (complex ([1; 0], zeros (2, 1)));
%!     mpbits (128);
%!     result = A * B;
%!     assert (! isreal (result));
%!     assert (strcmp (char (result), char (tail)));
%!     assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!             uint64 (128));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp (complex (ones (2, 2), zeros (2, 2)));
%!   B = mp (complex (ones (3, 1), zeros (3, 1)));
%!   caught = false;
%!   try
%!     A * B;
%!   catch exception
%!     caught = true;
%!     assert (strcmp (exception.identifier, "mplapack:mp:DimensionMismatch"));
%!   end_try_catch
%!   assert (caught);
%!   E = mp (complex (zeros (1, 0), zeros (1, 0)));
%!   F = mp (complex (zeros (0, 2), zeros (0, 2)));
%!   empty = E * F;
%!   assert_matrix_info (empty, 1, 2, 256);
%!   assert (! isempty (empty));
%!   assert (double (empty), zeros (1, 2));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
