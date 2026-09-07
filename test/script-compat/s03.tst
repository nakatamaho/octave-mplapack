## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 0; -2, NaN]);
%!   assert (isequal (A < 1, [false, true; true, false]));
%!   assert (isequal (A <= 1, [true, true; true, false]));
%!   assert (isequal (A > -2, [true, true; false, false]));
%!   assert (isequal (A >= -2, [true, true; true, false]));
%!   assert (isequal (A == [1, 0; -2, NaN], [true, true; true, false]));
%!   assert (isequal (A ~= [1, 0; -2, NaN], [false, false; false, true]));
%!   assert (isequal (1 < A, [false, false; false, false]));
%!   assert (isequal (A == 1, [true, false; false, false]));
%!   assert (isequal (A == A, [true, true; true, false]));
%!   assert (isequal (logical (A), [true, false; true, true]));
%!   assert (isequal (~A, [false, true; false, false]));
%!   assert (isequal (A & [true, false; false, true], ...
%!                    [true, false; false, true]));
%!   assert (isequal (A | false, [true, false; true, true]));
%!   assert (isequal (xor (A, [true, true; false, false]), ...
%!                    [false, true; true, true]));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 0; -2, NaN]);
%!   assert (isequal (any (A), [true, true]));
%!   assert (isequal (any (A, 2), [true; true]));
%!   assert (isequal (all (A), [true, false]));
%!   assert (isequal (all (A, 2), [false; true]));
%!   assert (any (A, "all"));
%!   assert (! all (mp ([1, 0])));
%!   assert (all (mp (ones (2, 2)), "all"));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 0; -2, NaN]);
%!   assert (isequal (find (A), [1; 2; 4]));
%!   assert (isequal (find (A, 2), [1; 2]));
%!   assert (isequal (find (A, 2, "last"), [2; 4]));
%!   [rows, columns] = find (A);
%!   assert (isequal (rows, [1; 2; 2]));
%!   assert (isequal (columns, [1; 1; 2]));
%!   [rows, columns, values] = find (A);
%!   assert (isequal (rows, [1; 2; 2]));
%!   assert (isequal (columns, [1; 1; 2]));
%!   assert (isequaln (double (values), [1; -2; NaN]));
%!   assert (isequaln (double (A (logical (A))), [1; -2; NaN]));
%!   assert (isequaln (double (A ([1, 4])), [1; NaN]));
%!   B = A;
%!   B (A > 0) = mp (7);
%!   assert (isequaln (double (B), [7, 0; -2, NaN]));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   Z = mp ([1 + 2i, 0; 0, NaN + 1i]);
%!   assert (isequal (Z == Z, [true, true; true, false]));
%!   assert (isequal (Z ~= Z, [false, false; false, true]));
%!   assert (isequal (logical (Z), [true, false; false, true]));
%!   assert (isequal (Z & [true, false; true, false], ...
%!                    [true, false; false, false]));
%!   assert (isequal (find (Z), [1; 4]));
%!   rejected = false;
%!   try
%!     Z < Z;
%!   catch
%!     rejected = true;
%!   end_try_catch
%!   assert (rejected);
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
%!     assert (logical (x));
%!     assert (x == x);
%!     assert (! (x ~= x));
%!     assert (any (x));
%!     assert (! (mpbits () != precision));
%!     mpbits (128);
%!     assert (__mplapack_core__ ("precision_test_mpfr_global_bits") == 128);
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!error <ordered comparison is undefined for complex>
%! mp ([1 + 1i]) < mp ([2 + 2i]);
