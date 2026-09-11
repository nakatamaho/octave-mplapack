% Manifest/profile facade for the NEIGT V-S/V-A verification jobs.
function result = mp_neig_verify_examples (profile, options)
  if (nargin < 1 || nargin > 2)
    error ("mplapack:neigt:Arguments", ...
           "mp_neig_verify_examples expects a profile and optional options");
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
  unwind_protect
    opts = net_options (profile, options);
    bundle = net_manifest ();
    if (strcmp (opts.profile, "stress"))
      jobs = struct ([]);
    else
      all_jobs = bundle.jobs.profiles.(opts.profile).jobs;
      if (any (strcmp (opts.tier, {"all", "V"})))
          jobs = all_jobs;
      else
        keep = false (numel (all_jobs), 1);
        for index = 1:numel (all_jobs)
          keep(index) = strcmp (all_jobs{index}.tier, opts.tier);
        endfor
        jobs = all_jobs(keep);
      endif
    endif
    status = repmat (job_status_template (), numel (jobs), 1);
    for index = 1:numel (jobs)
      status(index).id = jobs{index}.id;
      if (strncmp (jobs{index}.id, "VS1-", 4))
        fprintf (2, "NEIGT14: starting %s (%s)\n", jobs{index}.id, opts.profile);
        status(index) = run_vs1_job (jobs{index}, ...
          bundle.cases.profiles.(opts.profile), opts.profile);
        fprintf (2, "NEIGT14: finished %s status=%s pass=%d\n", ...
                 status(index).id, status(index).status, status(index).pass);
      elseif (strncmp (jobs{index}.id, "VS2-", 4))
        fprintf (2, "NEIGT16: starting %s (%s)\n", jobs{index}.id, opts.profile);
        try
          graph_job = net_v_s2_job (jobs{index}, ...
                                    bundle.cases.profiles.(opts.profile), opts.profile);
          status(index).status = graph_job.status;
          status(index).claim_status = graph_job.claim_status;
          status(index).claim_quality = graph_job.claim_quality;
          status(index).milestone_pass = graph_job.milestone_pass;
          status(index).details = graph_job;
          status(index).certificate = graph_job.graph;
          status(index).candidate_source = graph_job.candidate_source;
          status(index).candidate_bits = graph_job.candidate_bits;
          status(index).evaluation_bits = graph_job.evaluation_bits;
          status(index).pass = graph_job.pass;
        catch exception
          status(index).status = "FAILED_PREPARATION";
          status(index).error_identifier = exception.identifier;
          status(index).error_message = exception.message;
        end_try_catch
        fprintf (2, "NEIGT16: finished %s status=%s milestone_pass=%d\n", ...
                 status(index).id, status(index).status, status(index).milestone_pass);
      elseif (strncmp (jobs{index}.id, "VS3-", 4))
        fprintf (2, "NEIGT17: starting %s (%s)\n", jobs{index}.id, opts.profile);
        try
          pseudospectrum_job = net_v_s3_job (jobs{index}, ...
                                             bundle.jobs.profiles.(opts.profile), ...
                                             opts.profile);
          status(index) = pseudospectrum_job;
        catch exception
          status(index).status = "FAILED_VERIFIER";
          status(index).claim_status = "ERROR";
          status(index).error_identifier = exception.identifier;
          status(index).error_message = exception.message;
        end_try_catch
        fprintf (2, "NEIGT17: finished %s status=%s milestone_pass=%d\n", ...
                 status(index).id, status(index).status, status(index).milestone_pass);
      elseif (strncmp (jobs{index}.id, "VA1-", 4))
        fprintf (2, "NEIGT18: starting %s (%s)\n", jobs{index}.id, opts.profile);
        try
          factor_job = net_v_a1_job (jobs{index}, ...
                                     bundle.jobs.profiles.(opts.profile), ...
                                     opts.profile);
          status(index) = factor_job;
        catch exception
          status(index).status = "FAILED_VERIFIER";
          status(index).claim_status = "ERROR";
          status(index).error_identifier = exception.identifier;
          status(index).error_message = exception.message;
        end_try_catch
        fprintf (2, "NEIGT18: finished %s status=%s milestone_pass=%d\n", ...
                 status(index).id, status(index).status, status(index).milestone_pass);
      endif
    endfor
    vs1 = status(starts_with ({status.id}, "VS1-"));
    vs2_active = active_vs2 ({status.id});
    implemented = sum (starts_with ({status.id}, "VS1-")) ...
                  + sum (vs2_active) + sum (active_prefix ({status.id}, "VS3-"));
    vs1_complete = ! isempty (vs1) && all ([vs1.pass]);
    vs2 = status(vs2_active);
    vs2_milestone_complete = ! isempty (vs2) ...
                             && all ([vs2.milestone_pass]);
    vs3_active = active_prefix ({status.id}, "VS3-");
    vs3 = status(vs3_active);
    vs3_complete = ! isempty (vs3) && all ([vs3.milestone_pass]);
    va1_active = active_prefix ({status.id}, "VA1-");
    va1 = status(va1_active);
    va1_complete = ! isempty (va1) && all ([va1.pass]);
    implemented += sum (va1_active);
    selected_complete = ! isempty (status) && all ([status.pass]);
    if (isempty (status))
      overall_status = "NOT_APPLICABLE";
    elseif (selected_complete)
      overall_status = "COMPLETE";
    else
      overall_status = "PARTIAL_NOT_IMPLEMENTED";
    endif
    result = struct ("schema", "neigt-v1", "profile", opts.profile, ...
                     "tier", opts.tier, "status", overall_status, ...
                     "ok", selected_complete, "scope_ok", true, "jobs", status, ...
                     "coverage", struct ("verification_job_count", numel (jobs), ...
                                          "expected_all_verification_job_count", 26, ...
                                          "verification_jobs_implemented", implemented, ...
                                          "vs1_job_count", numel (vs1), ...
                                          "vs1_complete", vs1_complete, ...
                                          "vs2_invariant_job_count", sum (vs2_active), ...
                                          "vs2_invariant_complete", vs2_milestone_complete, ...
                                          "vs3_job_count", sum (vs3_active), ...
                                          "vs3_complete", vs3_complete, ...
                                          "va1_job_count", sum (va1_active), ...
                                          "va1_complete", va1_complete), ...
                     "manifest", struct ("cases", bundle.cases_path, ...
                                         "verification_jobs", bundle.jobs_path), ...
                     "options", opts, "source", "NEIGT17_VS3_SVD_POLAR_WEYL_V1");
    if (added)
      rmpath (private_root);
    endif
  unwind_protect_cleanup
    if (added && any (strcmp (strsplit (path (), pathsep), private_root)))
      rmpath (private_root);
    endif
  end_unwind_protect
endfunction

function result = job_status_template ()
  result = struct ("id", "", "tier", "", "kind", "", ...
    "status", "NOT_IMPLEMENTED", "pass", false, "milestone_pass", false, ...
    "claim_status", "", "claim_quality", "", "details", [], ...
    "candidate_source", "", ...
    "candidate_bits", NaN, "evaluation_bits", NaN, "raw_V_hash", "", ...
    "raw_D_hash", "", "raw_W_hash", "", "certificate", [], ...
    "raw_B_hash", "", "raw_U_hash", "", "raw_s_hash", "", ...
    "raw_lambda_hash", "", ...
    "input_hash", "", "source", "", "input_status", "", "target", "", ...
    "raw_V", [], "raw_D", [], "raw_W", [], "error_identifier", "", ...
    "error_message", "");
endfunction

function result = run_vs1_job (job, profile_data, profile)
  result = job_status_template ();
  result.id = job.id;
  result.tier = job.tier;
  result.kind = job.kind;
  result.candidate_source = job.candidate_source;
  result.candidate_bits = job.source_bits;
  result.evaluation_bits = profile_data.evaluation_bits;
  case_entry = find_case (profile_data.cases, job.core_case);
  saved_bits = mpbits ();
  unwind_protect
    try
      mpbits (job.source_bits);
      stage = tic ();
      model = net_case_model (case_entry, job.source_bits);
      fprintf (2, "NEIGT14: %s model %.3fs\n", job.id, toc (stage));
      stage = tic ();
      [V, D, W] = eig (model.A_frozen, "nobalance");
      fprintf (2, "NEIGT14: %s eig %.3fs\n", job.id, toc (stage));
      result.raw_V = V;
      result.raw_D = D;
      result.raw_W = W;
      result.raw_V_hash = net_raw_hash (V, [job.id, "_raw_V"]);
      result.raw_D_hash = net_raw_hash (D, [job.id, "_raw_D"]);
      result.raw_W_hash = net_raw_hash (W, [job.id, "_raw_W"]);
      q = profile_data.evaluation_bits;
      mpbits (q);
      stage = tic ();
      A = net_widen (model.A_frozen, q, job.source_bits);
      X = net_widen (V, q, job.source_bits);
      T = net_widen (D, q, job.source_bits);
      fprintf (2, "NEIGT14: %s widen %.3fs\n", job.id, toc (stage));
      stage = tic ();
      R = X \ mp (eye (rows (X)));
      fprintf (2, "NEIGT14: %s inverse-candidate %.3fs\n", job.id, toc (stage));
      useful_exponent = -40;
      if (strcmp (profile, "demo"))
        useful_exponent = -64;
      endif
      stage = tic ();
      certificate = net_v_s1_gershgorin ...
        (A, X, T, R, q, useful_exponent);
      fprintf (2, "NEIGT14: %s interval-certificate %.3fs\n", ...
               job.id, toc (stage));
      result.certificate = certificate;
      result.status = certificate.status;
      result.pass = strcmp (certificate.status, "CERTIFIED_ALL") ...
                    && certificate.all_roots && certificate.counted_roots == rows (A) ...
                    && certificate.singleton_useful && certificate.useful;
      result.milestone_pass = result.pass;
      result.claim_status = certificate.status;
      result.claim_quality = "resolved";
      result.details = certificate;
      if (result.pass)
        result.status = "PASS";
      endif
    catch exception
      result.status = "FAILED_VERIFIER";
      result.error_identifier = exception.identifier;
      result.error_message = exception.message;
    end_try_catch
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function result = find_case (cases, id)
  result = [];
  for index = 1:numel (cases)
    if (strcmp (cases(index).id, id))
      result = cases(index);
      return;
    endif
  endfor
  error ("mplapack:neigt:Manifest", "case %s is not in the profile", id);
endfunction

function result = starts_with (values, prefix)
  result = false (size (values));
  for index = 1:numel (values)
    result(index) = strncmp (values{index}, prefix, numel (prefix));
  endfor
endfunction

function result = active_vs2 (values)
  result = active_prefix (values, "VS2-");
endfunction

function result = active_prefix (values, prefix)
  result = false (size (values));
  for index = 1:numel (values)
    result(index) = strncmp (values{index}, prefix, numel (prefix));
  endfor
endfunction
