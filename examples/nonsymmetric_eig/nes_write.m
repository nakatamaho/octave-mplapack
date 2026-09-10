% Write deterministic, non-overwriting NEIG result files.
function paths = nes_write (results, output_dir)
  if (nargin != 2 || ! isstruct (results) || ! isscalar (results) ...
      || ! ischar (output_dir) || rows (output_dir) != 1 || isempty (output_dir))
    error ("NEIG:WriteArguments", ...
           "nes_write expects a scalar result and a nonempty output directory");
  endif
  if (! exist (output_dir, "dir"))
    [created, message] = mkdir (output_dir);
    if (! created)
      error ("NEIG:WriteDirectory", "cannot create output directory: %s", message);
    endif
  elseif (! isfolder (output_dir))
    error ("NEIG:WriteDirectory", "output path is not a directory: %s", output_dir);
  endif

  names = {"summary.tsv", "eigenvalues.tsv", "environment.txt", "report.md"};
  paths = struct ("summary", fullfile (output_dir, names{1}), ...
                  "eigenvalues", fullfile (output_dir, names{2}), ...
                  "environment", fullfile (output_dir, names{3}), ...
                  "report", fullfile (output_dir, names{4}));
  if (isfield (results.options, "plot") && results.options.plot)
    names{end + 1} = "spectrum.png";
    paths.plot = fullfile (output_dir, names{end});
  endif
  for k = 1:numel (names)
    if (exist (fullfile (output_dir, names{k}), "file"))
      error ("NEIG:WriteExists", ...
             "refusing to overwrite existing result file: %s", names{k});
    endif
  endfor

  write_summary (paths.summary, results);
  write_eigenvalues (paths.eigenvalues, results);
  write_environment (paths.environment, results);
  write_report (paths.report, results, paths);
  if (isfield (paths, "plot"))
    nes_plot (results, paths.plot);
  endif
endfunction

function write_summary (path, results)
  file = open_new (path);
  unwind_protect
    fprintf (file, ["family\trepresentation\tn\ta\ts\tbackend\twork_bits\t", ...
                    "mode\tnative\tsolver_status\tinput_precision\t", ...
                    "reference_status\taccuracy_status\tright_residual\t", ...
                    "left_residual\tabsolute_error\trelative_error\tcircle_error\t", ...
                    "condition_status\tsolver_time\n"]);
    for k = 1:numel (results.rows)
      row = results.rows(k);
      fprintf (file, "%s\t%s\t%d\t%s\t%s\t%s\t%d\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", ...
              row.family, row.representation, row.n, scalar_text (row.a), ...
              scalar_text (row.s), row.backend, row.work_bits, row.mode, ...
              scalar_text (row.native), row.solver_status, row.input_precision, ...
              row.reference_status, row.accuracy_status, ...
              scalar_text (row.right_residual), scalar_text (row.left_residual), ...
              scalar_text (row.absolute_error), scalar_text (row.relative_error), ...
              scalar_text (row.circle_error), row.condition_status, ...
              scalar_text (row.solver_time));
    endfor
  unwind_protect_cleanup
    fclose (file);
  end_unwind_protect
endfunction

function write_eigenvalues (path, results)
  file = open_new (path);
  unwind_protect
    fprintf (file, ["row\tfamily\trepresentation\tmode\tbackend\twork_bits\t", ...
                    "index\tcomputed_real\tcomputed_imag\treference_real\t", ...
                    "reference_imag\n"]);
    for k = 1:numel (results.rows)
      row = results.rows(k);
      if (isempty (row.computed_values))
        continue;
      endif
      for j = 1:numel (row.computed_values)
        computed = row.computed_values(j);
        reference = row.reference_values(j);
        fprintf (file, "%d\t%s\t%s\t%s\t%s\t%d\t%d\t%s\t%s\t%s\t%s\n", ...
                k, row.family, row.representation, row.mode, row.backend, ...
                row.work_bits, j, scalar_text (real (computed)), ...
                scalar_text (imag (computed)), scalar_text (real (reference)), ...
                scalar_text (imag (reference)));
      endfor
    endfor
  unwind_protect_cleanup
    fclose (file);
  end_unwind_protect
endfunction

function write_environment (path, results)
  file = open_new (path);
  unwind_protect
    fprintf (file, "schema=%s\n", results.schema);
    fprintf (file, "profile=%s\n", results.profile);
    fprintf (file, "family=%s\n", results.family);
    fprintf (file, "status=%s\n", results.status);
    fprintf (file, "rows=%d\n", numel (results.rows));
    fprintf (file, "evaluation_bits=%d\n", results.evaluation_bits);
    fprintf (file, "reference_low_bits=%d\n", min (results.work_precisions));
    fprintf (file, "octave_version=%s\n", version ());
    fprintf (file, "architecture=%s\n", computer ());
    fprintf (file, "working_directory=%s\n", pwd ());
    fprintf (file, "mpbits_after=%s\n", scalar_text (mpbits ()));
  unwind_protect_cleanup
    fclose (file);
  end_unwind_protect
endfunction

function write_report (path, results, paths)
  file = open_new (path);
  unwind_protect
    fprintf (file, "# NEIG result bundle\n\n");
    fprintf (file, "- Status: **%s**\n", results.status);
    fprintf (file, "- Profile: `%s`\n", results.profile);
    fprintf (file, "- Family selection: `%s`\n", results.family);
    fprintf (file, "- Rows: `%d`\n", numel (results.rows));
    fprintf (file, "- Evaluation precision: `%d` bits\n", results.evaluation_bits);
    fprintf (file, "- MP values in `eigenvalues.tsv` are serialized with `char(mp)`; no\n");
    fprintf (file, "  binary64 conversion is used for the numerical result columns.\n\n");
    fprintf (file, "Files:\n\n");
    fprintf (file, "- `summary.tsv`: one row per solver run.\n");
    fprintf (file, "- `eigenvalues.tsv`: computed/reference MP real and imaginary parts.\n");
    fprintf (file, "- `environment.txt`: execution metadata.\n");
    if (isfield (paths, "plot"))
      fprintf (file, "- `spectrum.png`: explicitly labeled visualization conversion.\n");
    endif
  unwind_protect_cleanup
    fclose (file);
  end_unwind_protect
endfunction

function file = open_new (path)
  [file, message] = fopen (path, "w");
  if (file < 0)
    error ("NEIG:WriteFile", "cannot create result file %s: %s", path, message);
  endif
endfunction

function text = scalar_text (value)
  if (ischar (value))
    text = value;
  elseif (isa (value, "mp"))
    text = char (value);
  elseif (islogical (value))
    text = ternary (value, "true", "false");
  elseif (isnumeric (value) && isscalar (value))
    if (isnan (value))
      text = "NaN";
    elseif (isinf (value))
      text = ternary (value > 0, "Inf", "-Inf");
    else
      text = sprintf ("%.17g", value);
    endif
  else
    error ("NEIG:WriteScalar", "result contains a non-scalar output value");
  endif
  text = strrep (text, sprintf ("\t"), " ");
  text = strrep (text, sprintf ("\n"), " ");
endfunction

function answer = ternary (condition, if_true, if_false)
  if (condition), answer = if_true; else, answer = if_false; endif
endfunction
