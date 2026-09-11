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
      endif
    endfor
    vs1 = status(starts_with ({status.id}, "VS1-"));
    implemented = sum (starts_with ({status.id}, "VS1-"));
    vs1_complete = ! isempty (vs1) && all ([vs1.pass]);
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
                                          "vs1_complete", vs1_complete), ...
                     "manifest", struct ("cases", bundle.cases_path, ...
                                         "verification_jobs", bundle.jobs_path), ...
                     "options", opts, "source", "NEIGT14_VS1_GERSHGORIN_V1");
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
    "status", "NOT_IMPLEMENTED", "pass", false, "candidate_source", "", ...
    "candidate_bits", NaN, "evaluation_bits", NaN, "raw_V_hash", "", ...
    "raw_D_hash", "", "raw_W_hash", "", "certificate", [], ...
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
