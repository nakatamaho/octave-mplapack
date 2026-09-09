## SPDX-License-Identifier: BSD-2-Clause

%!test
%! old_visible = get (0, "defaultfigurevisible");
%! unwind_protect
%!   graphics_toolkit ("gnuplot");
%!   set (0, "defaultfigurevisible", "off");
%!   x = mp ([1; 2; 3]);
%!   y = mp ([2; 4; 8]);
%!   fig = figure ("visible", "off");
%!   ax = axes ("parent", fig);
%!   h = plot (ax, y, "o-", "linewidth", 2);
%!   assert (isgraphics (h, "line"));
%!   assert (get (h, "xdata"), [1, 2, 3]);
%!   assert (get (h, "ydata"), [2, 4, 8]);
%!   assert (get (h, "linewidth"), 2);
%!   close (fig);
%! unwind_protect_cleanup
%!   set (0, "defaultfigurevisible", old_visible);
%!   close all;
%! end_unwind_protect

%!test
%! old_visible = get (0, "defaultfigurevisible");
%! unwind_protect
%!   graphics_toolkit ("gnuplot");
%!   set (0, "defaultfigurevisible", "off");
%!   x = mp ([1; 2; 3]);
%!   y = mp ([2; 4; 8]);
%!   fig = figure ("visible", "off");
%!   ax = axes ("parent", fig);
%!   hold (ax, "on");
%!   h = plot (ax, x, y, "o-", x, 2 * y, "x--", "color", [0, 0, 1]);
%!   assert (numel (h) == 2);
%!   assert (get (h(1), "xdata"), [1, 2, 3]);
%!   assert (get (h(2), "ydata"), [4, 8, 16]);
%!   hm = plot (ax, [1; 2; 3], y, "+");
%!   assert (isgraphics (hm, "line"));
%!   hsx = semilogx (ax, x, y, "s");
%!   hsy = semilogy (ax, x, y, "d");
%!   hll = loglog (ax, x, y, "^");
%!   hsc = scatter (ax, x, y);
%!   hst = stem (ax, x, y);
%!   hsr = stairs (ax, x, y);
%!   assert (isgraphics (hsx, "line") && isgraphics (hsy, "line"));
%!   assert (isgraphics (hll, "line") && isgraphics (hsc));
%!   assert (isgraphics (hst) && isgraphics (hsr));
%!   close (fig);
%! unwind_protect_cleanup
%!   set (0, "defaultfigurevisible", old_visible);
%!   close all;
%! end_unwind_protect

%!test
%! old_visible = get (0, "defaultfigurevisible");
%! unwind_protect
%!   graphics_toolkit ("gnuplot");
%!   set (0, "defaultfigurevisible", "off");
%!   z = mp ([1 + 2i; 2 + 1i; 3 + 3i]);
%!   fig = figure ("visible", "off");
%!   ax = axes ("parent", fig);
%!   h = plot (ax, z, "o");
%!   assert (get (h, "xdata"), [1, 2, 3]);
%!   assert (get (h, "ydata"), [2, 1, 3]);
%!   close (fig);
%! unwind_protect_cleanup
%!   set (0, "defaultfigurevisible", old_visible);
%!   close all;
%! end_unwind_protect

%!test
%! old_visible = get (0, "defaultfigurevisible");
%! unwind_protect
%!   graphics_toolkit ("gnuplot");
%!   set (0, "defaultfigurevisible", "off");
%!   A = mp (gallery ("grcar", 32));
%!   balanced = eig (A, "balance");
%!   unbalanced = eig (A, "nobalance");
%!   fig = figure ("visible", "off");
%!   ax = axes ("parent", fig);
%!   h1 = plot (ax, real (balanced), imag (balanced), "o");
%!   hold (ax, "on");
%!   h2 = plot (ax, real (unbalanced), imag (unbalanced), "x");
%!   axis (ax, "equal");
%!   grid (ax, "on");
%!   assert (isgraphics (h1, "line") && isgraphics (h2, "line"));
%!   assert (numel (get (h1, "xdata")) == 32);
%!   assert (numel (get (h2, "ydata")) == 32);
%!   close (fig);
%! unwind_protect_cleanup
%!   set (0, "defaultfigurevisible", old_visible);
%!   close all;
%! end_unwind_protect
