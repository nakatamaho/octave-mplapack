## SPDX-License-Identifier: BSD-2-Clause

function results = svt_run_profile (profile_data, profile_name, tier, plot_enabled)
  ## Execute the complete measured profile and its separate reference/V jobs.
  ## Native rows are explicit comparison rows; they never feed an MP solve.
  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  selected = profile_data.cases;
  if (! strcmp (tier, "all"))
    selected = selected(strcmp ({selected.tier}, tier));
  endif
  work_bits = profile_data.work_bits;
  modes = profile_data.modes;
  expected_rows = numel (selected) * (numel (work_bits) + ...
                                     double (profile_data.native)) * numel (modes);
  rows_out = {};
  high_fixtures = cell (numel (selected), 1);
  high_econ = cell (numel (selected), 1);

  for case_index = 1:numel (selected)
    case_data = selected(case_index);
    for work_index = 1:numel (work_bits)
      bits = work_bits(work_index);
      fixture = svt_build_case (case_data, bits);
      if (work_index == numel (work_bits))
        high_fixtures{case_index} = fixture;
      endif
      for mode_index = 1:numel (modes)
        mode = char (modes{mode_index});
        measured = svt_run_svd (fixture.A, mode, profile_data.evaluation_bits);
        measured.case_id = char (case_data.id);
        measured.tier = char (case_data.tier);
        measured.family = char (case_data.family);
        measured.work_bits = bits;
        measured.precision_role = "MP";
        measured.native = false;
        measured.fixture_identity = fixture.identity;
        measured.input_snapshot = fixture.A;
        rows_out{end + 1} = measured;
        if (work_index == numel (work_bits) && strcmp (mode, "econ"))
          high_econ{case_index} = measured;
        endif
      endfor
    endfor
    if (profile_data.native)
      fixture = high_fixtures{case_index};
      for mode_index = 1:numel (modes)
        mode = char (modes{mode_index});
        native = svt_run_native_svd (fixture.A, mode);
        native.case_id = char (case_data.id);
        native.tier = char (case_data.tier);
        native.family = char (case_data.family);
        native.work_bits = 0;
        native.precision_role = "EXPLICIT_NATIVE_COMPARISON";
        native.fixture_identity = fixture.identity;
        rows_out{end + 1} = native;
      endfor
    endif
  endfor

  ## References are separate from measured rows and use the frozen represented
  ## input at each reference precision.
  references = {};
  for case_index = 1:numel (selected)
    case_data = selected(case_index);
    case_references = {};
    for reference_index = 1:numel (profile_data.reference_bits)
      reference_bits = profile_data.reference_bits(reference_index);
      fixture = svt_build_case (case_data, reference_bits);
      mpbits (reference_bits);
      reference = svt_reference (fixture.A, reference_bits);
      reference.case_id = char (case_data.id);
      reference.family = char (case_data.family);
      reference.reference_role = "SEPARATE_REFERENCE";
      case_references{end + 1} = reference;
    endfor
    high_reference = case_references{end};
    for row_index = 1:numel (rows_out)
      row = rows_out{row_index};
      if (! row.native && strcmp (row.case_id, case_data.id) ...
          && row.work_bits == work_bits(end))
        row.reference_bits = profile_data.reference_bits;
        row.reference_status = "consistent_reference";
        row.reference_absolute_max = max (abs (svt_widen (row.values, ...
                                                high_reference.input_precision_bits) ...
                                             - high_reference.values));
        rows_out{row_index} = row;
      endif
    endfor
    references{end + 1} = case_references;
  endfor

  target_bits = 60;
  if (strcmp (profile_name, "demo")), target_bits = 80; endif
  certificates = {};
  ## V1a is run for every highest-work-precision economy row.
  for case_index = 1:numel (selected)
    fixture = high_fixtures{case_index};
    row = high_econ{case_index};
    certificate = svt_certify_values (fixture.A, row.U, row.S, row.V, ...
                                      profile_data.evaluation_bits);
    certificate.meets_accuracy_target = svt_value_target (certificate, ...
                                                           target_bits);
    job = svt_job (row.case_id, "V1A", certificate.method, ...
                   certificate.status, certificate.meets_accuracy_target, ...
                   certificate, "highest-work-precision economy row");
    certificates{end + 1} = job;
  endfor

  ## Selected native inputs are certified separately after explicit conversion.
  if (strcmp (profile_name, "demo") && strcmp (tier, "all"))
    native_names = {"S1-NRO-TWO", "A5-GEO", "S4-DD-SYM"};
    for name_index = 1:numel (native_names)
      case_index = find (strcmp ({selected.id}, native_names{name_index}), 1);
      if (isempty (case_index)), continue; endif
      fixture = high_fixtures{case_index};
      mpbits (profile_data.evaluation_bits);
      native_input = mp (double (fixture.A));
      [native_u, native_s, native_v] = svd (native_input, "econ");
      certificate = svt_certify_values (native_input, native_u, native_s, ...
                                        native_v, profile_data.evaluation_bits);
      certificate.meets_accuracy_target = svt_value_target (certificate, ...
                                                             target_bits);
      job = svt_job (native_names{name_index}, "V1A-NATIVE", ...
                     certificate.method, certificate.status, ...
                     certificate.meets_accuracy_target, certificate, ...
                     "selected frozen native input; explicit MP conversion");
      certificates{end + 1} = job;
    endfor
  endif

  ## V1b positive cluster jobs. Internal multiplicity is permitted; only the
  ## external signed-dilation separation may make the result inconclusive.
  for case_index = 1:numel (selected)
    fixture = high_fixtures{case_index};
    row = high_econ{case_index};
    indices = [];
    if (isfield (fixture, "cluster_indices"))
      indices = fixture.cluster_indices;
    elseif (strcmp (fixture.family, "lauchli"))
      k = min (size (fixture.A));
      if (k >= 2), indices = 2:k; endif
    endif
    if (! isempty (indices))
      certificate = svt_certify_projector (fixture.A, row.U, row.S, row.V, ...
                                           profile_data.evaluation_bits, indices);
      certificate.meets_accuracy_target = ...
          strcmp (certificate.projector_status, "CERTIFIED") ...
          && certificate.bU.hi <= svt_pow2 (-target_bits) ...
          && certificate.bV.hi <= svt_pow2 (-target_bits);
      job = svt_job (row.case_id, "V1B", certificate.method, ...
                     certificate.projector_status, ...
                     certificate.meets_accuracy_target, certificate, ...
                     "positive singular cluster projector");
      certificates{end + 1} = job;
    endif
  endfor

  ## V2 simple-factor jobs cover a nontrivial rectangular real/complex pair,
  ## in addition to the named geometric Hadamard and graded NRO fixtures.
  factor_names = {"A5-GEO", "S1-NRO-GRADED"};
  for name_index = 1:numel (factor_names)
    case_index = find (strcmp ({selected.id}, factor_names{name_index}), 1);
    if (isempty (case_index)), continue; endif
    fixture = high_fixtures{case_index};
    row = high_econ{case_index};
    k = min (size (fixture.A));
    certificate = svt_certify_factor_boxes (fixture.A, row.U, row.S, row.V, ...
                                             profile_data.evaluation_bits, 1:k);
    certificate.meets_accuracy_target = svt_factor_target (certificate, ...
                                                            target_bits);
    job = svt_job (row.case_id, "V2", certificate.method, certificate.status, ...
                   certificate.meets_accuracy_target, certificate, ...
                   "named positive separated factor fixture");
    certificates{end + 1} = job;
  endfor
  if (strcmp (tier, "all"))
    [simple_real, simple_complex] = svt_simple_factor_inputs (profile_data.evaluation_bits);
    simple_inputs = {simple_real, simple_complex};
    simple_names = {"V2-SIMPLE-REAL", "V2-SIMPLE-COMPLEX"};
    for simple_index = 1:2
      input = simple_inputs{simple_index};
      [u, s, v] = svd (input, "econ");
      certificate = svt_certify_factor_boxes (input, u, s, v, ...
                                               profile_data.evaluation_bits);
      certificate.meets_accuracy_target = svt_factor_target (certificate, ...
                                                              target_bits);
      job = svt_job (simple_names{simple_index}, "V2", certificate.method, ...
                     certificate.status, certificate.meets_accuracy_target, ...
                     certificate, "separate 3-by-2 simple factor control");
      certificates{end + 1} = job;
    endfor
  endif

  ## V3 positive inverse checks use public solve outputs. Negative controls are
  ## recorded as INCONCLUSIVE/UNSUPPORTED, never as a singularity proof.
  inverse_names = {"S1-NRO-TWO", "A6-NRO-COMPANION", "S4-DD-SYM"};
  for name_index = 1:numel (inverse_names)
    case_index = find (strcmp ({selected.id}, inverse_names{name_index}), 1);
    if (isempty (case_index)), continue; endif
    fixture = high_fixtures{case_index};
    q = profile_data.evaluation_bits;
    mpbits (q);
    input = svt_widen (fixture.A, q);
    identity = mp (eye (rows (input)));
    inverse = input \ identity;
    certificate = svt_certify_inverse (input, inverse, q);
    certificate.meets_accuracy_target = strcmp (certificate.status, "CERTIFIED") ...
                                         && certificate.residual.hi < mp (1) ...
                                         && certificate.sigma_min_lower > mp (0);
    job = svt_job (inverse_names{name_index}, "V3", certificate.method, ...
                   certificate.status, certificate.meets_accuracy_target, ...
                   certificate, "public solve output inverse verification");
    certificates{end + 1} = job;
  endfor
  if (strcmp (tier, "all"))
    bad_case_index = find (strcmp ({selected.id}, "A5-RANK4"), 1);
    if (! isempty (bad_case_index))
      fixture = high_fixtures{bad_case_index};
      q = profile_data.evaluation_bits;
      mpbits (q);
      bad = svt_certify_inverse (fixture.A, mp (eye (rows (fixture.A))), q);
      bad.meets_accuracy_target = ! strcmp (bad.status, "CERTIFIED");
      certificates{end + 1} = svt_job (fixture.id, "V3-NEGATIVE-SINGULAR", ...
                                       bad.method, bad.status, ...
                                       bad.meets_accuracy_target, bad, ...
                                       "rank-deficient negative control");
    endif
    poor_input = mp (eye (3));
    poor_inverse = mp (zeros (3, 3));
    bad = svt_certify_inverse (poor_input, poor_inverse, profile_data.evaluation_bits);
    bad.meets_accuracy_target = ! strcmp (bad.status, "CERTIFIED");
    certificates{end + 1} = svt_job ("V3-POOR-INVERSE", "V3-NEGATIVE-POOR", ...
                                     bad.method, bad.status, ...
                                     bad.meets_accuracy_target, bad, ...
                                     "zero approximate inverse negative control");
    rectangular = high_fixtures{find (strcmp ({selected.id}, "A4-LAU-TALL"), 1)};
    rectangular_inverse = mp (zeros (rows (rectangular.A), columns (rectangular.A)));
    bad = svt_certify_inverse (rectangular.A, rectangular_inverse, ...
                               profile_data.evaluation_bits);
    bad.meets_accuracy_target = strcmp (bad.status, "UNSUPPORTED_RECTANGULAR");
    certificates{end + 1} = svt_job (rectangular.id, "V3-NEGATIVE-RECTANGULAR", ...
                                     bad.method, bad.status, ...
                                     bad.meets_accuracy_target, bad, ...
                                     "rectangular inverse route is unsupported");
  endif

  all_rows_pass = true;
  for index = 1:numel (rows_out)
    all_rows_pass = all_rows_pass && strcmp (rows_out{index}.status, "PASS");
  endfor
  all_jobs_pass = true;
  for index = 1:numel (certificates)
    all_jobs_pass = all_jobs_pass && certificates{index}.gate_ok;
  endfor
  results = struct ();
  results.schema = "svt-v1";
  results.profile = profile_name;
  results.tier = tier;
  results.plot = plot_enabled;
  results.rows = rows_out;
  results.references = references;
  results.certificates = certificates;
  results.measured_svd_rows = numel (rows_out);
  results.expected_svd_rows = expected_rows;
  results.reference_job_count = numel (selected) * numel (profile_data.reference_bits);
  results.v_job_count = numel (certificates);
  results.coverage = struct ("cases", numel (selected), "expected_cases", ...
                             numel (selected), "svd_rows", numel (rows_out), ...
                             "expected_svd_rows", expected_rows, ...
                             "references", results.reference_job_count, ...
                             "v_jobs", results.v_job_count);
  results.scope_ok = svt_check_coverage (rows_out, expected_rows);
  results.ok = results.scope_ok && all_rows_pass && all_jobs_pass ...
               && strcmp (tier, "all");
  if (results.ok)
    results.status = "PASS";
    results.message = "complete measured profile and mandatory V jobs passed";
  elseif (results.scope_ok && all_rows_pass && all_jobs_pass)
    results.status = "PASS";
    results.message = "selected tier passed; tier-only run is not full-suite PASS";
  else
    results.status = "FAIL";
    results.message = "a measured row, coverage gate, or mandatory V job failed";
  endif
  results.environment = struct ("octave", version (), "entry_mpbits", saved_bits, ...
                                "evaluation_bits", profile_data.evaluation_bits, ...
                                "native_rows_are_explicit", true, ...
                                "paper_algorithm_reproduction", false);
  clear cleanup;
endfunction

function job = svt_job (case_id, tier, method, status, gate_ok, certificate, notes)
  job = struct ("schema", "svt-verification-job-v1", "case_id", case_id, ...
                "tier", tier, "method", method, "status", status, ...
                "gate_ok", logical (gate_ok), "notes", notes, ...
                "paper_algorithm_reproduction", false, "certificate", certificate);
endfunction

function good = svt_value_target (certificate, target_bits)
  good = strcmp (certificate.status, "CERTIFIED");
  if (! good), return; endif
  lower = certificate.values_lower;
  upper = certificate.values_upper;
  scale = certificate.values_upper(1);
  tolerance = svt_pow2 (-target_bits);
  for index = 1:numel (lower)
    width = upper(index) - lower(index);
    if (lower(index) > mp (0))
      good = good && width / lower(index) <= tolerance;
    else
      good = good && width <= scale * tolerance;
    endif
  endfor
endfunction

function good = svt_factor_target (certificate, target_bits)
  if (strcmp (certificate.status, "UNSUPPORTED_MULTIPLICITY"))
    ## The repeated-pair part is intentionally not an individual-factor claim.
    good = true;
    for index = 1:numel (certificate.individual_status)
      state = certificate.individual_status{index};
      good = good && any (strcmp (state, {"CERTIFIED", "UNSUPPORTED_MULTIPLICITY"}));
    endfor
    return;
  endif
  good = strcmp (certificate.status, "CERTIFIED");
  if (! good), return; endif
  tolerance = svt_pow2 (-target_bits);
  for index = 1:numel (certificate.individual_status)
    good = good && strcmp (certificate.individual_status{index}, "CERTIFIED");
  endfor
  if (isfield (certificate, "dU"))
    good = good && certificate.dU.hi <= tolerance ...
                && certificate.dV.hi <= tolerance;
  endif
endfunction

function [real_input, complex_input] = svt_simple_factor_inputs (q)
  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (q);
  real_input = mp (zeros (3, 2));
  real_input(1, 1) = mp (4);
  real_input(2, 2) = mp (2);
  real_input(3, 2) = mp ("0.5");
  left_phase = svt_phase_diagonal (3);
  complex_input = left_phase * real_input;
  clear cleanup;
endfunction
