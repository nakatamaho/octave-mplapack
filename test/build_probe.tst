%!test
%! info = mplapack_version ();
%! required = {"octave", "mplapack", "backend", "mpfr", ...
%!             "probe_routine", "probe_ok", "probe_value"};
%! assert (isstruct (info));
%! assert (all (isfield (info, required)));
%! assert (! isempty (info.octave));
%! assert (! isempty (info.mplapack));
%! assert (strcmp (info.backend, "mpfr"));
%! assert (! isempty (info.mpfr));
%! assert (strcmp (info.probe_routine, 'Rlamch_mpfr("E")'));
%! assert (info.probe_ok);
%! assert (isfinite (info.probe_value));
%! assert (info.probe_value > 0 && info.probe_value < 1);
%! expected = getenv ("MPLAPACK_EXPECTED_VERSION");
%! if (! isempty (expected))
%!   assert (strcmp (info.mplapack, expected));
%! endif
