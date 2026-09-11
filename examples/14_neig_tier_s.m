% NEIGT Tier-S entry point.
%
% This numbered example exercises the manifest/profile facade.  Numerical
% constructors are added by the corresponding NEIGT milestones.
if (exist ("mp_neig_tiers", "file") != 2)
  example_root = fileparts (mfilename ("fullpath"));
  addpath (fullfile (example_root, "neig_tiers"));
endif

result = mp_neig_tiers ("smoke", struct ("tier", "S", "plot", false));
assert (result.scope_ok);
fprintf ("NEIGT Tier-S scope parsed: %d cases, %d measured rows; status=%s\n", ...
         result.coverage.case_count, result.coverage.measured_eig_rows, ...
         result.status);
