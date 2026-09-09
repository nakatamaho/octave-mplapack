## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! old_visible = get (0, "defaultfigurevisible");
%! unwind_protect
%!   mpbits (1024);
%!   graphics_toolkit ("gnuplot");
%!   set (0, "defaultfigurevisible", "off");
%!   t = linspace (mp ("0"), mp ("6.283185307179586476925286766559"), 17);
%!   x = cos (t);
%!   y = sin (t);
%!   z = t;
%!   fig = figure ("visible", "off");
%!   ax = axes ("parent", fig);
%!   h = plot3 (ax, x, y, z, "o-", "linewidth", 2);
%!   assert (isgraphics (h, "line"));
%!   assert (get (h, "linewidth"), 2);
%!   assert (get (h, "xdata"), double (x));
%!   assert (get (h, "ydata"), double (y));
%!   assert (get (h, "zdata"), double (z));
%!   hs = scatter3 (ax, x, y, z, 12, "filled");
%!   assert (isgraphics (hs));
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
%!   mpbits (1024);
%!   graphics_toolkit ("gnuplot");
%!   set (0, "defaultfigurevisible", "off");
%!   X = mp ({"0", "1"; "0", "1"});
%!   Y = mp ({"0", "0"; "1", "1"});
%!   tiny = mp ("1");
%!   for k = 1:700, tiny = tiny * mp ("0.5"); endfor
%!   Z = mp ({"0", "1"; "1", "2"});
%!   Z(1, 1) = tiny;
%!   fig = figure ("visible", "off");
%!   ax = axes ("parent", fig);
%!   hm = mesh (ax, X, Y, Z, "edgecolor", [0, 0, 1]);
%!   assert (isgraphics (hm));
%!   assert (get (hm, "xdata"), double (X));
%!   assert (get (hm, "zdata"), double (Z));
%!   hf = surf (ax, X, Y, Z);
%!   assert (isgraphics (hf));
%!   [contour_matrix, hline] = contour3 (ax, X, Y, Z);
%!   assert (isnumeric (contour_matrix) && isgraphics (hline));
%!   hmc = meshc (ax, X, Y, Z);
%!   hsc = surfc (ax, X, Y, Z);
%!   hw = waterfall (ax, X, Y, Z);
%!   assert (numel (hmc) >= 1 && numel (hsc) >= 1 && isgraphics (hw));
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
%!   mpbits (512);
%!   graphics_toolkit ("gnuplot");
%!   set (0, "defaultfigurevisible", "off");
%!   w = mp ([1 + 2i, 2 - 1i, 3 + 3i]);
%!   fig = figure ("visible", "off");
%!   ax = axes ("parent", fig);
%!   h = plot3 (ax, real (w), imag (w), mp ([1, 2, 3]), "x-");
%!   assert (isgraphics (h, "line"));
%!   assert (get (h, "xdata"), [1, 2, 3]);
%!   assert (get (h, "ydata"), [2, -1, 3]);
%!   assert (get (h, "zdata"), [1, 2, 3]);
%!   close (fig);
%! unwind_protect_cleanup
%!   set (0, "defaultfigurevisible", old_visible);
%!   close all;
%!   mpbits (saved);
%! end_unwind_protect
