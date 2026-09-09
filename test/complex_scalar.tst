%!test
%! mpbits (512);
%! z = mp ("1.25", "-0");
%! assert (! isreal (z));
%! assert (strcmp (class (z), "mp"));
%! text = char (z);
%! assert (strcmp (text, "(1.25e+0,-0)"));
%! assert (strcmp (char (mp (text)), text));
%! assert (double (z) == complex (1.25, -0.0));

%!test
%! for bits = [1024, 2048]
%!   mpbits (bits);
%!   z = mp ("1", "1e-211");
%!   info = __mplapack_core__ ("scalar_test_info", z);
%!   assert (info.precision_bits == bits);
%!   assert (info.is_complex);
%!   assert (strcmp (char (mp (char (z))), char (z)));
%! endfor

%!test
%! z = mp (complex (1, -2));
%! assert (! isreal (z));
%! assert (double (z) == complex (1, -2));
%! r = mp ("0.1");
%! assert (isreal (r));
%! assert (! __mplapack_core__ ("value_shape_info", r).is_complex);
