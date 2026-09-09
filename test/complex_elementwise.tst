%!function info = complex_elementwise_info (value)
%!  if (__mplapack_core__ ("value_is_matrix", value))
%!    info = __mplapack_core__ ("matrix_test_info", value);
%!  else
%!    info = __mplapack_core__ ("scalar_test_info", value);
%!  endif
%!endfunction

%!test
%! mpbits (512);
%! a = mp ("1", "2");
%! b = mp ("3", "4");
%! assert (strcmp (char (a + b), "(4e+0,6e+0)"));
%! assert (strcmp (char (a - b), "(-2e+0,-2e+0)"));
%! assert (strcmp (char (a .* b), "(-5e+0,1e+1)"));
%! assert (strcmp (char (a ./ mp ("1", "0")), "(1e+0,2e+0)"));
%! assert (strcmp (char (-a), "(-1e+0,-2e+0)"));
%! assert (strcmp (char (+a), char (a)));

%!test
%! mpbits (256);
%! r = mp ("1.5");
%! z = mp ("2", "3");
%! assert (! isreal (r + z) && ! isreal (z + r));
%! assert (double (r + z) == complex (3.5, 3));
%! assert (double (z - r) == complex (0.5, 3));
%! assert (double (r .* z) == complex (3, 4.5));
%! assert (double (z ./ r) == complex (4 / 3, 2));
%! builtin = complex (0.25, -0.5);
%! assert (! isreal (z + builtin));
%! assert (double (z + builtin) == complex (2.25, 2.5));
%! assert (! isreal (builtin - z));
%! assert (double (builtin - z) == complex (-1.75, -3.5));

%!test
%! mpbits (512);
%! A = mp ([1 + 2i, 3 + 4i; 5 + 6i, 7 + 8i]);
%! row = mp ([10 + 1i, 20 + 2i]);
%! column = mp ([100 + 10i; 200 + 20i]);
%! assert (double (A + row), [11 + 3i, 23 + 6i; 15 + 7i, 27 + 10i]);
%! assert (double (A + column), [101 + 12i, 103 + 14i; 205 + 26i, 207 + 28i]);
%! assert (double (column - row), [90 + 9i, 80 + 8i; 190 + 19i, 180 + 18i]);
%! assert (size (A .* [2 + 1i, 3 + 2i]), [2, 2]);
%! assert (! isreal (-(A)));
%! assert (complex_elementwise_info (A + row).precision_bits == 512);

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (128);
%!   low = mp ("1", "2");
%!   mpbits (1024);
%!   high = mp ("3", "4");
%!   mpbits (2048);
%!   result = low + high;
%!   assert (complex_elementwise_info (result).precision_bits == 1024);
%!   assert (strcmp (char (result), "(4e+0,6e+0)"));
%!   assert (mpbits (), uint64 (2048));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits") == 2048);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! positive = mp ("1", "0");
%! zero = mp ("0", "0");
%! quotient = positive ./ zero;
%! qinfo = __mplapack_core__ ("scalar_test_info", quotient);
%! assert (qinfo.is_infinite || qinfo.is_nan);
%! nan_value = mp ("NaN", "0");
%! assert (__mplapack_core__ ("scalar_test_info", nan_value + positive).is_nan);

%!test
%! A = mp (complex (zeros (0, 3), zeros (0, 3)));
%! B = mp (complex (ones (1, 3), zeros (1, 3)));
%! C = A + B;
%! assert (size (C), [0, 3]);
%! assert (! isreal (C));
