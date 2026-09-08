## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! old_visible = get (0, "defaultfigurevisible");
%! unwind_protect
%!   mpbits (256);
%!   t = linspace (mp ("0"), mp ("1"), 5);
%!   one = t + mp ("1");
%!   y = sqrt (one) .* exp (log (one)) .* (sin (t) .^ 2 + cos (t) .^ 2);
%!   assert (isa (y, "mp"));
%!   assert (size (y), [1, 5]);
%!   assert (double (sum (y)), sum (double (y)), 1e-12);
%!   graphics_toolkit ("gnuplot");
%!   set (0, "defaultfigurevisible", "off");
%!   fig = figure ("visible", "off");
%!   ax = axes ("parent", fig);
%!   h = plot (ax, t, y, "o-");
%!   assert (isgraphics (h, "line"));
%!   close (fig);
%! unwind_protect_cleanup
%!   set (0, "defaultfigurevisible", old_visible);
%!   close all;
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "NaN", "3"; "4", "5", "Inf"});
%!   mask = isfinite (A) & (A > mp ("2"));
%!   selected = A(mask);
%!   assert (numel (selected), 3);
%!   assert (double (min (selected)), 3);
%!   assert (double (max (selected)), 5);
%!   assert (double (mean (selected)), 4);
%!   assert (double (std (selected)), 1);
%!   assert (all (isfinite (selected)));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   template = mp ({"1", "2"; "3", "4"});
%!   Z = zeros (2, 3, "like", template);
%!   O = ones (2, 3, "like", template);
%!   I = eye (2, "like", template);
%!   assert (size (Z), [2, 3]);
%!   assert (double (O), ones (2, 3));
%!   assert (double (I), eye (2));
%!   D = diag (mp ([1, 2, 3]));
%!   assert (double (D), diag ([1, 2, 3]));
%!   assert (double (triu (D + mp (1))), triu (double (D + mp (1))));
%!   assert (double (tril (D + mp (1))), tril (double (D + mp (1))));
%!   R = repmat (mp ([1, 2]), 2, 2);
%!   assert (double (R), repmat ([1, 2], 2, 2));
%!   assert (double (flip (R, 1)), flip (double (R), 1));
%!   assert (double (cat (1, R, R)), cat (1, double (R), double (R)));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"4", "1"; "2", "3"});
%!   right_identity = A / A;
%!   assert (double (norm (right_identity - eye (2, "like", A))), ...
%!           0, 1e-12);
%!   values = eig (A);
%!   singular = svd (A);
%!   assert (numel (values), 2);
%!   assert (numel (singular), 2);
%!   assert (rank (A), 2);
%!   assert (double (cond (A)) > 1);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! old_visible = get (0, "defaultfigurevisible");
%! unwind_protect
%!   mpbits (256);
%!   A = mp (gallery ("grcar", 8));
%!   e = eig (A);
%!   identity = eye (8, "like", A);
%!   residual = norm (A / A - identity);
%!   assert (double (residual) < 1e-12);
%!   balanced = eig (A, "balance");
%!   unbalanced = eig (A, "nobalance");
%!   graphics_toolkit ("gnuplot");
%!   set (0, "defaultfigurevisible", "off");
%!   fig = figure ("visible", "off");
%!   ax = axes ("parent", fig);
%!   h1 = plot (ax, real (e), imag (e), "o");
%!   hold (ax, "on");
%!   h2 = plot (ax, real (balanced), imag (balanced), "x");
%!   h3 = plot (ax, real (unbalanced), imag (unbalanced), "+");
%!   axis (ax, "equal");
%!   grid (ax, "on");
%!   assert (isgraphics (h1, "line") && isgraphics (h2, "line")
%!           && isgraphics (h3, "line"));
%!   close (fig);
%! unwind_protect_cleanup
%!   set (0, "defaultfigurevisible", old_visible);
%!   close all;
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! old_visible = get (0, "defaultfigurevisible");
%! unwind_protect
%!   mpbits (256);
%!   negative_root = sqrt (mp ("-1"));
%!   negative_log = log (mp ("-1"));
%!   z = mp ([1 + 2i, 2 - 1i, -1 + 1i]);
%!   trig = sin (z) + cos (z);
%!   assert (! isreal (negative_root) && ! isreal (negative_log));
%!   assert (! isreal (trig));
%!   assert (double (abs (z)), abs (double (z)), 1e-12);
%!   assert (double (angle (z)), angle (double (z)), 1e-12);
%!   assert (isequal (z, z));
%!   rejected = false;
%!   try
%!     z < z;
%!   catch
%!     rejected = true;
%!   end_try_catch
%!   assert (rejected);
%!   assert (double (mean (z)), mean (double (z)), 1e-12);
%!   [~, order] = sort (z);
%!   assert (isequal (order, [3, 2, 1]));
%!   graphics_toolkit ("gnuplot");
%!   set (0, "defaultfigurevisible", "off");
%!   fig = figure ("visible", "off");
%!   ax = axes ("parent", fig);
%!   h = plot (ax, z, "o");
%!   assert (get (h, "xdata"), [1, 2, -1]);
%!   assert (get (h, "ydata"), [2, -1, 1]);
%!   close (fig);
%! unwind_protect_cleanup
%!   set (0, "defaultfigurevisible", old_visible);
%!   close all;
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"3", "1"; "2", "NaN"});
%!   [ascending, ia] = sort (A);
%!   assert (isequaln (double (ascending), [2, 1; 3, NaN]));
%!   assert (isequal (ia, [2, 1; 1, 2]));
%!   [descending, id] = sort (A, 2, "descend");
%!   assert (isequaln (double (descending), [3, 1; NaN, 2]));
%!   assert (isequal (id, [1, 2; 2, 1]));
%!   D = mp ([1, 4, 9, 16]);
%!   assert (double (diff (D)), [3, 5, 7]);
%!   assert (double (diff (D, 2)), [2, 2]);
%!   M = mp ([1, 3, 6; 2, 5, 9]);
%!   assert (double (diff (M, 1, 1)), [1, 2, 3]);
%!   assert (double (diff (M, 1, 2)), [2, 3; 3, 4]);
%!   assert (isequal (double (diff (M, 0)), double (M)));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for precision = [1024, 2048]
%!     mpbits (precision);
%!     exponent = (precision == 1024) * -700 ...
%!                + (precision == 2048) * -1500;
%!     x = mp ("2") ^ exponent;
%!     incremented = x + eps (x);
%!     sorted = sort ([x, incremented]);
%!     differences = diff ([x, incremented]);
%!     assert (__mplapack_core__ ("value_shape_info", sorted).precision_bits == precision);
%!     assert (__mplapack_core__ ("value_shape_info", differences).precision_bits == precision);
%!     assert (isequal (sorted (1), x));
%!     assert (all (differences == eps (x)));
%!     mpbits (128);
%!     assert (__mplapack_core__ ("precision_test_mpfr_global_bits") == 128);
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 2; 3, 4]);
%!   assert (length (A), 2);
%!   assert (isequal (size (A), [2, 2]));
%!   assert (rows (A), 2);
%!   assert (columns (A), 2);
%!   assert (numel (A), 4);
%!   assert (ndims (A), 2);
%!   assert (! isempty (A));
%!   empty = zeros (0, 3, "like", A);
%!   assert (isempty (empty));
%!   assert (size (empty), [0, 3]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!error <sort dimension must be 1 or 2>
%! sort (mp ([1 + 1i, 2 + 2i]), 3);

%!test
%! assert (isequal (diff ([1, 2, 3]), [1, 1]));

%!test
%! saved = mpbits ();
%! old_visible = get (0, "defaultfigurevisible");
%! unwind_protect
%!   mpbits (256);
%!   graphics_toolkit ("gnuplot");
%!   set (0, "defaultfigurevisible", "off");
%!   A = mp ([1, 2; 3, 4]);
%!   fig = figure ("visible", "off");
%!   ax = axes ("parent", fig);
%!   h = mesh (ax, A);
%!   assert (isgraphics (h));
%!   close (fig);
%! unwind_protect_cleanup
%!   set (0, "defaultfigurevisible", old_visible);
%!   close all;
%!   mpbits (saved);
%! end_unwind_protect
