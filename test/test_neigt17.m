% NEIGT17: verified pseudospectrum points, cells, and fail-closed boundaries.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "neig_tiers", "private"));

saved_bits = mpbits ();
unwind_protect
  mpbits (256);
  bundle = net_manifest ();
  jobs = bundle.jobs.profiles.smoke.jobs;
  for index = 13:16
    job = jobs{index};
    result = net_v_s3_job (job, bundle.jobs.profiles.smoke, "smoke");
    assert (result.pass && result.milestone_pass);
    assert (strcmp (result.status, "PASS"));
    expected_method = "neigt_svd_pseudospectrum_point_v1";
    if (strcmp (job.kind, "pseudospectrum_cell"))
      expected_method = "neigt_svd_pseudospectrum_cell_v1";
    endif
    assert (strcmp (result.certificate.method, expected_method));
    assert (strcmp (result.claim_status, job.expected));
    assert (! isempty (result.raw_B_hash));
    assert (! isempty (result.raw_U_hash));
    assert (! isempty (result.raw_s_hash));
    assert (! isempty (result.raw_V_hash));
    assert (result.certificate.gU < mp (1));
    assert (result.certificate.gV < mp (1));
    assert (result.certificate.delta >= mp (0));
    assert (result.certificate.lower >= mp (0));
    assert (result.certificate.upper >= result.certificate.lower);
    if (strcmp (job.kind, "pseudospectrum_cell"))
      assert (result.certificate.cell.positive_area);
      assert (result.certificate.cell.area > mp (0));
      assert (result.certificate.cell.distance > mp (0));
      assert (strcmp (result.certificate.cell.status, job.expected));
    endif
  endfor

  % The classifier receives a genuinely straddling outward interval and must
  % not manufacture an inside/outside decision at the boundary.
  epsilon = net_pow2 (-12, 256);
  assert (strcmp (net_v_s3_classify (epsilon / mp (2), epsilon * mp (2), ...
                                    epsilon), "INCONCLUSIVE"));
  assert (strcmp (net_v_s3_classify (epsilon, epsilon, epsilon), ...
                  "CERTIFIED_INSIDE"));

  caught = false;
  try
    net_v_s3_classify (mp (2), mp (1), epsilon);
  catch
    caught = true;
  end_try_catch
  assert (caught);
  caught = false;
  try
    net_v_s3_classify (mp (0), mp (1), mp (0));
  catch
    caught = true;
  end_try_catch
  assert (caught);

  fprintf ("PASS: NEIGT17 verified SVD pseudospectrum points, positive-area cells, and boundary traps\n");
unwind_protect_cleanup
  mpbits (saved_bits);
  if (any (strcmp (strsplit (path (), pathsep), ...
             fullfile (test_root, "examples", "neig_tiers", "private"))))
    rmpath (fullfile (test_root, "examples", "neig_tiers", "private"));
  endif
end_unwind_protect
