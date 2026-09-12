% NEIGT22: full ordinary and verification-tier integration per profile.
test_root = fileparts (fileparts (mfilename ("fullpath")));
example_root = fullfile (test_root, "examples", "neig_tiers");
private_root = fullfile (example_root, "private");
addpath (example_root);
addpath (private_root);

saved_bits = mpbits ();
unwind_protect
  smoke_ordinary = mp_neig_tiers ("smoke", struct ("tier", "all"));
  assert (strcmp (smoke_ordinary.status, "NUMERICS_ONLY_COMPLETE"));
  assert (smoke_ordinary.coverage.measured_eig_rows == 120);
  assert (smoke_ordinary.coverage.expected_all_measured_eig_rows == 120);
  assert (smoke_ordinary.coverage.numerics_only_complete);
  clear smoke_ordinary;

  demo_ordinary = mp_neig_tiers ("demo", struct ("tier", "all"));
  assert (strcmp (demo_ordinary.status, "NUMERICS_ONLY_COMPLETE"));
  assert (demo_ordinary.coverage.measured_eig_rows == 168);
  assert (demo_ordinary.coverage.expected_all_measured_eig_rows == 168);
  assert (demo_ordinary.coverage.numerics_only_complete);
  clear demo_ordinary;

  smoke_verify = mp_neig_verify_examples ("smoke", struct ("tier", "V"));
  assert (smoke_verify.ok && strcmp (smoke_verify.status, "COMPLETE"));
  assert (smoke_verify.coverage.verification_job_count == 26);
  assert (smoke_verify.coverage.verification_jobs_implemented == 26);
  assert (all ([smoke_verify.jobs.pass]));
  assert (all ([smoke_verify.jobs.milestone_pass]));
  clear smoke_verify;

  demo_verify = mp_neig_verify_examples ("demo", struct ("tier", "V"));
  assert (demo_verify.ok && strcmp (demo_verify.status, "COMPLETE"));
  assert (demo_verify.coverage.verification_job_count == 26);
  assert (demo_verify.coverage.verification_jobs_implemented == 26);
  assert (all ([demo_verify.jobs.pass]));
  assert (all ([demo_verify.jobs.milestone_pass]));
  fprintf ("PASS: NEIGT22 full 120/168 ordinary rows and 26+26 verification jobs\n");
unwind_protect_cleanup
  mpbits (saved_bits);
  if (any (strcmp (strsplit (path (), pathsep), private_root)))
    rmpath (private_root);
  endif
  if (any (strcmp (strsplit (path (), pathsep), example_root)))
    rmpath (example_root);
  endif
end_unwind_protect
