% NEIGT01 manifest/options/path-restoration self-test.
function report = mp_neig_tiers_selftest ()
  helper_root = fileparts (mfilename ("fullpath"));
  private_root = fullfile (helper_root, "private");
  addpath (private_root);
  saved_path = path ();
  have_mpbits = (exist ("mpbits", "file") == 2);
  if (have_mpbits)
    saved_bits = mpbits ();
  endif
  unwind_protect
    bundle = net_manifest ();
    assert (bundle.cases.profiles.smoke.expected_case_count == 20);
    assert (bundle.cases.profiles.demo.expected_case_count == 21);
    assert (bundle.cases.profiles.stress.expected_case_count == 8);
    assert (bundle.cases.profiles.smoke.expected_measured_eig_rows == 120);
    assert (bundle.cases.profiles.demo.expected_measured_eig_rows == 168);
    assert (bundle.cases.profiles.stress.expected_measured_eig_rows == 64);
    assert (numel (bundle.jobs.profiles.smoke.jobs) == 26);
    assert (numel (bundle.jobs.profiles.demo.jobs) == 26);

    smoke = mp_neig_tiers ("smoke");
    assert (smoke.scope_ok && ! smoke.ok && strcmp (smoke.status, "NOT_IMPLEMENTED"));
    s = mp_neig_tiers ("smoke", struct ("tier", "S"));
    a = mp_neig_tiers ("smoke", struct ("tier", "A"));
    vs = mp_neig_verify_examples ("smoke", struct ("tier", "V-S"));
    va = mp_neig_verify_examples ("smoke", struct ("tier", "V-A"));
    assert (s.coverage.case_count == 12 && s.coverage.measured_eig_rows == 72);
    assert (a.coverage.case_count == 8 && a.coverage.measured_eig_rows == 48);
    assert (numel (vs.jobs) == 16 && numel (va.jobs) == 10);
    assert (! any (strcmp ({vs.jobs.status}, "PASS")));

    caught = false;
    try
      mp_neig_tiers ("smoke", struct ("unknown", true));
    catch
      caught = true;
    end_try_catch
    assert (caught);
    caught = false;
    try
      mp_neig_tiers ("smoke", struct ("tier", "bad"));
    catch
      caught = true;
    end_try_catch
    assert (caught);

    if (have_mpbits)
      mpbits (256);
      mp_neig_tiers ("smoke", struct ("tier", "S"));
      assert (mpbits () == 256);
    endif
    report = struct ("ok", true, "manifest", "PASS", "options", "PASS", ...
                     "state_restoration", "PASS", "implemented", false);
    fprintf ("PASS: NEIGT01 manifest, strict options, filtered coverage, and restoration selftest\n");
  unwind_protect_cleanup
    path (saved_path);
    if (have_mpbits)
      mpbits (saved_bits);
    endif
    if (any (strcmp (strsplit (path (), pathsep), private_root)))
      rmpath (private_root);
    endif
  end_unwind_protect
endfunction
