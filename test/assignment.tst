## SPDX-License-Identifier: BSD-2-Clause

%!function info = assignment_info (value)
%!  info = __mplapack_core__ ("value_shape_info", value);
%!endfunction

%!function assert_matrix_text (value, expected)
%!  info = assignment_info (value);
%!  assert (info.rows, uint64 (rows (expected)));
%!  assert (info.columns, uint64 (columns (expected)));
%!  for column = 1:columns (expected)
%!    for row = 1:rows (expected)
%!      assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!        value, row, column, expected{row, column}));
%!    endfor
%!  endfor
%!endfunction

%!function ok = raises_id (callable, identifier)
%!  ok = false;
%!  try
%!    callable ();
%!  catch exception
%!    ok = strcmp (exception.identifier, identifier);
%!  end_try_catch
%!endfunction

%!function ok = raises_any (callable)
%!  ok = false;
%!  try
%!    callable ();
%!  catch
%!    ok = true;
%!  end_try_catch
%!endfunction

%!function assign_bad_index (value)
%!  value (0, 1) = mp ("5");
%!endfunction

%!function assign_bad_shape (value)
%!  value (:, 1) = mp ({"5", "6"; "7", "8"});
%!endfunction

%!function assign_growth (value)
%!  value (3, 1) = mp ("5");
%!endfunction

%!function assign_delete (value)
%!  value (1, 1) = [];
%!endfunction

%!function assign_linear_vector (value)
%!  value ([1, 2]) = mp ([5, 6]);
%!endfunction

%!function assign_complex (value)
%!  value (1, 1) = 1 + 2i;
%!endfunction

%!function assign_sparse (value)
%!  value (1, 1) = sparse (1);
%!endfunction

%!function assign_nd (value)
%!  value (1, 1) = ones (1, 1, 2);
%!endfunction

%!test
%! A = mp ({"11", "12", "13"; "21", "22", "23"; ...
%!          "31", "32", "33"});
%! B = A;
%! B(2, 3) = mp ("99");
%! assert_matrix_text (A, {"11", "12", "13"; "21", "22", "23"; ...
%!                         "31", "32", "33"});
%! assert_matrix_text (B, {"11", "12", "13"; "21", "22", "99"; ...
%!                         "31", "32", "33"});
%! C = A;
%! C(:, 2) = mp ({"7"; "8"; "9"});
%! assert_matrix_text (C, {"11", "7", "13"; "21", "8", "23"; ...
%!                         "31", "9", "33"});
%! D = A;
%! D(2, :) = [6, 7, 8];
%! assert_matrix_text (D, {"11", "12", "13"; "6", "7", "8"; ...
%!                         "31", "32", "33"});
%! E = A;
%! E(1:2, 2:3) = mp ({"41", "42"; "51", "52"});
%! assert_matrix_text (E, {"11", "41", "42"; "21", "51", "52"; ...
%!                         "31", "32", "33"});
%! F = A;
%! F([3, 1], [3, 1]) = mp ({"61", "62"; "71", "72"});
%! assert_matrix_text (F, {"72", "12", "71"; "21", "22", "23"; ...
%!                         "62", "32", "61"});

%!test
%! A = mp ({"11", "12"; "21", "22"});
%! A(1) = mp ("31");
%! A(4) = 0.125;
%! assert_matrix_text (A, {"31", "12"; "21", "0.125"});
%! A(:) = mp ({"1", "2"; "3", "4"});
%! assert_matrix_text (A, {"1", "2"; "3", "4"});
%! A(:) = [5, 6, 7, 8];
%! assert_matrix_text (A, {"5", "7"; "6", "8"});
%! A(:, []) = 99;
%! assert_matrix_text (A, {"5", "7"; "6", "8"});

%!test
%! x = mp ("1");
%! x(1, 1) = mp ("2");
%! assert (! __mplapack_core__ ("value_is_matrix", x));
%! assert (char (x), "2e+0");
%! x(1) = 0.125;
%! assert (char (x), "1.25e-1");
%! x(:) = mp ("3");
%! assert (char (x), "3e+0");

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "2"; "3", "4"});
%!   mpbits (1024);
%!   tail = strcat ("1.", repmat ("0", 1, 210), "1");
%!   high = mp (tail);
%!   mpbits (128);
%!   no_op = A;
%!   no_op(:, []) = high;
%!   assert (assignment_info (no_op).precision_bits, uint64 (256));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                              no_op, 1, 1, "1"));
%!   A(1, 1) = high;
%!   info = assignment_info (A);
%!   assert (info.precision_bits, uint64 (1024));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                              A, 1, 1, tail));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                              A, 2, 2, "4"));
%!   assert (mpbits (), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%!   A(2, 2) = mp ("5");
%!   assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                              A, 1, 1, tail));
%!   assert (assignment_info (A).precision_bits, uint64 (1024));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (2048);
%!   tail = strcat ("1.", repmat ("0", 1, 450), "1");
%!   A = mp ({tail, "2"; "3", "4"});
%!   mpbits (2048);
%!   rhs = mp (tail);
%!   mpbits (128);
%!   A(2, 2) = rhs;
%!   assert (assignment_info (A).precision_bits, uint64 (2048));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                              A, 1, 1, tail));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                              A, 2, 2, tail));
%!   assert (mpbits (), uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "2"; "3", "4"});
%!   mpbits (4096);
%!   A(1, 1) = 0.1;
%!   assert (assignment_info (A).precision_bits, uint64 (256));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!                              A, 1, 1, 0.1));
%!   A(2, 2) = -0.0;
%!   zero = __mplapack_core__ ("scalar_test_info", A(2, 2));
%!   assert (zero.is_zero && zero.signbit);
%!   A(1, 2) = Inf;
%!   A(2, 1) = NaN;
%!   assert (__mplapack_core__ ("scalar_test_info", A(1, 2)).is_infinite);
%!   assert (__mplapack_core__ ("scalar_test_info", A(2, 1)).is_nan);
%!   assert (mpbits (), uint64 (4096));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp ({"11", "12"; "21", "22"});
%! A(end, 1) = mp ("31");
%! A(1, end) = mp ("32");
%! A(:, end) = mp ({"42"; "43"});
%! A(end, :) = [51, 52];
%! assert_matrix_text (A, {"11", "42"; "51", "52"});
%! A(1:2, 1:2) = A([2, 1], [2, 1]);
%! assert_matrix_text (A, {"52", "51"; "42", "11"});
%! R = mp ({"1", "2"; "3", "4"});
%! R([1, 1], 2) = [5; 6];
%! assert_matrix_text (R, {"1", "6"; "3", "4"});
%! R(1, [1, 1]) = [7, 8];
%! assert_matrix_text (R, {"8", "6"; "3", "4"});

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! assert (raises_any (@() assign_bad_index (A)));
%! assert (raises_id (@() assign_bad_shape (A), ...
%!                    "mplapack:mp:DimensionMismatch"));
%! assert (raises_id (@() assign_growth (A), ...
%!                    "mplapack:mp:IndexOutOfBounds"));
%! assert (raises_id (@() assign_delete (A), ...
%!                    "mplapack:mp:DeletionUnsupported"));
%! assert (raises_id (@() assign_linear_vector (A), ...
%!                    "mplapack:mp:LinearAssignmentUnsupported"));

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! B = A;
%! B(:, 1) = A(:, 2);
%! assert_matrix_text (A, {"1", "2"; "3", "4"});
%! assert_matrix_text (B, {"2", "2"; "4", "4"});
%! C = [A, B];
%! C(1, 1) = mp ("9");
%! assert_matrix_text (A, {"1", "2"; "3", "4"});
%! assert_matrix_text (C, {"9", "2", "2", "2"; ...
%!                         "3", "4", "4", "4"});
%! S = C(:, 1);
%! clear C;
%! assert (char (S(1)), "9e+0");
%! T = S + mp ("1");
%! assert (char (T(1)), "1e+1");

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! before = double (A);
%! A(1, 1) = 1 + 2i;
%! assert (__mplapack_core__ ("matrix_test_info", A).is_complex);
%! assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!                            A, 1, 1, 1 + 2i));
%! assert (double (A(:, 2)), before(:, 2));
%! B = mp ({"1", "2"; "3", "4"});
%! bad = {@() assign_sparse (B), ...
%!        @() assign_nd (B)};
%! for k = 1:numel (bad)
%!   try
%!     bad{k} ();
%!     error ("unsupported assignment unexpectedly succeeded");
%!   catch exception
%!     assert (! strcmp (exception.message, ...
%!                       "unsupported assignment unexpectedly succeeded"));
%!   end_try_catch
%! endfor

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! A(1, 1) = mp ("9");
%! B = A.';
%! C = reshape (A, 1, 4);
%! D = [A, A];
%! assert (char (B(1, 1)), "9e+0");
%! assert (char (C(1)), "9e+0");
%! assert (char (D(1, 1)), "9e+0");
%! X = A * mp ({"1"; "0"});
%! assert (char (X(1)), "9e+0");
%! Y = A \ mp ({"13"; "11"});
%! assert (char (Y(1)), "1e+0");

%!error <chained indexed assignment> mp (1){1} = mp (2)
