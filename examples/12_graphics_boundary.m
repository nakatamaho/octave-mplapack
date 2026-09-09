% Headless graphics-boundary example. Numerical data stays mp until plotting.
if (exist ("mpbits", "file") != 2)
  pkg load mplapack-interop
endif

toolkits = available_graphics_toolkits ();
if (! any (strcmp (toolkits, "gnuplot")))
  fprintf ("graphics example SKIP: no headless gnuplot toolkit available\n");
  return;
endif

saved_bits = mpbits ();
old_visible = get (0, "defaultfigurevisible");
unwind_protect
  mpbits (512);
  graphics_toolkit ("gnuplot");
  set (0, "defaultfigurevisible", "off");
  t = linspace (mp ("0"), mp ("6.283185307179586476925286766559"), 24);
  x = cos (t);
  y = sin (t);
  z = t;
  fig = figure ("visible", "off");
  ax = axes ("parent", fig);
  h = plot3 (ax, x, y, z, "o-");
  assert (isgraphics (h, "line"));
  assert (get (h, "xdata"), double (x));
  close (fig);
  fprintf ("graphics boundary PASS: final mp-to-double conversion only\n");
unwind_protect_cleanup
  set (0, "defaultfigurevisible", old_visible);
  close all;
  mpbits (saved_bits);
end_unwind_protect
