## SPDX-License-Identifier: BSD-2-Clause

%!function assert_fails (thunk, label)
%!  did_fail = false;
%!  try
%!    thunk ();
%!  catch
%!    did_fail = true;
%!  end_try_catch
%!  assert (did_fail, label);
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   text_value = mp ("0.1");
%!   binary_value = mp (0.1);
%!   assert (! __mplapack_core__ ("scalar_test_equal", text_value, binary_value));
%!   assert (__mplapack_core__ ("scalar_test_equal_string", text_value, "0.1"));
%!   A = mp ([1, 2; 3, 4]);
%!   assert (size (A), [2, 2]);
%!   assert (rows (A), 2);
%!   assert (columns (A), 2);
%!   assert (numel (A), 4);
%!   assert (ndims (A), 2);
%!   assert (! isempty (A));
%!   assert (size (A, 3), 1);
%!   B = A;
%!   B(1, 1) = mp (9);
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", A, 1, 1, 1));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", B, 1, 1, 9));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([2, 1; 1, 3]);
%!   b = mp ([1; 2]);
%!   x = A \ b;
%!   assert (size (x), [2, 1]);
%!   [Q, R] = qr (A);
%!   assert (size (Q), [2, 2]);
%!   assert (size (R), [2, 2]);
%!   [L, U, P] = lu (A);
%!   assert (size (L), [2, 2]);
%!   assert (size (U), [2, 2]);
%!   assert (size (P), [2, 2]);
%!   C = chol (A);
%!   assert (size (C), [2, 2]);
%!   assert (isa (x, "mp") && isa (Q, "mp") && isa (R, "mp") ...
%!           && isa (L, "mp") && isa (U, "mp") && isa (C, "mp"));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp ([1, 2; 3, 4]);
%! assert_fails (@() eig (A), "eig must reject mp matrices");
%! assert_fails (@() svd (A), "svd must reject mp matrices");
%! assert_fails (@() det (A), "det must reject mp matrices");
%! assert_fails (@() inv (A), "inv must reject mp matrices");
%! assert_fails (@() rank (A), "rank must reject mp matrices");
%! assert_fails (@() norm (A), "norm must reject mp matrices");
%! assert_fails (@() sin (A), "sin must reject mp matrices");
%! assert_fails (@() exp (A), "exp must reject mp matrices");
%! assert_fails (@() sqrt (A), "sqrt must reject mp matrices");
%! assert_fails (@() (A ^ 2), "power must reject mp matrices");
%! assert_fails (@() (A == A), "comparison must reject mp matrices");
%! assert_fails (@() (A / A), "right division must reject mp matrices");

%!test
%! help_text = evalc ("help @mp/qr");
%! assert (! isempty (strfind (help_text, "qr")));
%! help_text = evalc ("help @mp/lu");
%! assert (! isempty (strfind (help_text, "lu")));
%! help_text = evalc ("help @mp/rows");
%! assert (! isempty (strfind (help_text, "rows")));
