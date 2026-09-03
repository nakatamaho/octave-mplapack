## SPDX-License-Identifier: BSD-2-Clause

%!function assert_rank_info (value, expected_rows, expected_columns, ...
%!                            expected_precision)
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
%!   A = mp ([1 + 0i, 0 + 0i; 0 + 0i, 1 + 0i; 1 + 0i, 1 + 0i]);
%!   B = mp ([1 + 2i, 2 - 1i; 3 + 0i, -1 + 4i; ...
%!            4 + 2i, 1 + 3i]);
%!   A_before = double (A);
%!   B_before = double (B);
%!   X = A \ B;
%!   assert_rank_info (X, 2, 2, 512);
%!   assert (double (X), [1 + 2i, 2 - 1i; 3 + 0i, -1 + 4i], 1e-12);
%!   assert (double (A), A_before);
%!   assert (double (B), B_before);
%!   clear A B;
%!   assert (double (X), [1 + 2i, 2 - 1i; 3 + 0i, -1 + 4i], 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1 + 0i, 0 + 0i, 1 + 0i; ...
%!            0 + 0i, 1 + 0i, 1 + 0i]);
%!   B = mp ([3 + 3i; 3 + 3i]);
%!   X = A \ B;
%!   assert_rank_info (X, 3, 1, 256);
%!   assert (double (X), [1 + 1i; 1 + 1i; 2 + 2i], 1e-12);
%!   rank_deficient = mp ([1 + 0i, 0 + 0i; ...
%!                         2 + 0i, 0 + 0i; 3 + 0i, 0 + 0i]);
%!   rank_rhs = mp ([1 + 2i; 2 + 4i; 3 + 6i]);
%!   rank_solution = rank_deficient \ rank_rhs;
%!   assert_rank_info (rank_solution, 2, 1, 256);
%!   assert (double (rank_solution), [1 + 2i; 0 + 0i], 1e-12);
%!   zero_solution = mp (complex (zeros (3, 2), zeros (3, 2))) \ ...
%!                   mp (complex (zeros (3, 1), zeros (3, 1)));
%!   assert_rank_info (zero_solution, 2, 1, 256);
%!   assert (double (zero_solution), [0; 0]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 0; 0, 1; 1, 1]);
%!   mpbits (512);
%!   B = mp ([1 + 2i; 3 + 0i; 4 + 2i]);
%!   mpbits (1024);
%!   X = A \ B;
%!   assert_rank_info (X, 2, 1, 512);
%!   assert (double (X), [1 + 2i; 3 + 0i], 1e-12);
%!   builtin_B = [1 + 2i; 3 + 0i; 4 + 2i];
%!   builtin_X = A \ builtin_B;
%!   assert_rank_info (builtin_X, 2, 1, 256);
%!   assert (double (builtin_X), [1 + 2i; 3 + 0i], 1e-12);
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (1024));
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
%!     A = mp ([1 + 0i, 0 + 0i; 0 + 0i, 1 + 0i; ...
%!              0 + 0i, 0 + 0i]);
%!     B = mp (complex (zeros (3, 1), zeros (3, 1)));
%!     tail = mp ("1", "-1");
%!     for k = 1:exponent
%!       tail = tail ./ mp ("2");
%!     endfor
%!     B(1, 1) = tail;
%!     B(2, 1) = tail;
%!     mpbits (128);
%!     X = A \ B;
%!     assert_rank_info (X, 2, 1, precision);
%!     assert (strcmp (char (X(1, 1)), char (tail)));
%!     assert (strcmp (char (X(2, 1)), char (tail)));
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
%!   A = mp (complex (ones (3, 2), zeros (3, 2)));
%!   B = mp (complex (ones (2, 1), zeros (2, 1)));
%!   caught = false;
%!   try
%!     A \ B;
%!   catch exception
%!     caught = true;
%!     assert (strcmp (exception.identifier, "mplapack:mp:DimensionMismatch"));
%!   end_try_catch
%!   assert (caught);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
