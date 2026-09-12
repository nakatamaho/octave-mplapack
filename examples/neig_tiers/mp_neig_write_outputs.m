## -*- texinfo -*-
## @deftypefn {} {@var{result} =} mp_neig_write_outputs (@var{profile}, @var{output_dir})
## @deftypefnx {} {@var{result} =} mp_neig_write_outputs (@var{profile}, @var{output_dir}, @var{options})
## Write a new, non-overwriting NEIGT result directory.
##
## The directory contains an ordinary measured-row TSV, execution metadata,
## a Markdown report, and a hash-bound exact MP V-S1 proof record.  The proof
## record stores the measured inputs and certificate data separately from the
## result summary and can be checked with @code{mp_neig_replay}.  No binary64
## conversion is used for the proof artifact.  @var{options} accepts the
## ordinary @code{tier} and @code{plot} fields; plotting is presentation-only
## and is recorded as not run when false.
## @end deftypefn
function result = mp_neig_write_outputs (profile, output_dir, options)
  if (nargin < 2 || nargin > 3 || ! ischar (output_dir) ...
      || isempty (output_dir) || rows (output_dir) != 1)
    error ("mplapack:neigt:Output", "a new output directory is required");
  endif
  if (exist (output_dir, "file") || exist (output_dir, "dir"))
    error ("mplapack:neigt:OutputExists", ...
           "refusing to write an existing output path: %s", output_dir);
  endif
  if (nargin < 3 || isempty (options))
    options = struct ("tier", "all", "plot", false);
  endif
  if (! isstruct (options) || ! isscalar (options))
    error ("mplapack:neigt:Output", "options must be a scalar struct");
  endif
  if (! isfield (options, "tier")), options.tier = "all"; endif
  if (! isfield (options, "plot")), options.plot = false; endif
  if (! ischar (options.tier) || ! islogical (options.plot) ...
      || ! isscalar (options.plot))
    error ("mplapack:neigt:Output", "invalid output options");
  endif
  if (! any (strcmp (options.tier, {"all", "S", "A"})))
    error ("mplapack:neigt:Output", "output tier must be all, S, or A");
  endif

  helper_root = fileparts (mfilename ("fullpath"));
  private_root = fullfile (helper_root, "private");
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), private_root)))
    addpath (private_root);
    added = true;
  endif
  [created, message] = mkdir (output_dir);
  if (! created)
    error ("mplapack:neigt:Output", "cannot create output directory: %s", message);
  endif
  saved_bits = mpbits ();
  unwind_protect
    ordinary = mp_neig_tiers (profile, struct ("tier", options.tier));
    proof = net_neigt_capture_s1 (profile, "VS1-01");
    proof_file = fullfile (output_dir, "proof-vs1-01.json");
    proof_hash = net_neigt_json_write (proof, proof_file);
    rows_file = fullfile (output_dir, "rows.tsv");
    write_rows (rows_file, ordinary);
    environment_file = fullfile (output_dir, "environment.txt");
    write_environment (environment_file, ordinary, proof_hash, options);
    report_file = fullfile (output_dir, "report.md");
    write_report (report_file, ordinary, proof, proof_hash, options);
    manifest_file = fullfile (output_dir, "manifest.tsv");
    write_manifest (manifest_file, rows_file, environment_file, report_file, ...
                   proof_file, proof_hash);
    result = struct ("schema", "neigt-output-v1", "profile", profile, ...
      "tier", options.tier, "status", "COMPLETE", "ok", ordinary.coverage.ordinary_complete, ...
      "ordinary", ordinary, "proof", proof, "proof_hash", proof_hash, ...
      "replay", mp_neig_replay (proof_file), ...
      "output", struct ("rows", rows_file, "environment", environment_file, ...
                         "report", report_file, "manifest", manifest_file, ...
                         "proof", proof_file));
    if (! result.replay.ok)
      error ("mplapack:neigt:Output", "fresh proof replay did not pass");
    endif
    if (added)
      rmpath (private_root);
    endif
  unwind_protect_cleanup
    mpbits (saved_bits);
    if (added && any (strcmp (strsplit (path (), pathsep), private_root)))
      rmpath (private_root);
    endif
  end_unwind_protect
endfunction

function write_rows (filename, result)
  handle = fopen (filename, "w");
  if (handle < 0), error ("mplapack:neigt:Output", "cannot open rows TSV"); endif
  unwind_protect
    fprintf (handle, "case_id\tmode\twork_role\twork_bits\tstatus\tgate_pass\telapsed_seconds\tinput_hash\tmodel_hash\traw_V_hash\traw_D_hash\traw_W_hash\n");
    for index = 1:numel (result.rows)
      row = result.rows{index};
      fprintf (handle, "%s\t%s\t%s\t%d\t%s\t%d\t%.17g\t%s\t%s\t%s\t%s\t%s\n", ...
               row.case_id, row.mode, row.work_role, row.work_bits, row.status, ...
               row.gate_pass, row.elapsed_seconds, row.input_hash, row.model_hash, ...
               row.raw_V_hash, row.raw_D_hash, row.raw_W_hash);
    endfor
  unwind_protect_cleanup
    fclose (handle);
  end_unwind_protect
endfunction

function write_environment (filename, ordinary, proof_hash, options)
  handle = fopen (filename, "w");
  if (handle < 0), error ("mplapack:neigt:Output", "cannot open environment"); endif
  unwind_protect
    fprintf (handle, "schema=neigt-output-v1\nprofile=%s\ntier=%s\n", ...
             ordinary.profile, options.tier);
    fprintf (handle, "ordinary_status=%s\nordinary_rows=%d\n", ...
             ordinary.status, numel (ordinary.rows));
    fprintf (handle, "octave_version=%s\narchitecture=%s\nworking_directory=%s\n", ...
             version (), computer (), pwd ());
    fprintf (handle, "evaluation_default_bits=%d\nproof_sha256=%s\n", ...
             mpbits (), proof_hash);
    fprintf (handle, "plot=%s\nplot_status=NOT_RUN\n", ...
             ternary (options.plot, "true", "false"));
  unwind_protect_cleanup
    fclose (handle);
  end_unwind_protect
endfunction

function write_report (filename, ordinary, proof, proof_hash, options)
  handle = fopen (filename, "w");
  if (handle < 0), error ("mplapack:neigt:Output", "cannot open output report"); endif
  unwind_protect
    fprintf (handle, "# NEIGT output bundle\n\n");
    fprintf (handle, "- Schema: `neigt-output-v1`\n- Profile: `%s`\n", ordinary.profile);
    fprintf (handle, "- Tier: `%s`\n- Status: **%s**\n", options.tier, ordinary.status);
    fprintf (handle, "- Ordinary measured rows: `%d`\n", numel (ordinary.rows));
    fprintf (handle, "- Exact proof: `proof-vs1-01.json`\n");
    fprintf (handle, "- Proof SHA256: `%s`\n", proof_hash);
    fprintf (handle, "- Proof method: `%s`\n", proof.method_version);
    fprintf (handle, "- Replay command: `mp_neig_replay (""proof-vs1-01.json"")`\n");
    fprintf (handle, "- Replay policy: no `eig`, no ideal-model reconstruction, MP-only proof inputs.\n");
    fprintf (handle, "- Plot status: **NOT_RUN** (plot=false; display conversion is not numerical evidence).\n\n");
    fprintf (handle, "Files:\n\n- `rows.tsv`\n- `manifest.tsv`\n- `environment.txt`\n- `proof-vs1-01.json`\n- `report.md`\n");
  unwind_protect_cleanup
    fclose (handle);
  end_unwind_protect
endfunction

function write_manifest (filename, rows_file, environment_file, report_file, proof_file, proof_hash)
  handle = fopen (filename, "w");
  if (handle < 0), error ("mplapack:neigt:Output", "cannot open output manifest"); endif
  unwind_protect
    fprintf (handle, "schema\tfile\tsha256\tsize_bytes\n");
    entries = {rows_file, environment_file, report_file, proof_file};
    labels = {"rows", "environment", "report", "proof"};
    for index = 1:numel (entries)
      data = fileread (entries{index});
      digest = hash ("sha256", data);
      if (strcmp (labels{index}, "proof")), digest = proof_hash; endif
      info = dir (entries{index});
      fprintf (handle, "neigt-output-v1\t%s\t%s\t%d\n", ...
               labels{index}, digest, info.bytes);
    endfor
  unwind_protect_cleanup
    fclose (handle);
  end_unwind_protect
endfunction

function result = ternary (condition, if_true, if_false)
  if (condition), result = if_true; else, result = if_false; endif
endfunction
