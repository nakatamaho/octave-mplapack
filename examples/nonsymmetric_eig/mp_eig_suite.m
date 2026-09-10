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
  if (! strcmp (options.family, "hadamard"))
    error ("NEIG:DeferredFamily", ...
           "this family is not implemented yet; no family was silently skipped");
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
  reference = nes_reference ("hadamard", selected, q);
  model = nes_build ("hadamard", selected, q).A;
  rows_out = struct ([]);
  ok = true;
  for mode_index = 1:2
    mode = {"balance", "nobalance"}{mode_index};
    native_row = nes_hadamard_run (selected, 53, mode, model, reference, true);
    rows_out(end + 1) = native_row;
    for precision_index = 1:numel (work_precisions)
      work_bits = work_precisions(precision_index);
      row = nes_hadamard_run (selected, work_bits, mode, model, reference, false);
      rows_out(end + 1) = row;
      if (strcmp (row.solver_status, "error") ...
          || ! strcmp (row.reference_status, "analytic_exact") ...
          || row.right_residual > residual_tolerance (selected.n, work_bits, q) ...
          || row.left_residual > residual_tolerance (selected.n, work_bits, q))
        ok = false;
      endif
      if (strcmp (profile, "smoke") && work_bits == 256
          && row.absolute_error > negative_power_of_two (120, q))
        ok = false;
        row.accuracy_status = "failed";
        rows_out(end) = row;
      elseif (strcmp (profile, "demo") && work_bits == 256
              && row.absolute_error > negative_power_of_two (100, q))
        ok = false;
        row.accuracy_status = "failed";
        rows_out(end) = row;
      elseif (strcmp (profile, "demo") && work_bits == 512
              && row.absolute_error > negative_power_of_two (300, q))
        ok = false;
        row.accuracy_status = "failed";
        rows_out(end) = row;
      endif
      if (strcmp (profile, "demo") && work_bits == 512
          && row.condition_disagreement > negative_power_of_two (80, q))
        ok = false;
      endif
    endfor
  endfor
  results = struct ("schema", "neig-v1", "profile", profile, ...
                    "family", options.family, "options", options, ...
                    "cases", selected, "work_precisions", work_precisions, ...
                    "q0", q0, "evaluation_bits", q, "rows", rows_out, ...
                    "ok", ok, "status", ternary (ok, "PASS", "FAIL"));
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
