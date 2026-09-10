% Entry point for the repository-local difficult nonsymmetric eigensystem suite.
function results = mp_eig_suite (profile, options)
  if (nargin < 1)
    profile = "smoke";
  endif
  if (nargin > 2)
    error ("NEIG:Arguments", "mp_eig_suite accepts a profile and optional options");
  endif
  if (! ischar (profile) || rows (profile) != 1)
    error ("NEIG:Profile", "profile must be a character row");
  endif
  if (! any (strcmp (profile, {"smoke", "demo", "stress"})))
    error ("NEIG:Profile", "profile must be smoke, demo, or stress");
  endif

  defaults = struct ("output_dir", '', "plot", false, "family", "all");
  if (nargin == 1)
    options = defaults;
  elseif (! isstruct (options) || ! isscalar (options))
    error ("NEIG:Options", "options must be a scalar struct");
  else
    names = fieldnames (options);
    for k = 1:numel (names)
      if (! isfield (defaults, names{k}))
        error ("NEIG:Options", "unknown option name: %s", names{k});
      endif
    endfor
    options = merge_options (defaults, options);
  endif
  if (! (ischar (options.output_dir)
         && (isempty (options.output_dir) || rows (options.output_dir) == 1)))
    error ("NEIG:Options", "output_dir must be a character row");
  endif
  if (! (islogical (options.plot) && isscalar (options.plot)))
    error ("NEIG:Options", "plot must be a logical scalar");
  endif
  if (! ischar (options.family) || rows (options.family) != 1)
    error ("NEIG:Options", "family must be a character row");
  endif
  if (! any (strcmp (options.family, {"all", "hadamard", "frank", ...
                                     "companion", "forsythe"})))
    error ("NEIG:Options", "unknown family: %s", options.family);
  endif
  selected = nes_cases (profile, options.family);
  if (strcmp (profile, "smoke"))
    work_precisions = [128, 256];
  elseif (strcmp (profile, "demo"))
    work_precisions = [128, 256, 512];
  else
    work_precisions = [256, 512, 1024, 2048];
  endif
  pmax = max (work_precisions);
  q0 = max (512, pmax + 128);
  q = q0 + 128;
  rows_out = struct ([]);
  ok = true;
  for case_index = 1:numel (selected)
    parameters = selected(case_index);
    reference = nes_reference (parameters.family, parameters, q, q0);
    model = nes_build (parameters.family, parameters, q).A;
    for mode_index = 1:2
      mode = {"balance", "nobalance"}{mode_index};
      native_row = run_case (parameters, 53, mode, model, reference, true);
      native_row = normalize_row (native_row);
      rows_out(end + 1) = native_row;
      for precision_index = 1:numel (work_precisions)
        work_bits = work_precisions(precision_index);
        row = run_case (parameters, work_bits, mode, model, reference, false);
        row = normalize_row (row);
        rows_out(end + 1) = row;
        [row_ok, row] = check_row (row, profile, work_bits, q);
        if (! row_ok)
          ok = false;
        endif
        rows_out(end) = row;
      endfor
    endfor
  endfor
  results = struct ("schema", "neig-v1", "profile", profile, ...
                    "family", options.family, "options", options, ...
                    "cases", selected, "work_precisions", work_precisions, ...
                    "q0", q0, "evaluation_bits", q, "rows", rows_out, ...
                    "ok", ok, "status", ternary (ok, "PASS", "FAIL"));
  if (! isempty (options.output_dir))
    results.output = nes_write (results, options.output_dir);
  else
    results.output = struct ("summary", "", "eigenvalues", "", ...
                             "environment", "", "report", "");
  endif
endfunction

function row = normalize_row (row)
  common = struct ("schema", "neig-v1", "family", "", "representation", ...
                   "", "n", NaN, "a", NaN, "s", NaN, "backend", "", ...
                   "work_bits", NaN, "evaluation_bits", NaN, ...
                   "reference_bits", NaN, "low_reference_bits", NaN, ...
                   "reference_agreement", mp ("NaN"), ...
                   "reference_agreement_limit", mp ("NaN"), "mode", "", ...
                   "input_precision", "", "native", false, ...
                   "native_underflow", false, "minimum_coefficient_bits", NaN, ...
                   "solver_status", "", "solver_error", "", ...
                   "solver_time", NaN, "input_error", mp ("NaN"), ...
                   "input_error_relative", mp ("NaN"), ...
                   "accuracy_status", "", "reference_status", "", ...
                   "condition_status", "", "max_imaginary", mp ("NaN"), ...
                   "absolute_error", mp ("NaN"), "relative_error", mp ("NaN"), ...
                   "circle_error", mp ("NaN"), "right_residual", mp ("NaN"), ...
                   "left_residual", mp ("NaN"), ...
                   "right_column_residual", mp ("NaN"), ...
                   "left_column_residual", mp ("NaN"), ...
                   "condition_estimates", mp ("NaN"), ...
                   "vector_condition", mp ("NaN"), ...
                   "condition_disagreement", mp ("NaN"), ...
                   "absolute_mapping", [], "relative_mapping", [], ...
                   "circle_mapping", [], "computed_values", [], ...
                   "reference_values", []);
  names = fieldnames (common);
  for k = 1:numel (names)
    if (isfield (row, names{k}))
      common.(names{k}) = row.(names{k});
    endif
  endfor
  row = common;
endfunction

function row = run_case (parameters, work_bits, mode, model, reference, native)
  switch parameters.family
    case "hadamard"
      row = nes_hadamard_run (parameters, work_bits, mode, model, reference, native);
    case "frank"
      row = nes_frank_run (parameters, work_bits, mode, model, reference, native);
    case "companion"
      row = nes_companion_run (parameters, work_bits, mode, model, reference, native);
    case "forsythe"
      row = nes_forsythe_run (parameters, work_bits, mode, model, reference, native);
    otherwise
      error ("NEIG:Family", "unsupported family: %s", parameters.family);
  endswitch
endfunction

function [ok, row] = check_row (row, profile, work_bits, q)
  ok = true;
  if (strcmp (row.solver_status, "error") ...
      || strcmp (row.reference_status, "unresolved") ...
      || row.right_residual > residual_tolerance (row.n, work_bits, q) ...
      || row.left_residual > residual_tolerance (row.n, work_bits, q))
    ok = false;
  endif
  target = mp ("NaN");
  metric_name = "absolute_error";
  family = row.family;
  if (strcmp (family, "hadamard"))
    if (strcmp (profile, "smoke") && work_bits == 256)
      target = negative_power_of_two (120, q);
    elseif (strcmp (profile, "demo") && work_bits == 256)
      target = negative_power_of_two (100, q);
    elseif (strcmp (profile, "demo") && work_bits == 512)
      target = negative_power_of_two (300, q);
    endif
    if (strcmp (profile, "demo") && work_bits == 512
        && row.condition_disagreement > negative_power_of_two (80, q))
      ok = false;
    endif
  elseif (strcmp (family, "frank"))
    metric_name = "relative_error";
    if (strcmp (profile, "smoke") && work_bits == 256)
      target = negative_power_of_two (120, q);
    elseif (strcmp (profile, "demo") && work_bits == 512)
      target = negative_power_of_two (200, q);
    endif
  elseif (strcmp (family, "companion"))
    if (strcmp (profile, "smoke") && work_bits == 256)
      target = negative_power_of_two (120, q);
    elseif (strcmp (profile, "demo") && work_bits == 512)
      target = negative_power_of_two (200, q);
    endif
  elseif (strcmp (family, "forsythe"))
    if (strcmp (profile, "smoke") && work_bits == 256)
      target = negative_power_of_two (120, q);
    elseif (strcmp (profile, "demo") && work_bits == 512)
      if (strcmp (row.representation, "original"))
        target = negative_power_of_two (64, q);
      else
        target = negative_power_of_two (200, q);
      endif
    endif
    metric_name = "circle_error";
  endif
  if (! isnan (target))
    if (row.(metric_name) > target)
      ok = false;
      row.accuracy_status = "failed";
    else
      row.accuracy_status = "meets_target";
    endif
  endif
endfunction

function result = residual_tolerance (n, work_bits, q)
  result = mp ("65536") * mp (n * n) * negative_power_of_two (work_bits, q);
endfunction

function result = negative_power_of_two (exponent, bits)
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    result = mp ("1");
    half = mp ("0.5");
    for k = 1:exponent
      result = result * half;
    endfor
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function result = ternary (condition, if_true, if_false)
  if (condition), result = if_true; else, result = if_false; endif
endfunction

function result = merge_options (defaults, supplied)
  result = defaults;
  names = fieldnames (supplied);
  for k = 1:numel (names)
    result.(names{k}) = supplied.(names{k});
  endfor
endfunction
