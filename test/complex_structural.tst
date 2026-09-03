%!test
%! mpbits (512);
%! z = mp ("1.25", "-2.5");
%! r = real (z);
%! i = imag (z);
%! c = conj (z);
%! assert (isreal (r) && isreal (i) && ! isreal (c));
%! assert (__mplapack_core__ ("value_shape_info", r).precision_bits == 512);
%! assert (__mplapack_core__ ("value_shape_info", i).precision_bits == 512);
%! assert (strcmp (char (r), "1.25e+0"));
%! assert (strcmp (char (i), "-2.5e+0"));
%! assert (strcmp (char (c), "(1.25e+0,2.5e+0)"));
%! assert (double (r) == 1.25 && double (i) == -2.5);
%! assert (double (c) == complex (1.25, 2.5));

%!test
%! mpbits (512);
%! A = mp ([1 + 2i, 3 - 4i; 5 + 6i, 7 - 8i]);
%! R = real (A);
%! I = imag (A);
%! C = conj (A);
%! assert (size (R), [2, 2]);
%! assert (size (I), [2, 2]);
%! assert (size (C), [2, 2]);
%! assert (isreal (R) && isreal (I) && ! isreal (C));
%! assert (double (R), [1, 3; 5, 7]);
%! assert (double (I), [2, -4; 6, -8]);
%! assert (double (C), [1 - 2i, 3 + 4i; 5 - 6i, 7 + 8i]);
%! T = A.';
%! H = A';
%! assert (double (T), [1 + 2i, 5 + 6i; 3 - 4i, 7 - 8i]);
%! assert (double (H), [1 - 2i, 5 - 6i; 3 + 4i, 7 + 8i]);
%! assert (__mplapack_core__ ("matrix_test_info", T).precision_bits == 512);

%!test
%! z = mp ("0", "-0");
%! cz = conj (z);
%! zi = __mplapack_core__ ("scalar_test_info", z);
%! czi = __mplapack_core__ ("scalar_test_info", cz);
%! assert (zi.is_zero && zi.imag_signbit);
%! assert (czi.is_zero && ! czi.imag_signbit);
%! assert (strcmp (char (cz), "(0,0)"));

%!test
%! mpbits (1024);
%! A = mp (complex ([1, 3], [2, 4]));
%! assert (__mplapack_core__ ("value_shape_info", real (A)).precision_bits == 1024);
%! mpbits (2048);
%! B = mp (complex ([5, 7], [6, 8]));
%! assert (__mplapack_core__ ("value_shape_info", imag (B)).precision_bits == 2048);
%! assert (__mplapack_core__ ("value_shape_info", conj (B)).precision_bits == 2048);

%!test
%! r = mp ([1, 2; 3, 4]);
%! assert (isreal (real (r)) && isreal (conj (r)));
%! assert (double (imag (r)), zeros (2, 2));
%! assert (double (r.'), [1, 3; 2, 4]);
%! assert (double (r'), [1, 3; 2, 4]);
