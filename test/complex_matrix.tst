%!test
%! mpbits (256);
%! A = mp ([1 + 2i, 3 + 4i; 5 + 6i, 7 + 8i]);
%! info = __mplapack_core__ ("matrix_test_info", A);
%! assert (info.rows == 2 && info.columns == 2);
%! assert (info.precision_bits == 256 && info.is_complex);
%! assert (info.all_elements_same_precision);
%! assert (double (A), [1 + 2i, 3 + 4i; 5 + 6i, 7 + 8i]);
%! assert (double (A([2, 1], [2, 1])), [7 + 8i, 5 + 6i; 3 + 4i, 1 + 2i]);
%! assert (strcmp (char (A(2, 1)), "(5e+0,6e+0)"));
%! assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                            A, 2, 1, "(5,6)"));
%! assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!                            A, 1, 2, 3 + 4i));

%!test
%! mpbits (512);
%! A = mp ([1 + 2i, 3 + 4i; 5 + 6i, 7 + 8i]);
%! assert (double (A(:, 2)), [3 + 4i; 7 + 8i]);
%! assert (double (A(1, :)), [1 + 2i, 3 + 4i]);
%! assert (double (A(:)), [1 + 2i; 5 + 6i; 3 + 4i; 7 + 8i]);
%! B = A;
%! B(1, 1) = mp (9 + 10i);
%! assert (double (A(1, 1)) == 1 + 2i);
%! assert (double (B(1, 1)) == 9 + 10i);
%! mpbits (1024);
%! C = A;
%! C(2, 2) = mp (11 + 12i);
%! assert (__mplapack_core__ ("matrix_test_info", C).precision_bits == 1024);
%! assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!                            C, 2, 2, 11 + 12i));

%!test
%! A = mp (complex (zeros (0, 0), zeros (0, 0)));
%! B = mp (complex (zeros (0, 3), zeros (0, 3)));
%! C = mp (complex (zeros (4, 0), zeros (4, 0)));
%! assert (size (A), [0, 0]);
%! assert (size (B), [0, 3]);
%! assert (size (C), [4, 0]);
%! assert (! isreal (A) && ! isreal (B) && ! isreal (C));
%! assert (isempty (A) && isempty (B) && isempty (C));
%! assert (strfind (evalc ("disp (B)"), "complex matrix"));
