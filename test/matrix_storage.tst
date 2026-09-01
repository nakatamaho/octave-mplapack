## SPDX-License-Identifier: BSD-2-Clause

%!function y = m07_pass_through (x)
%!  y = x;
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (333);
%!   A = mp ({"11", "12", "13"; "21", "22", "23"});
%!   assert (strcmp (class (A), "mp"));
%!   info = __mplapack_core__ ("matrix_test_info", A);
%!   assert (strcmp (info.internal_type, "mplapack_mpfr_matrix_internal"));
%!   assert (strcmp (info.storage_kind, "column_major_contiguous"));
%!   assert (info.rows, uint64 (2));
%!   assert (info.columns, uint64 (3));
%!   assert (info.numel, uint64 (6));
%!   assert (info.precision_bits, uint64 (333));
%!   assert (info.leading_dimension, int64 (2));
%!   assert (info.all_elements_same_precision);
%!   native_order = {"11", "21", "12", "22", "13", "23"};
%!   for index = 1:numel (native_order)
%!     row = mod (index - 1, 2) + 1;
%!     column = floor ((index - 1) / 2) + 1;
%!     assert (__mplapack_core__ (
%!       "matrix_test_element_equal_text", A, row, column,
%!       native_order{index}));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for bits = [32, 128, 256, 333, 512, 1024]
%!     mpbits (bits);
%!     A = mp ([1, 2; 3, 4]);
%!     info = __mplapack_core__ ("matrix_test_info", A);
%!     assert (info.precision_bits, uint64 (bits));
%!     assert (info.all_elements_same_precision);
%!   endfor
%!   mpbits (256);
%!   A = mp ([1, 2; 3, 4]);
%!   mpbits (1024);
%!   B = mp ([1, 2; 3, 4]);
%!   assert (__mplapack_core__ (
%!     "matrix_test_info", A).precision_bits, uint64 (256));
%!   assert (__mplapack_core__ (
%!     "matrix_test_info", B).precision_bits, uint64 (1024));
%!   mpdigits (100);
%!   C = mp ({"0.1", "0.2"; "0.3", "0.4"});
%!   info = __mplapack_core__ ("matrix_test_info", C);
%!   assert (info.precision_bits, uint64 (333));
%!   assert (info.all_elements_same_precision);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   text = mp ({"0.1", "0.125"});
%!   binary64 = mp ([0.1, 0.125]);
%!   assert (__mplapack_core__ (
%!     "matrix_test_element_equal_double", binary64, 1, 1, 0.1));
%!   assert (__mplapack_core__ (
%!     "matrix_test_element_equal_double", binary64, 1, 2, 0.125));
%!   assert (! __mplapack_core__ (
%!     "matrix_test_element_equal", text, 1, 1, binary64, 1, 1));
%!   assert (__mplapack_core__ (
%!     "matrix_test_element_equal", text, 1, 2, binary64, 1, 2));
%!   assert (__mplapack_core__ (
%!     "matrix_test_element_equal_text", text, 1, 1, "0.1"));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! numeric_scalar = mp (reshape (1, 1, 1));
%! text_cell_scalar = mp ({"1"});
%! numeric_info = __mplapack_core__ ("scalar_test_info", numeric_scalar);
%! cell_info = __mplapack_core__ ("scalar_test_info", text_cell_scalar);
%! assert (strcmp (numeric_info.internal_type,
%!                 "mplapack_mpfr_scalar_internal"));
%! assert (strcmp (cell_info.internal_type,
%!                 "mplapack_mpfr_scalar_internal"));
%! assert (size (numeric_scalar), [1, 1]);
%! assert (size (text_cell_scalar), [1, 1]);

%!test
%! empty_00 = mp ([]);
%! empty_03 = mp (zeros (0, 3));
%! empty_40 = mp (zeros (4, 0));
%! empty_cell = mp (cell (0, 3));
%! assert (size (empty_00), [0, 0]);
%! assert (size (empty_03), [0, 3]);
%! assert (size (empty_40), [4, 0]);
%! assert (size (empty_cell), [0, 3]);
%! assert (isempty (empty_00));
%! assert (isempty (empty_03));
%! assert (isempty (empty_40));
%! assert (isempty (empty_cell));
%! assert (size (empty_03, 1), 0);
%! assert (size (empty_03, 2), 3);
%! assert (rows (empty_03), 0);
%! assert (columns (empty_03), 3);
%! assert (numel (empty_03), 0);
%! assert (ndims (empty_03), 2);
%! assert (size (empty_40, 1), 4);
%! assert (size (empty_40, 2), 0);
%! assert (rows (empty_40), 4);
%! assert (columns (empty_40), 0);
%! assert (numel (empty_40), 0);
%! assert (ndims (empty_40), 2);
%! assert (__mplapack_core__ (
%!   "matrix_test_info", empty_03).leading_dimension, int64 (1));
%! assert (__mplapack_core__ (
%!   "matrix_test_info", empty_40).leading_dimension, int64 (4));

%!test
%! A = mp ({"11", "12", "13"; "21", "22", "23"});
%! assert (size (A), [2, 3]);
%! assert (size (A, 1), 2);
%! assert (size (A, 2), 3);
%! assert (size (A, 3), 1);
%! [r, c] = size (A);
%! assert (r, 2);
%! assert (c, 3);
%! assert (rows (A), 2);
%! assert (columns (A), 3);
%! assert (numel (A), 6);
%! assert (ndims (A), 2);
%! assert (! isempty (A));
%! assert (strcmp (strtrim (evalc ("disp (A)")), "mp 2x3 matrix"));
%! assert (isempty (strfind (evalc ("disp (A)"), "payload_")));
%! assert (isempty (strfind (evalc ("disp (A)"),
%!                                 "mplapack_mpfr_matrix_internal")));

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   original = mp ({"1", "2"; "3", "4"});
%!   assigned = original;
%!   copied = mp (original);
%!   collection = {original};
%!   record.value = original;
%!   passed = m07_pass_through (original);
%!   internal_clone = __mplapack_core__ ("matrix_test_clone", original);
%!   clear original;
%!   for value = {assigned, copied, collection{1}, record.value, passed}
%!     info = __mplapack_core__ ("matrix_test_info", value{1});
%!     assert (info.rows, uint64 (2));
%!     assert (info.columns, uint64 (2));
%!     assert (info.precision_bits, uint64 (256));
%!     assert (__mplapack_core__ (
%!       "matrix_test_element_equal_text", value{1}, 2, 2, "4"));
%!   endfor
%!   clone_info = __mplapack_core__ ("matrix_test_info", internal_clone);
%!   assert (clone_info.precision_bits, uint64 (256));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! index_operations = {@() A(1, 1), @() A(1), @() A(:, 1)};
%! for index = 1:numel (index_operations)
%!   try
%!     index_operations{index} ();
%!     error ("M07 indexing unexpectedly succeeded");
%!   catch exception
%!     assert (strcmp (exception.identifier,
%!                     "mplapack:mp:IndexingUnsupported"));
%!   end_try_catch
%! endfor
%! try
%!   A(1, 1) = mp ("5");
%!   error ("M07 indexed assignment unexpectedly succeeded");
%! catch exception
%!   assert (strcmp (exception.identifier,
%!                   "mplapack:mp:IndexingUnsupported"));
%! end_try_catch

%!test
%! scalar_a = mp ("1");
%! scalar_b = mp ("2");
%! try
%!   [scalar_a, scalar_b];
%!   error ("M07 horizontal object array unexpectedly succeeded");
%! catch exception
%!   assert (! isempty (strfind (exception.message, "horzcat method failed")));
%! end_try_catch
%! try
%!   [scalar_a; scalar_b];
%!   error ("M07 vertical object array unexpectedly succeeded");
%! catch exception
%!   assert (! isempty (strfind (exception.message, "vertcat method failed")));
%! end_try_catch

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! B = mp ({"5", "6"; "7", "8"});
%! operations = {@() A + B, @() A - B, @() A .* B, @() A ./ B, ...
%!               @() +A, @() -A};
%! for index = 1:numel (operations)
%!   try
%!     operations{index} ();
%!     error ("M07 matrix arithmetic unexpectedly succeeded");
%!   catch exception
%!     assert (strcmp (exception.identifier,
%!                     "mplapack:mp:MatrixUnsupported"));
%!   end_try_catch
%! endfor
%! not_implemented = {@() A \ B};
%! for index = 1:numel (not_implemented)
%!   try
%!     not_implemented{index} ();
%!     error ("M07 future kernel unexpectedly succeeded");
%!   catch exception
%!     assert (strcmp (exception.identifier, "mplapack:NotImplemented"));
%!   end_try_catch
%! endfor

%!error <char conversion for dense mp matrices> char (mp ([1, 2]))
%!error <double conversion for dense mp matrices> double (mp ([1, 2]))
%!error <complex mp matrices are not supported> mp ([1 + 2i, 3])
%!error <only two-dimensional mp matrices> mp (ones (2, 2, 2))
%!error <only two-dimensional mp matrices> mp (reshape (cellstr (["1"; "2"; "3"; "4"; "5"; "6"; "7"; "8"]), 2, 2, 2))
%!error <each matrix cell must contain one nonempty text row> mp ({"1", 2})
%!test
%! value = mp ("1");
%! try
%!   mp ({value, "2"});
%!   error ("M07 cell-of-mp assembly unexpectedly succeeded");
%! catch exception
%!   assert (! isempty (strfind (
%!     exception.message, "each matrix cell must contain one nonempty text row")));
%! end_try_catch

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (333);
%!   try
%!     mp ({"1", "bad"; "3", "4"});
%!     error ("M07 malformed text matrix unexpectedly succeeded");
%!   catch exception
%!     assert (! isempty (strfind (
%!       exception.message, "invalid text in mp matrix constructor")));
%!   end_try_catch
%!   assert (mpbits (), uint64 (333));
%!   valid = mp ({"1", "2"; "3", "4"});
%!   assert (__mplapack_core__ (
%!     "matrix_test_info", valid).precision_bits, uint64 (333));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
