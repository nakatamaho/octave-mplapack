## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 2, 3; 4, 5, 6]);
%!   assert (double (diag (A)), [1; 5]);
%!   assert (double (diag (A, 1)), [2; 6]);
%!   assert (double (diag (A, -1)), 4);
%!   V = mp ([7; 8; 9]);
%!   assert (double (diag (V, -1)), [0, 0, 0, 0; 7, 0, 0, 0; ...
%!                                   0, 8, 0, 0; 0, 0, 9, 0]);
%!   assert (double (triu (A)), [1, 2, 3; 0, 5, 6]);
%!   assert (double (triu (A, 1)), [0, 2, 3; 0, 0, 6]);
%!   assert (double (tril (A)), [1, 0, 0; 4, 5, 0]);
%!   assert (double (tril (A, -1)), [0, 0, 0; 4, 0, 0]);
%!   info = __mplapack_core__ ("value_shape_info", triu (A));
%!   assert (info.precision_bits == 256);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   Z = mp ([1 + 2i, 2 - 1i; 3, 4 + 3i]);
%!   assert (double (diag (Z)), [1 + 2i; 4 + 3i], 1e-12);
%!   assert (double (diag (Z, 1)), 2 - 1i, 1e-12);
%!   assert (double (triu (Z)), [1 + 2i, 2 - 1i; 0, 4 + 3i], 1e-12);
%!   assert (double (tril (Z, -1)), [0, 0; 3, 0], 1e-12);
%!   R = repmat (Z, [2, 2]);
%!   assert (double (R), repmat (double (Z), [2, 2]), 1e-12);
%!   assert (! __mplapack_core__ ("value_is_real", R));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (320);
%!   A = mp ([1, 2; 3, 4]);
%!   R = zeros (2, 3, "like", A);
%!   O = ones ([2, 2], "like", A);
%!   E = eye (2, "like", A);
%!   N = NaN (1, 2, "like", A);
%!   I = Inf (1, 2, "like", A);
%!   assert (isa (R, "mp") && isa (O, "mp") && isa (E, "mp"));
%!   assert (double (R), zeros (2, 3));
%!   assert (double (O), ones (2, 2));
%!   assert (double (E), eye (2));
%!   assert (all (isnan (N)) && all (isinf (I)));
%!   Z = mp ([1 + 2i, 3 - 4i]);
%!   C = zeros (2, 2, "like", Z);
%!   CE = eye ([2, 3], "like", Z);
%!   CN = NaN (1, 2, "like", Z);
%!   CI = Inf (1, 2, "like", Z);
%!   assert (! __mplapack_core__ ("value_is_real", C));
%!   assert (! __mplapack_core__ ("value_is_real", CE));
%!   assert (double (C), zeros (2, 2), 1e-12);
%!   assert (double (CE), [1, 0, 0; 0, 1, 0], 1e-12);
%!   assert (all (isnan (CN)) && all (isinf (CI)));
%!   assert (__mplapack_core__ ("value_shape_info", R).precision_bits == 320);
%!   assert (__mplapack_core__ ("value_shape_info", CE).precision_bits == 320);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 2, 3; 4, 5, 6]);
%!   assert (double (repmat (A, 2, 3)), ...
%!           repmat ([1, 2, 3; 4, 5, 6], 2, 3));
%!   assert (double (flipud (A)), [4, 5, 6; 1, 2, 3]);
%!   assert (double (fliplr (A)), [3, 2, 1; 6, 5, 4]);
%!   assert (double (flip (A, 1)), flipud (double (A)));
%!   assert (double (flip (A, 2)), fliplr (double (A)));
%!   assert (double (flip (A)), flipud (double (A)));
%!   assert (double (rot90 (A)), [3, 6; 2, 5; 1, 4]);
%!   assert (double (rot90 (A, 2)), [6, 5, 4; 3, 2, 1]);
%!   assert (double (rot90 (A, -1)), [4, 1; 5, 2; 6, 3]);
%!   Z = mp ([1 + 1i, 2 + 2i; 3 + 3i, 4 + 4i]);
%!   assert (double (rot90 (Z)), [2 + 2i, 4 + 4i; 1 + 1i, 3 + 3i], 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 2; 3, 4]);
%!   B = mp ([5, 6; 7, 8]);
%!   assert (double (cat (1, A, A)), [1, 2; 3, 4; 1, 2; 3, 4]);
%!   assert (double (cat (2, A, A)), [1, 2, 1, 2; 3, 4, 3, 4]);
%!   assert (double (cat (2, A, B)), [1, 2, 5, 6; 3, 4, 7, 8]);
%!   assert (double (cat (1, B, B)), [5, 6; 7, 8; 5, 6; 7, 8]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for precision = [1024, 2048]
%!     mpbits (precision);
%!     x = mp ("2") ^ ((precision == 1024) * -700 ...
%!                      + (precision == 2048) * -1500);
%!     A = repmat (x, 2, 2);
%!     assert (__mplapack_core__ ("value_shape_info", A).precision_bits == precision);
%!     assert (logical (all (diag (A) == x)));
%!     mpbits (128);
%!     assert (__mplapack_core__ ("precision_test_mpfr_global_bits") == 128);
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!error <real integer scalar>
%! triu (mp ([1, 2]), "pack");

%!error <dimensions 1 and 2>
%! cat (3, mp ([1]), mp ([2]));

%!error <dimension must be 1 or 2>
%! flip (mp ([1, 2]), 3);
