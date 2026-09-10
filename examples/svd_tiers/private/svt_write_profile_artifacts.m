## SPDX-License-Identifier: BSD-2-Clause

function artifacts = svt_write_profile_artifacts (results, profile_data, output_dir)
  ## Write the versioned, exact-evidence result bundle. Numeric display columns
  ## are conveniences; certificates and factor snapshots remain exact V4 data.
  if (exist (output_dir, "file") == 2 || exist (output_dir, "dir") != 7)
    error ("mplapack:svt:OutputDirectoryExists", ...
           "artifact writer requires a newly created output directory");
  endif
  directory_entries = dir (output_dir);
  entry_names = {directory_entries.name};
  entry_names = entry_names(! strcmp (entry_names, ".") ...
                            & ! strcmp (entry_names, ".."));
  if (! isempty (entry_names))
    error ("mplapack:svt:OutputDirectoryExists", ...
           "artifact writer refuses a nonempty output directory");
  endif
  q = profile_data.evaluation_bits;
  if (results.plot)
    plots_dir = fullfile (output_dir, "plots");
    if (! mkdir (plots_dir))
      error ("mplapack:svt:PlotDirectory", "could not create plots directory");
    endif
    svt_write_plots (results.rows, plots_dir);
  endif

  write_summary_tsv (fullfile (output_dir, "summary.tsv"), results);
  write_values_tsv (fullfile (output_dir, "singular-values.tsv"), results.rows);
  write_verification_tsv (fullfile (output_dir, "verification.tsv"), results.certificates);

  safe_certificates = cell (numel (results.certificates), 1);
  for index = 1:numel (results.certificates)
    safe_certificates{index} = svt_json_safe (results.certificates{index}, q);
  endfor
  write_json (fullfile (output_dir, "certificates.json"), ...
              struct ("schema", "svt-v1", "profile", results.profile, ...
                     "certificates", {safe_certificates}));

  safe_rows = cell (numel (results.rows), 1);
  for index = 1:numel (results.rows)
    row = results.rows{index};
    summary = struct ("schema", row.schema, "case_id", row.case_id, ...
                      "tier", row.tier, "family", row.family, ...
                      "mode", row.mode, "native", row.native, ...
                      "precision_role", row.precision_role, ...
                      "work_bits", row.work_bits, ...
                      "input_shape", row.input_shape, ...
                      "input_precision_bits", row.input_precision_bits, ...
                      "evaluation_bits", row.evaluation_bits, ...
                      "status", row.status, "svd_seconds", row.svd_seconds, ...
                      "values", svt_json_safe (row.values, row.input_precision_bits));
    if (isfield (row, "metrics"))
      summary.metrics = svt_json_safe (row.metrics, q);
    endif
    if (isfield (row, "reference_absolute_max"))
      summary.reference_absolute_max = svt_json_safe (...
          row.reference_absolute_max, q);
    endif
    safe_rows{index} = summary;
  endfor
  write_json (fullfile (output_dir, "summary.json"), ...
              struct ("schema", "svt-v1", "profile", results.profile, ...
                     "rows", {safe_rows}));

  snapshots = {};
  for index = 1:numel (results.rows)
    row = results.rows{index};
    if (! row.native && strcmp (row.mode, "econ") ...
        && row.work_bits == profile_data.work_bits(end))
      snapshots{end + 1} = struct ("schema", "svt-input-factor-record-v1", ...
                                  "case_id", row.case_id, "tier", row.tier, ...
                                  "family", row.family, "work_bits", row.work_bits, ...
                                  "evaluation_bits", q, ...
                                  "input", svt_serialize_mp_array (row.input_snapshot, row.work_bits), ...
                                  "U", svt_serialize_mp_array (row.U, row.work_bits), ...
                                  "S", svt_serialize_mp_array (row.S, row.work_bits), ...
                                  "V", svt_serialize_mp_array (row.V, row.work_bits));
    endif
  endfor
  write_json (fullfile (output_dir, "inputs-and-factors.json"), ...
              struct ("schema", "svt-v1", "profile", results.profile, ...
                     "records", {snapshots}, "replay", ...
                     "replay exact snapshots with the V4 decoder before checking certificates"));

  environment_path = fullfile (output_dir, "environment.txt");
  write_environment (environment_path, results, profile_data);
  report_path = fullfile (output_dir, "report.md");
  write_report (report_path, results);

  names = {"summary.tsv", "singular-values.tsv", "verification.tsv", ...
           "certificates.json", "summary.json", "inputs-and-factors.json", ...
           "environment.txt", "report.md"};
  if (results.plot), names{end + 1} = "plots"; endif
  artifacts = cell (numel (names), 1);
  for index = 1:numel (names)
    path_name = fullfile (output_dir, names{index});
    artifacts{index} = struct ("name", names{index}, "path", path_name, ...
                               "sha256", path_hash (path_name), ...
                               "bytes", path_bytes (path_name));
  endfor
endfunction

function write_summary_tsv (path_name, results)
  fid = fopen (path_name, "w");
  require_file (fid, path_name);
  fprintf (fid, "case_id\ttier\tfamily\tmode\tnative\twork_bits\tshape\tinput_bits\tstatus\tseconds\n");
  for index = 1:numel (results.rows)
    row = results.rows{index};
    shape = sprintf ("%dx%d", row.input_shape(1), row.input_shape(2));
    fprintf (fid, "%s\t%s\t%s\t%s\t%d\t%d\t%s\t%d\t%s\t%.9g\n", ...
             row.case_id, row.tier, row.family, row.mode, row.native, ...
             row.work_bits, shape, row.input_precision_bits, row.status, ...
             row.svd_seconds);
  endfor
  fclose (fid);
endfunction

function write_values_tsv (path_name, rows)
  fid = fopen (path_name, "w");
  require_file (fid, path_name);
  fprintf (fid, "case_id\tmode\tnative\twork_bits\tindex\tvalue\n");
  for row_index = 1:numel (rows)
    row = rows{row_index};
    for value_index = 1:numel (row.values)
      fprintf (fid, "%s\t%s\t%d\t%d\t%d\t%s\n", row.case_id, row.mode, ...
               row.native, row.work_bits, value_index, display_value (row.values(value_index)));
    endfor
  endfor
  fclose (fid);
endfunction

function write_verification_tsv (path_name, jobs)
  fid = fopen (path_name, "w");
  require_file (fid, path_name);
  fprintf (fid, "case_id\ttier\tmethod\tstatus\tgate_ok\tmeets_accuracy_target\tnotes\n");
  for index = 1:numel (jobs)
    job = jobs{index};
    fprintf (fid, "%s\t%s\t%s\t%s\t%d\t%d\t%s\n", job.case_id, job.tier, ...
             job.method, job.status, job.gate_ok, ...
             job.certificate.meets_accuracy_target, job.notes);
  endfor
  fclose (fid);
endfunction

function write_json (path_name, value)
  fid = fopen (path_name, "w");
  require_file (fid, path_name);
  fwrite (fid, jsonencode (value));
  fwrite (fid, "\n");
  fclose (fid);
endfunction

function write_environment (path_name, results, profile_data)
  fid = fopen (path_name, "w");
  require_file (fid, path_name);
  fprintf (fid, "schema=svt-v1\nprofile=%s\ntier=%s\noctave=%s\n", ...
           results.profile, results.tier, version ());
  fprintf (fid, "work_bits=%s\nreference_bits=%s\nevaluation_bits=%d\n", ...
           vector_text (profile_data.work_bits), vector_text (profile_data.reference_bits), ...
           profile_data.evaluation_bits);
  fprintf (fid, "native_rows_are_explicit=true\nmp_numeric_evidence=exact_v4_snapshots\n");
  fprintf (fid, "paper_algorithm_reproduction=false\nmodule_resolution=source-tree src/__mplapack_core__.oct plus inst\n");
  fclose (fid);
endfunction

function write_report (path_name, results)
  fid = fopen (path_name, "w");
  require_file (fid, path_name);
  fprintf (fid, "# SVT %s artifact report\n\n", results.profile);
  fprintf (fid, "- schema: `svt-v1`\n- tier: `%s`\n- status: `%s`\n", ...
           results.tier, results.status);
  fprintf (fid, "- measured SVD rows: `%d/%d`\n- references: `%d`\n- V jobs: `%d`\n", ...
           results.measured_svd_rows, results.expected_svd_rows, ...
           results.reference_job_count, results.v_job_count);
  fprintf (fid, "- `plot=false` execution is headless and produces no plots.\n\n");
  fprintf (fid, "All values in `certificates.json` and `inputs-and-factors.json` are exact MPFR/MPC V4 snapshots; TSV values are display fields.\n\n");
  fprintf (fid, "## Verification jobs\n\n| Case | Tier | Method | Status | Gate | Target |\n|---|---|---|---|---:|---:|\n");
  for index = 1:numel (results.certificates)
    job = results.certificates{index};
    fprintf (fid, "| %s | %s | `%s` | `%s` | %d | %d |\n", job.case_id, ...
             job.tier, job.method, job.status, job.gate_ok, ...
             job.certificate.meets_accuracy_target);
  endfor
  fclose (fid);
endfunction

function svt_write_plots (rows, plots_dir)
  ## Presentation-only conversion; no plotted value is fed back to a gate.
  try
    figure ("visible", "off");
    hold on;
    for index = 1:numel (rows)
      row = rows{index};
      if (! row.native && strcmp (row.mode, "values"))
        semilogy (1:numel (row.values), double (row.values), ".-");
      endif
    endfor
    hold off;
    print (fullfile (plots_dir, "singular-values.png"), "-dpng");
    close all;
  catch exception
    close all;
    error ("mplapack:svt:PlotFailure", "presentation plot failed: %s", exception.message);
  end_try_catch
endfunction

function text = display_value (value)
  if (isa (value, "mp")), text = char (value); else, text = sprintf ("%.17g", value); endif
endfunction

function text = vector_text (value)
  text = "";
  for index = 1:numel (value)
    if (index > 1)
      text = [text, ","];
    endif
    entry = value(index);
    entry = double (entry);
    formatted = sprintf ("%d", entry);
    text = [text, formatted];
  endfor
endfunction

function require_file (fid, path_name)
  if (fid < 0), error ("mplapack:svt:ArtifactWrite", "cannot write %s", path_name); endif
endfunction

function digest = path_hash (path_name)
  digest = hash ("sha256", fileread (path_name));
endfunction

function bytes = path_bytes (path_name)
  info = dir (path_name);
  if (isempty (info)), bytes = 0; else, bytes = info.bytes; endif
endfunction
