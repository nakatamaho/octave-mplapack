% Manifest/profile facade for the NEIGT ordinary S/A eigensystem suite.
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
  unwind_protect
    opts = net_options (profile, options);
    bundle = net_manifest ();
    profile_data = bundle.cases.profiles.(opts.profile);
    selected = profile_data.cases;
    if (! strcmp (opts.tier, "all") && ! any (strcmp (opts.tier, {"V", "V-S", "V-A"})))
      keep = false (numel (selected), 1);
      for index = 1:numel (selected)
        keep(index) = strcmp (selected(index).tier, opts.tier);
      endfor
      selected = selected(keep);
    elseif (any (strcmp (opts.tier, {"V", "V-S", "V-A"})))
      selected = selected([]);
    endif
    rows = 2 * numel (selected) * (numel (profile_data.work_bits) + 1);
    result = struct ("schema", "neigt-v1", "profile", opts.profile, ...
                     "tier", opts.tier, "status", "NOT_IMPLEMENTED", ...
                     "ok", false, "scope_ok", true, "rows", struct ([]), ...
                     "coverage", struct ("case_count", numel (selected), ...
                                          "measured_eig_rows", rows, ...
                                          "expected_all_case_count", ...
                                          profile_data.expected_case_count, ...
                                          "expected_all_measured_eig_rows", ...
                                          profile_data.expected_measured_eig_rows, ...
                                          "ordinary_cases_implemented", false), ...
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
