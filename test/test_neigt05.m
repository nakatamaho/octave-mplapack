% Focused NEIGT05 exact similarity regimes and nontrivial subspace checks.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "neig_tiers"));
addpath (fullfile (test_root, "examples", "neig_tiers", "private"));
saved_bits = mpbits ();
unwind_protect
  regimes = {"simple", "semisimple", "jordan", "two_jordan"};
  for regime_index = 1:numel (regimes)
    regime = regimes{regime_index};
    if (strcmp (regime, "two_jordan"))
      gap = 12;
    else
      gap = 24;
    endif
    fixture = net_similarity_model (regime, 8, gap, 512);
    audit = net_similarity_audit (fixture);
    assert (audit.exact_intertwining);
    assert (all (audit.characteristic_checks));
    assert (all (cellfun (@(x) x.status, audit.nilpotent_checks)));
    assert (all (cellfun (@(x) x.status, audit.subspace_checks)));
    assert (strcmp (audit.multiplicity_source, ...
                    "exact_J_structure_not_disk_count"));
    if (strcmp (regime, "simple") || strcmp (regime, "semisimple"))
      assert (audit.diagonalizable && audit.full_eigenbasis_exists);
    else
      assert (! audit.diagonalizable && ! audit.full_eigenbasis_exists);
      assert (audit.nilpotent_checks{1}.first_power_nonzero);
    endif
    if (strcmp (regime, "semisimple"))
      assert (audit.groups(1).geometric_multiplicity == 2);
      assert (! audit.nilpotent_checks{1}.first_power_nonzero);
    endif
    if (strcmp (regime, "simple"))
      assert (! audit.coordinate_columns_diagonalize ...
              || strcmp (regime, "semisimple"));
    endif
  endfor

  merged = net_similarity_model ("two_jordan", 16, 40, 512);
  merged_audit = net_similarity_audit (merged, [0, 1, 2, 4, 16, 17]);
  assert (merged_audit.groups(1).algebraic_multiplicity == 2);
  assert (merged_audit.groups(2).algebraic_multiplicity == 2);
  assert (! merged_audit.full_eigenbasis_exists);
  fprintf ("PASS: NEIGT05 exact similarity multiplicities, Jordan orders, and subspaces\n");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
