function test_neigt16 ()
% NEIGT16: counted cluster separation, centered powers, and raw projectors.
addpath (fullfile (fileparts (mfilename ("fullpath")), "../examples/neig_tiers/private"));
addpath (fullfile (fileparts (mfilename ("fullpath")), "../examples/neig_tiers"));

saved_bits = mpbits ();
unwind_protect
  mpbits (256);
  profile_data = struct ("work_bits", [256], "evaluation_bits", 768);
  jobs = load_jobs ();
  positive = struct ([]);
  for index = 1:numel (jobs)
    positive(index) = net_v_s2_job (jobs(index), profile_data, "smoke");
    assert (positive(index).pass);
    assert (strcmp (positive(index).status, "CERTIFIED_CLUSTER"));
    assert (positive(index).milestone_pass);
    assert (positive(index).cluster.strict_separation);
    assert (positive(index).cluster.counted_total_roots == jobs(index).fixture.n);
    assert (positive(index).cluster.centered_power_pass);
    assert (positive(index).cluster.projector_pass);
    assert (positive(index).cluster.projector.raw_projector_bound <= net_pow2 (-40, 768));
    assert (positive(index).cluster.region_radius <= positive(index).cluster.cluster_radius_target);
  endfor

  % The defective exact 2-by-2 block has a nilpotent centered square.  This
  % checks the power primitive independently of the graph job's candidate.
  q = 256;
  mpbits (q);
  M = net_iv_cmatrix_point (mp ([1, 1; 0, 1]), q);
  shifted = net_iv_cmatrix_sub (M, net_iv_cmatrix_point (mp (eye (2)), q), q);
  squared = net_iv_cmatrix_mul (shifted, shifted, q);
  assert (net_iv_cmatrix_inf_upper (squared, q) == mp (0));

  % An intentionally invalid claimed region must not become a cluster proof.
  bad_job = jobs(1);
  bad_job.adversarial_claimed_radius = mp (8);
  bad = net_v_s2_cluster (positive(1).graph, positive(1).selected_candidate, ...
                          positive(1).query_center, bad_job, "smoke", 768);
  assert (! bad.pass);
  assert (! bad.strict_separation);
  assert (strcmp (bad.claim_status, "CERTIFIED_INVARIANT_BASIS"));

  % A full-space identity/triviality route is outside the certificate domain.
  full_job = jobs(1);
  full_job.cluster_dimension = full_job.fixture.n;
  full = net_v_s2_cluster (positive(1).graph, positive(1).selected_candidate, ...
                           positive(1).query_center, full_job, "smoke", 768);
  assert (! full.pass);
  assert (strcmp (full.status, "INCONCLUSIVE_FULL_SPACE_OR_DIMENSION"));

  fprintf ("PASS: NEIGT16 counted clusters, centered powers, projectors, and traps\n");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
endfunction

function jobs = load_jobs ()
  jobs = struct ();
  jobs(1) = make_job ("VS2-01", "semisimple", 6, 2, "1", "1/4");
  jobs(2) = make_job ("VS2-02", "jordan", 6, 2, "1", "1/4");
  jobs(3) = make_job ("VS2-03", "two_jordan", 8, 4, "1+2^-13", "1/4");
  jobs(3).fixture.gap_exponent = 12;
  jobs(4) = make_job ("VS2-04", "mks_zero", 6, 4, "0", "1/8");
  jobs(4).fixture.m = 3;
  jobs(4).fixture.delta = "1/8";
endfunction

function job = make_job (id, regime, n, k, center, radius)
  job = struct ("id", id, "tier", "V-S", "kind", "cluster_graph", ...
    "fixture", struct ("n", n, "regime", regime, ...
                        "query_center", center, "query_radius", radius, ...
                        "gap_exponent", 0, "m", 0, "delta", "1/8"), ...
    "cluster_dimension", k, "expected", "CERTIFIED_CLUSTER");
endfunction
