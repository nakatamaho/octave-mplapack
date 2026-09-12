% NEIGT24: numbered examples and documentation/example-runner integration.
test_root = fileparts (fileparts (mfilename ("fullpath")));
example_root = fullfile (test_root, "examples");
tier_root = fullfile (example_root, "neig_tiers");
addpath (tier_root);

numbered = {"14_neig_tier_s.m", "15_neig_tier_a.m", ...
            "16_neig_verified_vs.m", "17_neig_verified_va.m"};
for index = 1:numel (numbered)
  path_name = fullfile (example_root, numbered{index});
  assert (exist (path_name, "file") == 2);
  clear result;
  run (path_name);
  assert (exist ("result", "var") == 1 && isstruct (result));
  assert (result.scope_ok && result.ok);
  assert (! isfield (result, "used_binary64_fallback") ...
          || ! result.used_binary64_fallback);
  if (index <= 2)
    assert (any (strcmp (result.status, {"NUMERICS_COMPLETE", ...
                                         "NUMERICS_ONLY_COMPLETE"})));
    assert (result.coverage.measured_eig_rows > 0);
  else
    assert (result.coverage.verification_job_count > 0);
    assert (strcmp (result.status, "COMPLETE"));
  endif
endfor

% The numbered examples are documented entry points, while these are the
% exact replay APIs.  Keep the help text available in a source checkout.
for name = {"mp_neig_tiers", "mp_neig_verify_examples", ...
            "mp_neig_write_outputs", "mp_neig_replay"}
  help_text = evalc (sprintf ("help %s", name{1}));
  assert (! isempty (strfind (help_text, "NEIGT")));
endfor

fprintf ("PASS: NEIGT24 numbered Tier-S/Tier-A/V-S/V-A examples and help integration\n");
