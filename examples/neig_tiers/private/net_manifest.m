% Load and validate the NEIGT JSON manifests without executing parameters.
function bundle = net_manifest ()
  here = fileparts (mfilename ("fullpath"));
  example_root = fileparts (here);
  repo_root = fileparts (fileparts (example_root));
  manifest_root = fullfile (repo_root, "docs", "codex", "neigt");
  cases_path = fullfile (manifest_root, "cases.json");
  jobs_path = fullfile (manifest_root, "verification-jobs.json");
  if (exist (cases_path, "file") != 2 || exist (jobs_path, "file") != 2)
    error ("mplapack:neigt:Manifest", ...
           "NEIGT cases.json and verification-jobs.json are required");
  endif

  cases_text = fileread (cases_path);
  jobs_text = fileread (jobs_path);
  cases = jsondecode (cases_text);
  jobs = jsondecode (jobs_text);
  if (! isstruct (cases) || ! isstruct (jobs) ...
      || ! strcmp (cases.schema, "neigt-cases-v1") ...
      || ! strcmp (jobs.schema, "neigt-verification-jobs-v1"))
    error ("mplapack:neigt:Manifest", "unsupported NEIGT manifest schema");
  endif
  if (! strcmp (cases.version, "1.0") || ! strcmp (jobs.version, "1.0"))
    error ("mplapack:neigt:Manifest", "unsupported NEIGT manifest version");
  endif

  profiles = {"smoke", "demo", "stress"};
  for index = 1:numel (profiles)
    profile = profiles{index};
    if (! isfield (cases.profiles, profile))
      error ("mplapack:neigt:Manifest", "cases manifest lacks profile %s", profile);
    endif
    data = cases.profiles.(profile);
    if (! isfield (data, "cases") || ! isfield (data, "work_bits") ...
        || ! isfield (data, "expected_case_count") ...
        || ! isfield (data, "expected_measured_eig_rows"))
      error ("mplapack:neigt:Manifest", "incomplete cases profile %s", profile);
    endif
    case_count = numel (data.cases);
    if (case_count != data.expected_case_count)
      error ("mplapack:neigt:Manifest", ...
             "%s case count mismatch: %d != %d", profile, case_count, ...
             data.expected_case_count);
    endif
    if (! isscalar (data.native_baseline) || ! data.native_baseline)
      error ("mplapack:neigt:Manifest", ...
             "%s must declare the native baseline", profile);
    endif
    expected_rows = 2 * case_count * (numel (data.work_bits) + 1);
    if (expected_rows != data.expected_measured_eig_rows)
      error ("mplapack:neigt:Manifest", ...
             "%s measured-row count mismatch: %d != %d", profile, ...
             expected_rows, data.expected_measured_eig_rows);
    endif
    ids = cell (case_count, 1);
    for case_index = 1:case_count
      entry = data.cases(case_index);
      if (! isfield (entry, "id") || ! isfield (entry, "tier") ...
          || ! isfield (entry, "parameters"))
        error ("mplapack:neigt:Manifest", ...
               "malformed %s case %d", profile, case_index);
      endif
      ids{case_index} = entry.id;
      if (! any (strcmp (entry.tier, {"S", "A"})))
        error ("mplapack:neigt:Manifest", ...
               "ordinary case %s has invalid tier", entry.id);
      endif
    endfor
    if (numel (unique (ids)) != case_count)
      error ("mplapack:neigt:Manifest", "%s case IDs are not unique", profile);
    endif
  endfor

  job_profiles = {"smoke", "demo"};
  for index = 1:numel (job_profiles)
    profile = job_profiles{index};
    if (! isfield (jobs.profiles, profile))
      error ("mplapack:neigt:Manifest", "jobs manifest lacks profile %s", profile);
    endif
    data = jobs.profiles.(profile);
    if (! isfield (data, "jobs") || data.expected_job_count != 26 ...
        || numel (data.jobs) != data.expected_job_count)
      error ("mplapack:neigt:Manifest", ...
             "%s must contain exactly 26 verification jobs", profile);
    endif
    ids = cell (numel (data.jobs), 1);
    for job_index = 1:numel (data.jobs)
      job = data.jobs{job_index};
      if (! isfield (job, "id") || ! isfield (job, "tier") ...
          || ! isfield (job, "kind"))
        error ("mplapack:neigt:Manifest", ...
               "malformed %s verification job %d", profile, job_index);
      endif
      ids{job_index} = job.id;
      if (! any (strcmp (job.tier, {"V-S", "V-A"})))
        error ("mplapack:neigt:Manifest", ...
               "verification job %s has invalid tier", job.id);
      endif
    endfor
    if (numel (unique (ids)) != numel (data.jobs))
      error ("mplapack:neigt:Manifest", ...
             "%s verification IDs are not unique", profile);
    endif
  endfor

  bundle = struct ("root", manifest_root, "cases_path", cases_path, ...
                   "jobs_path", jobs_path, "cases_text", cases_text, ...
                   "jobs_text", jobs_text, "cases", cases, "jobs", jobs);
endfunction
