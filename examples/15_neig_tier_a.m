% NEIGT Tier-A entry point.
if (exist ("mp_neig_tiers", "file") != 2)
  example_root = fileparts (mfilename ("fullpath"));
  addpath (fullfile (example_root, "neig_tiers"));
endif

result = mp_neig_tiers ("smoke", struct ("tier", "A", "plot", false));
assert (result.scope_ok);
fprintf ("NEIGT Tier-A scope parsed: %d cases, %d measured rows; status=%s\n", ...
         result.coverage.case_count, result.coverage.measured_eig_rows, ...
         result.status);
