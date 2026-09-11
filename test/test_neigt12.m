% NEIGT12: complete ordinary profile coverage and honest all-tier status.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "neig_tiers"));

result = mp_neig_tiers ("smoke", struct ("tier", "all"));
assert (strcmp (result.schema, "neigt-v1"));
assert (strcmp (result.status, "NUMERICS_ONLY_COMPLETE"));
assert (! result.ok && result.scope_ok);
assert (result.coverage.case_count == 20);
assert (result.coverage.measured_eig_rows == 120);
assert (result.coverage.ordinary_complete);
assert (strcmp (result.verification_status, "NOT_IMPLEMENTED"));

for index = 1:numel (result.rows)
  row = result.rows{index};
  assert (row.complete);
  if (strcmp (row.work_role, "native64"))
    assert (row.gate_pass);
  else
    assert (isfield (row, "gate") && row.gate_pass);
  endif
endfor

fprintf ("PASS: NEIGT12 ordinary smoke coverage is 120 rows and V remains explicit\n");
