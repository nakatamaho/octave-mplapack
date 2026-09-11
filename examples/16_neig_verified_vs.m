% NEIGT verified nonsymmetric-eigenvalue (V-S) entry point.
if (exist ("mp_neig_verify_examples", "file") != 2)
  example_root = fileparts (mfilename ("fullpath"));
  addpath (fullfile (example_root, "neig_tiers"));
endif

result = mp_neig_verify_examples ("smoke", struct ("tier", "V-S", ...
                                                    "plot", false));
assert (result.scope_ok);
fprintf ("NEIGT V-S scope parsed: %d verification jobs; status=%s\n", ...
         result.coverage.verification_job_count, result.status);
