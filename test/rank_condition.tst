## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ([1, 2; 3, 4]);
%!   assert (rank (A), 2);
%!   assert (rank (A, mp ("1")), 1);
%!   c2 = cond (A);
%!   c1 = cond (A, 1);
%!   ci = cond (A, Inf);
%!   cf = cond (A, "fro");
%!   rc = rcond (A);
%!   assert (double (c2) > 14 && double (c2) < 15);
%!   assert (double (c1) > 20 && double (c1) < 22);
%!   assert (double (ci) > 20 && double (ci) < 22);
%!   assert (double (cf) > 14 && double (cf) < 16);
%!   assert (abs (double (c1 * rc) - 1) < 1e-12);
%!   [d, det_rc] = det (A);
%!   assert (double (d), -2, 1e-12);
%!   assert (abs (double (det_rc - rc)) < 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   Z = mp ([1 + 2i, 2 - 1i; 3, 4 + 3i]);
%!   assert (rank (Z), 2);
%!   assert (double (cond (Z)) > 1);
%!   assert (double (cond (Z, 1)) > 1);
%!   assert (double (cond (Z, Inf)) > 1);
%!   assert (double (cond (Z, "fro")) > 1);
%!   assert (double (rcond (Z)) > 0 && double (rcond (Z)) < 1);
%!   [d, det_rc] = det (Z);
%!   assert (! isreal (d));
%!   assert (double (det_rc) > 0 && double (det_rc) < 1);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ([1, 0; 0, 0]);
%!   assert (rank (A), 1);
%!   assert (rank (A, 0), 1);
%!   assert (rank (A, Inf), 0);
%!   assert (isinf (double (cond (A))));
%!   assert (double (rcond (A)) == 0);
%!   empty = mp (zeros (0, 0));
%!   assert (rank (empty), 0);
%!   assert (double (cond (empty)) == 0);
%!   assert (isinf (double (rcond (empty))));
%!   nonsquare = mp ([1, 2, 3; 4, 5, 6]);
%!   assert (rank (nonsquare), 2);
%!   assert (double (cond (nonsquare)) > 1);
%!   fail ("cond (nonsquare, 1)", "square");
%!   fail ("rcond (nonsquare)", "square");
%!   fail ("cond (nonsquare, \"fro\")", "square");
%!   fail ("[d, c] = det (empty)", "one output");
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A512 = mp ([1, 0; 0, 1]);
%!   tail = mp ("1");
%!   for k = 1:700, tail = tail .* mp ("0.5"); endfor
%!   A512 (2, 2) = tail;
%!   assert (rank (A512), 1);
%!   mpbits (1024);
%!   A1024 = mp ([1, 0; 0, 1]);
%!   tail = mp ("1");
%!   for k = 1:700, tail = tail .* mp ("0.5"); endfor
%!   A1024 (2, 2) = tail;
%!   assert (rank (A1024), 2);
%!   assert (__mplapack_core__ ("matrix_test_info", A1024).precision_bits == 1024);
%!   mpbits (2048);
%!   A2048 = mp ([1, 0; 0, 1]);
%!   tail = mp ("1");
%!   for k = 1:1500, tail = tail .* mp ("0.5"); endfor
%!   A2048 (2, 2) = tail;
%!   assert (rank (A2048), 2);
%!   assert (double (cond (A2048)) > 0);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp ([1, 2; 3, 4]);
%! fail ("cond (A, 3)", "cond norm");
%! fail ("cond (A, \"bad\")", "cond string option");
%! fail ("rank (A, mp ([1, 2]))", "real scalar");
