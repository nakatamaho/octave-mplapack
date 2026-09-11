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
    status = repmat (struct ("id", "", "status", "NOT_IMPLEMENTED"), ...
                     numel (jobs), 1);
    for index = 1:numel (jobs)
      status(index).id = jobs{index}.id;
    endfor
    result = struct ("schema", "neigt-v1", "profile", opts.profile, ...
                     "tier", opts.tier, "status", "NOT_IMPLEMENTED", ...
                     "ok", false, "scope_ok", true, "jobs", status, ...
                     "coverage", struct ("verification_job_count", numel (jobs), ...
                                          "expected_all_verification_job_count", 26, ...
                                          "verification_jobs_implemented", false), ...
                     "manifest", struct ("cases", bundle.cases_path, ...
                                         "verification_jobs", bundle.jobs_path), ...
                     "options", opts);
    if (added)
      rmpath (private_root);
    endif
  unwind_protect_cleanup
    if (added && any (strcmp (strsplit (path (), pathsep), private_root)))
      rmpath (private_root);
    endif
  end_unwind_protect
endfunction
