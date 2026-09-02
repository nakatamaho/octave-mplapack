## SPDX-License-Identifier: BSD-2-Clause

%!function assert_pivot_reconstruction (A, Q, R, P, p, tolerance)
%!  if (nargin < 6)
%!    tolerance = 1e-10;
%!  endif
%!  lhs = double (Q * R);
%!  if (! isempty (P))
%!    rhs = double (A * P);
%!  else
%!    rhs = double (A(:, p));
%!  endif
%!  assert (lhs, rhs, tolerance);
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1 0 0; 0 4 0; 0 0 2]);
%!   [Q, R, P] = qr (A);
%!   [Qv, Rv, p] = qr (A, "vector");
%!   assert (strcmp (class (P), "double"));
%!   assert (strcmp (class (p), "double"));
%!   assert (size (P), [3 3]);
%!   assert (size (p), [1 3]);
%!   assert (P, [0 0 1; 1 0 0; 0 1 0]);
%!   assert (p, [2 3 1]);
%!   assert_pivot_reconstruction (A, Q, R, P, [], 1e-12);
%!   assert_pivot_reconstruction (A, Qv, Rv, [], p, 1e-12);
%!   assert (double (Q.' * Q), eye (3), 1e-12);
%!   assert (double (Qv.' * Qv), eye (3), 1e-12);
%! unwind_protect_cleanup
%!  mpbits (saved);
%! end_unwind_protect

%!test
%! mpbits (256);
%! A = mp ([1 20 3; 4 5 16; 7 8 9; 10 11 12]);
%! [Q, R, P] = qr (A);
%! [Qe, Re, Pe] = qr (A, "econ");
%! [Q0, R0, p0] = qr (A, 0);
%! [Qv, Rv, p] = qr (A, "vector");
%! assert (size (Q), [4 4]);
%! assert (size (R), [4 3]);
%! assert (size (P), [3 3]);
%! assert (size (Qe), [4 3]);
%! assert (size (Re), [3 3]);
%! assert (size (Pe), [3 3]);
%! assert (size (Q0), [4 3]);
%! assert (size (R0), [3 3]);
%! assert (size (p0), [1 3]);
%! assert (size (p), [1 3]);
%! assert_pivot_reconstruction (A, Q, R, P, [], 1e-10);
%! assert_pivot_reconstruction (A, Qe, Re, Pe, [], 1e-10);
%! assert_pivot_reconstruction (A, Q0, R0, [], p0, 1e-10);
%! assert_pivot_reconstruction (A, Qv, Rv, [], p, 1e-10);
%! assert (P, Pe);
%! assert (p, p0);
%! assert (sort (p), 1:3);
%! assert (double (Q.' * Q), eye (4), 1e-10);
%! assert (double (Qe.' * Qe), eye (3), 1e-10);
%! mpbits (512);

%!test
%! mpbits (256);
%! A = mp ([1 0 0; 0 4 0; 0 0 2]);
%! [Qn, Rn] = qr (A);
%! [Qp, Rp, P] = qr (A);
%! assert (double (Qn * Rn), double (A), 1e-12);
%! assert (double (Qp * Rp), double (A * P), 1e-12);
%! assert (! isequal (P, eye (3)));
%! mpbits (512);

%!test
%! mpbits (256);
%! wide = mp ([1 0 0 4; 0 2 0 0]);
%! [Q, R, P] = qr (wide);
%! [Qe, Re, Pe] = qr (wide, "econ");
%! [Qv, Rv, p] = qr (wide, "vector");
%! assert (size (Q), [2 2]);
%! assert (size (R), [2 4]);
%! assert (size (Qe), [2 2]);
%! assert (size (Re), [2 4]);
%! assert (size (P), [4 4]);
%! assert (size (p), [1 4]);
%! assert_pivot_reconstruction (wide, Q, R, P, [], 1e-12);
%! assert_pivot_reconstruction (wide, Qe, Re, Pe, [], 1e-12);
%! assert_pivot_reconstruction (wide, Qv, Rv, [], p, 1e-12);
%! assert (sort (p), 1:4);
%! mpbits (512);

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   tail = strcat ("1.", repmat ("0", 1, 210), "1");
%!   A512 = mp ({"1", tail});
%!   assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                              A512, 1, 2, "1"));
%!   [Q512, R512, p512] = qr (A512, "vector");
%!   mpbits (1024);
%!   A1024 = mp ({"1", tail});
%!   assert (! __mplapack_core__ ("matrix_test_element_equal_text", ...
%!                                A1024, 1, 2, "1"));
%!   [Q1024, R1024, p1024] = qr (A1024, "vector");
%!   assert (p512, [1 2]);
%!   assert (p1024, [2 1]);
%!   assert (__mplapack_core__ ("scalar_test_info", Q512).precision_bits, ...
%!           int64 (512));
%!   assert (__mplapack_core__ ("matrix_test_info", R1024).precision_bits, ...
%!           uint64 (1024));
%!   assert (double (Q512 * R512), double (A512(:,p512)), 1e-12);
%!   assert (double (Q1024 * R1024), double (A1024(:,p1024)), 1e-12);
%!   mpbits (4096);
%!   [Qh, Rh, ph] = qr (A1024, "vector");
%!   assert (ph, [2 1]);
%!   assert (__mplapack_core__ ("scalar_test_info", Qh).precision_bits, ...
%!           int64 (1024));
%!   assert (__mplapack_core__ ("matrix_test_info", Rh).precision_bits, ...
%!           uint64 (1024));
%!   assert (mpbits (), uint64 (4096));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! mpbits (256);
%! A = mp ([1 2; 3 4]);
%! before = double (A);
%! [Q, R, P] = qr (A);
%! [Qv, Rv, p] = qr (A, "vector");
%! assert (double (A), before);
%! B = A;
%! [QB, RB, PB] = qr (B);
%! clear A B;
%! assert (__mplapack_core__ ("matrix_test_element_double", Q, 1, 1) != 0);
%! assert (__mplapack_core__ ("matrix_test_element_double", R, 1, 1) != 0);
%! assert (PB, P);
%! assert (sort (p), 1:2);
%! mpbits (512);

%!test
%! mpbits (256);
%! A = mp ([1 2 3; 2 4 6; 3 6 9]);
%! [Q, R, P] = qr (A);
%! [Qv, Rv, p] = qr (A, "vector");
%! assert (sort (p), 1:3);
%! assert (sum (P, 1), ones (1, 3));
%! assert (sum (P, 2), ones (3, 1));
%! assert (double (Q * R), double (A * P), 1e-10);
%! assert (double (Qv * Rv), double (A(:, p)), 1e-10);
%! mpbits (512);

%!test
%! mpbits (256);
%! for x = [4, -4, 0]
%!   [Q, R, P] = qr (mp (x));
%!   [Qv, Rv, p] = qr (mp (x), "vector");
%!   assert (size (Q), [1 1]);
%!   assert (size (R), [1 1]);
%!   assert (P, 1);
%!   assert (p, 1);
%!   assert (double (Q * R), double (mp (x)) * P, 1e-12);
%!   assert (double (Qv * Rv), double (mp (x))(:,p), 1e-12);
%! endfor
%! mpbits (512);

%!test
%! mpbits (256);
%! for shape_cell = {[0, 0], [0, 3], [3, 0]}
%!   shape = shape_cell{1};
%!   A = mp (zeros (shape(1), shape(2)));
%!   [Q, R, P] = qr (A);
%!   [Qv, Rv, p] = qr (A, "vector");
%!   [Qe, Re, Pe] = qr (A, "econ");
%!   [Q0, R0, p0] = qr (A, 0);
%!   assert (size (P), [shape(2), shape(2)]);
%!   assert (size (p), [1, shape(2)]);
%!   assert (size (Pe), [shape(2), shape(2)]);
%!   assert (size (p0), [1, shape(2)]);
%!   assert (size (Q), [shape(1), shape(1)]);
%!   assert (size (R), [shape(1), shape(2)]);
%!   assert (size (Qv), size (Q));
%!   assert (size (Rv), size (R));
%!   if (shape(1) > shape(2))
%!     assert (size (Qe), [shape(1), shape(2)]);
%!     assert (size (Re), [shape(2), shape(2)]);
%!   else
%!     assert (size (Qe), [shape(1), shape(1)]);
%!     assert (size (Re), [shape(1), shape(2)]);
%!   endif
%!   assert (size (Q0), size (Qe));
%!   assert (size (R0), size (Re));
%! endfor
%! mpbits (512);

%!error <qr option must be> qr (mp ([1 2]), "foo")
%!error <at most Q, R, and a permutation> [a,b,c,d] = qr (mp ([1 2]))
