## -*- texinfo -*-
## @deftypefn {} {@var{result} =} mp_neig_tiers (@var{profile})
## @deftypefnx {} {@var{result} =} mp_neig_tiers (@var{profile}, @var{options})
## Run the repository-local NEIGT ordinary Tier-S or Tier-A eigensystem suite.
## @var{profile} is @code{"smoke"} or @code{"demo"}; @var{options.tier}
## selects @code{"S"}, @code{"A"}, or @code{"all"}.  The measured rows use
## the existing public @code{mp}, @code{mpbits}, and @code{eig} interfaces.
## MP rows keep their exact model, frozen input, work precision, and returned
## eigentriples distinct; native rows are explicit binary64 controls.  An
## @code{"all"} result reports @code{NUMERICS_ONLY_COMPLETE} until verification
## jobs are run by @code{mp_neig_verify_examples}.
## @end deftypefn
function result = mp_neig_tiers (profile, options)
  if (nargin < 1 || nargin > 2)
    error ("mplapack:neigt:Arguments", ...
           "mp_neig_tiers expects a profile and optional options");
  endif
  if (nargin == 1)
    options = struct ();
  endif
  helper_root = fileparts (mfilename ("fullpath"));
  private_root = fullfile (helper_root, "private");
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), private_root)))
    addpath (private_root);
    added = true;
  endif
  saved_bits = mpbits ();
  unwind_protect
    opts = net_options (profile, options);
    bundle = net_manifest ();
    profile_data = bundle.cases.profiles.(opts.profile);
    selected = select_cases (profile_data.cases, opts.tier);
    expected_rows = 2 * numel (selected) * (numel (profile_data.work_bits) + 1);
    if (any (strcmp (opts.tier, {"V-S", "V-A", "V"})))
      selected = selected([]);
      expected_rows = 0;
    endif
    rows_out = cell (0, 1);
    references = cell (numel (selected), 1);
    native_models = cell (numel (selected), 1);
    numerical_ok = true;
    reference_ok = true;
    max_work = max (profile_data.work_bits);
    for case_index = 1:numel (selected)
      entry = selected(case_index);
      native_models{case_index} = net_case_model (entry, max_work);
      references{case_index} = net_case_reference ...
        (entry, profile_data.reference_bits(1), profile_data.reference_bits(2));
      reference_ok = reference_ok && reference_is_valid (references{case_index});
      modes = {"nobalance", "balance"};
      for mode_index = 1:2
        mode = modes{mode_index};
        native_row = run_native_row (entry, native_models{case_index}, mode);
        rows_out{end + 1} = native_row;
        numerical_ok = numerical_ok && native_row.complete;
        for work_index = 1:numel (profile_data.work_bits)
          work_bits = profile_data.work_bits(work_index);
          row = run_mp_row (entry, work_bits, mode, references{case_index}, ...
                            profile_data.reference_bits(2), ...
                            profile_data.evaluation_bits, max_work);
          rows_out{end + 1} = row;
          numerical_ok = numerical_ok && row.complete && row.gate_pass;
        endfor
      endfor
    endfor
    expected_all = profile_data.expected_case_count;
    expected_all_rows = profile_data.expected_measured_eig_rows;
    ordinary_complete = (numel (rows_out) == expected_rows) && numerical_ok ...
      && reference_ok;
    if (strcmp (opts.tier, "all"))
      status = ternary (ordinary_complete, "NUMERICS_ONLY_COMPLETE", ...
                        "NUMERICS_INCOMPLETE");
      ok = false;
      scope_ok = true;
    elseif (any (strcmp (opts.tier, {"S", "A"})))
      status = ternary (ordinary_complete, "NUMERICS_COMPLETE", ...
                        "NUMERICS_INCOMPLETE");
      ok = ordinary_complete;
      scope_ok = true;
    else
      status = "NOT_APPLICABLE";
      ok = false;
      scope_ok = true;
    endif
    coverage = struct ("case_count", numel (selected), ...
      "measured_eig_rows", numel (rows_out), ...
      "expected_selected_case_count", numel (selected), ...
      "expected_selected_measured_eig_rows", expected_rows, ...
      "expected_all_case_count", expected_all, ...
      "expected_all_measured_eig_rows", expected_all_rows, ...
      "ordinary_cases_implemented", true, ...
      "ordinary_complete", ordinary_complete, ...
      "numerics_only_complete", ordinary_complete, ...
      "native_rows", 2 * numel (selected), ...
      "mp_rows", 2 * numel (selected) * numel (profile_data.work_bits));
    result = struct ("schema", "neigt-v1", "profile", opts.profile, ...
      "tier", opts.tier, "status", status, "ok", ok, ...
      "scope_ok", scope_ok, "rows", {rows_out}, ...
      "references", {references}, "coverage", coverage, ...
      "manifest", struct ("cases", bundle.cases_path, ...
                           "verification_jobs", bundle.jobs_path), ...
      "options", opts, "environment", environment_record (), ...
      "verification_status", "NOT_IMPLEMENTED", ...
      "source", "NEIGT12_ORDINARY_PROFILE_RUNNER");
    if (! isempty (opts.output_dir))
      write_profile_outputs (result, opts.output_dir);
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

function selected = select_cases (cases, tier)
  if (strcmp (tier, "all"))
    selected = cases;
    return;
  endif
  if (! any (strcmp (tier, {"S", "A"})))
    selected = cases([]);
    return;
  endif
  keep = false (numel (cases), 1);
  for index = 1:numel (cases)
    keep(index) = strcmp (cases(index).tier, tier);
  endfor
  selected = cases(keep);
endfunction

function row = run_native_row (entry, model, mode)
  row = base_row (entry.id, mode, "native64", 53);
  row.input_status = "native_once_rounded_model";
  row.input_hash = net_raw_hash (model.native_A, "native_A");
  try
    started = tic ();
    [V, D, W] = eig (model.native_A, mode);
    elapsed = toc (started);
    row.complete = true;
    row.gate_pass = true;
    row.status = "MEASURED";
    row.elapsed_seconds = elapsed;
    row.raw_V = V;
    row.raw_D = D;
    row.raw_W = W;
    row.raw_V_hash = net_raw_hash (V, "native_V");
    row.raw_D_hash = net_raw_hash (D, "native_D");
    row.raw_W_hash = net_raw_hash (W, "native_W");
  catch exception
    row.status = "FAILED_NATIVE_SOLVER";
    row.error_identifier = exception.identifier;
    row.error_message = exception.message;
    row.complete = false;
    row.gate_pass = false;
  end_try_catch
endfunction

function row = run_mp_row (entry, work_bits, mode, reference, reference_bits, q, ...
                           highest_work_bits)
  row = base_row (entry.id, mode, sprintf ("mp%d", work_bits), work_bits);
  row.input_status = "exact_model_at_work_precision";
  saved_bits = mpbits ();
  unwind_protect
    try
    mpbits (work_bits);
    model = net_case_model (entry, work_bits);
    row.input_status = model.input_status;
    row.model_hash = net_raw_hash (net_widen (model.A_model, q, work_bits), ...
                                    "A_model");
    row.input_hash = net_raw_hash (net_widen (model.A_frozen, q, work_bits), ...
                                   "A_frozen");
    started = tic ();
    [V, D, W] = eig (model.A_frozen, mode);
    row.elapsed_seconds = toc (started);
    Vq = net_widen (V, q, work_bits);
    Dq = net_widen (D, q, work_bits);
    Wq = net_widen (W, q, work_bits);
    Aq = net_widen (model.A_frozen, q, work_bits);
    reference_q = net_widen (reference.values, q, reference_bits);
    metrics = net_metrics (Aq, Vq, Dq, Wq, reference_q);
    row.complete = true;
    row.status = "MEASURED";
    row.raw_V = V;
    row.raw_D = D;
    row.raw_W = W;
    row.raw_V_hash = net_raw_hash (Vq, "raw_V_q");
    row.raw_D_hash = net_raw_hash (Dq, "raw_D_q");
    row.raw_W_hash = net_raw_hash (Wq, "raw_W_q");
    row.values = metrics.values;
    row.metrics = metrics;
    row.reference_status = reference.status;
    row.reference_source = reference.source;
    row.reference_bits = reference_bits;
    row.gate = ordinary_gate (entry, work_bits, metrics, Aq, q, ...
                              highest_work_bits, reference_q);
    row.gate_pass = row.gate.pass;
    catch exception
    row.complete = false;
    row.gate_pass = false;
    row.status = "FAILED_MP_SOLVER_OR_METRICS";
    row.error_identifier = exception.identifier;
    row.error_message = exception.message;
  end_try_catch
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function row = base_row (case_id, mode, work_role, work_bits)
  row = struct ("case_id", case_id, "mode", mode, "work_role", work_role, ...
    "work_bits", work_bits, "status", "NOT_RUN", "complete", false, ...
    "gate_pass", false, "elapsed_seconds", NaN, "input_status", "", ...
    "input_hash", "", "model_hash", "", "raw_V_hash", "", ...
    "raw_D_hash", "", "raw_W_hash", "", "error_identifier", "", ...
    "error_message", "", "raw_V", [], "raw_D", [], "raw_W", []);
endfunction

function gate = ordinary_gate (entry, work_bits, metrics, A, q, ...
                               highest_work_bits, reference_q)
  case_id = entry.id;
  n = rows (A);
  scale = max (mp (1), norm (A, "fro"));
  normalized_error = metrics.absolute_match.threshold / scale;
  target_exponent = -80;
  if (highest_work_bits < work_bits)
    error ("mplapack:neigt:Gate", "work precision exceeds profile maximum");
  endif
  if (work_bits < highest_work_bits)
    gate = struct ("pass", true, "status", "NOT_APPLICABLE_LOWER_WORK", ...
      "target", mp ("NaN"), "target_exponent", NaN, ...
      "normalized_bottleneck", normalized_error, "n", n, "scale", scale, ...
      "residual_recorded", true, "method", "ordinary_lower_work_measured_v1");
    return;
  elseif (work_bits >= 512)
    target_exponent = -160;
  elseif (strcmp (case_id, "HAD_BIDIAG") || strcmp (case_id, "HAD_COMPLEX") ...
          || strncmp (case_id, "FORSYTHE", 8))
    target_exponent = -120;
  endif
  target = net_pow2 (target_exponent, q);
  pass = normalized_error <= target;
  nonzero_normalized_bottleneck = mp ("NaN");
  zero_target = mp ("NaN");
  zero_exponent = NaN;
  nonzero_target = mp ("NaN");
  if (strcmp (case_id, "MKS"))
    % The MKS reference deliberately contains a repeated defective zero.
    % Apply the conservative defective-root boundary to the zero subset,
    % while retaining the simple-root boundary for its nonzero subset.
    p = entry.parameters;
    kmax = floor ((n - 1) / p.m) + 1;
    zero_exponent = -floor (work_bits / (4 * kmax));
    zero_target = net_pow2 (zero_exponent, q);
    nonzero_target = target;
    mapping = metrics.absolute_match.mapping;
    nonzero_normalized_bottleneck = mp (0);
    for index = 1:numel (mapping)
      ref_index = mapping(index);
      if (reference_q(ref_index) != mp (0))
        denominator = abs (reference_q(ref_index));
        if (denominator < mp (1))
          denominator = mp (1);
        endif
        candidate = metrics.absolute_match.costs(index, ref_index) ...
                    / denominator;
        if (candidate > nonzero_normalized_bottleneck)
          nonzero_normalized_bottleneck = candidate;
        endif
      endif
    endfor
    pass = (normalized_error <= zero_target) ...
           && (nonzero_normalized_bottleneck <= nonzero_target);
  endif
  if (any (strcmp (case_id, {"FRANK0", "FRANK1"})))
    pass = pass && ! strcmp (metrics.relative_match.status, ...
                             "undefined_zero_reference") ...
      && metrics.relative_match.threshold <= target;
  endif
  gate = struct ("pass", pass, "status", ternary (pass, "PASS", "FAIL"), ...
    "target", target, ...
    "target_exponent", target_exponent, "normalized_bottleneck", ...
    normalized_error, "n", n, "scale", scale, ...
    "residual_recorded", true, "method", ternary (strcmp (case_id, "MKS"), ...
    "ordinary_mks_split_threshold_v1", "ordinary_fixed_threshold_v1"), ...
    "zero_target", zero_target, "zero_target_exponent", ternary ...
    (strcmp (case_id, "MKS"), zero_exponent, NaN), ...
    "nonzero_target", nonzero_target, ...
    "nonzero_normalized_bottleneck", nonzero_normalized_bottleneck);
endfunction

function value = reference_is_valid (reference)
  value = isstruct (reference) && isfield (reference, "values") ...
    && isfield (reference, "status") && isfield (reference, "source") ...
    && all (isfinite (reference.values));
endfunction

function value = ternary (condition, true_value, false_value)
  if (condition)
    value = true_value;
  else
    value = false_value;
  endif
endfunction

function result = environment_record ()
  path_parts = strsplit (path (), pathsep);
  result = struct ("octave_version", version (), "architecture", computer (), ...
    "mpbits", mpbits (), "cwd", pwd (), "path_head", path_parts{1});
endfunction

function write_profile_outputs (result, output_dir)
  if (exist (output_dir, "dir") != 7)
    [created, message] = mkdir (output_dir);
    if (! created)
      error ("mplapack:neigt:Output", "cannot create output directory: %s", message);
    endif
  endif
  target = fullfile (output_dir, sprintf ("neigt-%s-rows.tsv", result.profile));
  handle = fopen (target, "w");
  if (handle < 0)
    error ("mplapack:neigt:Output", "cannot open profile output");
  endif
  unwind_protect
    fprintf (handle, "case_id\tmode\twork_role\tstatus\tgate\telapsed_seconds\n");
    for index = 1:numel (result.rows)
      row = result.rows{index};
      fprintf (handle, "%s\t%s\t%s\t%s\t%d\t%.9g\n", row.case_id, ...
               row.mode, row.work_role, row.status, row.gate_pass, ...
               row.elapsed_seconds);
    endfor
  unwind_protect_cleanup
    fclose (handle);
  end_unwind_protect
endfunction
