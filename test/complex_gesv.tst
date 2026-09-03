## SPDX-License-Identifier: BSD-2-Clause

%!function assert_solve_info (value, expected_rows, expected_columns, ...
%!                             expected_precision)
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
%!   A = mp ([3 + 1i, 1 - 1i; 2 + 0i, 4 + 2i]);
%!   B = mp ([4 + 4i, 10 + 4i; 14 + 10i, -8 + 12i]);
%!   A_before = double (A);
%!   B_before = double (B);
%!   X = A \ B;
%!   assert_solve_info (X, 2, 2, 512);
%!   assert (double (X), [1 + 2i, 2 - 1i; 3 + 0i, -1 + 4i], 1e-12);
%!   assert (! isreal (X));
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
%!   A = mp ([3, 1; 2, 4]);
%!   mpbits (512);
%!   B = mp ([6 + 6i, 5 + 1i; 14 + 4i, 0 + 14i]);
%!   mpbits (1024);
%!   X = A \ B;
%!   assert_solve_info (X, 2, 2, 512);
%!   assert (double (X), [1 + 2i, 2 - 1i; 3 + 0i, -1 + 4i], 1e-12);
%!   assert (mpbits (), uint64 (1024));
%!   builtin_rhs = [6 + 6i; 14 + 4i];
%!   builtin_solution = A \ builtin_rhs;
%!   assert_solve_info (builtin_solution, 2, 1, 256);
%!   assert (double (builtin_solution), [1 + 2i; 3 + 0i], 1e-12);
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
%!     A = mp (complex (eye (2), zeros (2)));
%!     B = mp (complex (zeros (2, 1), zeros (2, 1)));
%!     tail = mp ("1", "-1");
%!     for k = 1:exponent
%!       tail = tail ./ mp ("2");
%!     endfor
%!     B(1, 1) = tail;
%!     B(2, 1) = tail;
%!     mpbits (128);
%!     X = A \ B;
%!     assert_solve_info (X, 2, 1, precision);
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
%!   singular = mp ([1 + 0i, 2 + 0i; 2 + 0i, 4 + 0i]);
%!   rhs = mp ([1 + 0i; 2 + 0i]);
%!   caught = false;
%!   try
%!     singular \ rhs;
%!   catch exception
%!     caught = true;
%!     assert (strcmp (exception.identifier, "mplapack:mp:SingularMatrix"));
%!   end_try_catch
%!   assert (caught);
%!   nonsquare = mp (complex (ones (2, 1), zeros (2, 1)));
%!   caught = false;
%!   try
%!     nonsquare \ rhs;
%!   catch exception
%!     caught = true;
%!     assert (strcmp (exception.identifier, "mplapack:mp:NonSquareMatrix"));
%!   end_try_catch
%!   assert (caught);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
