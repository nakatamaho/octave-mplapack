% Focused NEIG self-tests; this function uses only the public mp interface.
function mp_eig_suite_selftest ()
  helper_dir = fileparts (mfilename ("fullpath"));
  addpath (helper_dir);
  saved_bits = mpbits ();
  unwind_protect
    mpbits (256);
    fixture = nes_build ("hadamard", struct ("n", 8, "s", 16), 256);
    H = fixture.H;
    assert (double (norm (H * transpose (H) - 8 * eye (8), "fro")) == 0);
    assert (double (norm (tril (fixture.A, -1), "fro")) > 0);
    assert (double (norm (triu (fixture.A, 1), "fro")) > 0);
    assert (double (norm (fixture.A - transpose (fixture.A), "fro")) > 0);

    native_as_mp = mp (fixture.native_A);
    assert (double (norm (native_as_mp - fixture.A, "fro")) == 0);
    reference = nes_reference ("hadamard", struct ("n", 8, "s", 16), 512);
    assert (double (norm (reference.eigenvalues - mp (transpose (1:8)), "fro")) == 0);

    before = fixture.A;
    mpbits (1024);
    promoted = nes_promote (fixture.A, 1024, 256);
    assert (double (norm (promoted - fixture.A, "fro")) == 0);
    assert (double (norm (fixture.A - before, "fro")) == 0);

    for setting_index = 1:2
      if (setting_index == 1)
        setting = [1024, 700];
      else
        setting = [2048, 1500];
      endif
      mpbits (setting(1));
      tiny = mp ("1");
      for k = 1:setting(2)
        tiny = tiny * mp ("0.5");
      endfor
      widened = nes_promote (tiny, setting(1), setting(1));
    assert (! strcmp (char (widened), "0"));
    endfor

    one = mp ("1");
    match = nes_match (mp ([3; 1; 2]), mp ([1; 2; 3]), "absolute");
    assert (double (match.threshold) == 0);
    assert (match.mapping, [3, 1, 2]);
    duplicate = nes_match (mp ([0; 0; 2]), mp ([0; 1; 2]), "absolute");
    assert (double (duplicate.threshold) == 1);
    augment = nes_match (mp ([2; 0]), mp ([1; 3]), "absolute");
    assert (double (augment.threshold) == 1);
    circle_reference = mp (zeros (1, 4));
    circle_reference(1) = mp ("1", "0");
    circle_reference(2) = mp ("0", "1");
    circle_reference(3) = mp ("-1", "0");
    circle_reference(4) = mp ("0", "-1");
    circle_computed = circle_reference([3, 1, 4, 2]);
    circle_match = nes_match (circle_computed, circle_reference, "circle", ...
                              mp ("0"), one);
    assert (double (circle_match.threshold) == 0);

    for setting_index = 1:2
      if (setting_index == 1)
        precision = 1024; exponent = 700;
      else
        precision = 2048; exponent = 1500;
      endif
      mpbits (precision);
      tiny = mp ("1");
      for k = 1:exponent, tiny = tiny * mp ("0.5"); endfor
      near = mp (zeros (2, 1));
      near(1) = mp ("0"); near(2) = tiny;
      tiny_match = nes_match (near, mp (zeros (2, 1)), "absolute");
      assert (tiny_match.threshold == tiny);
    endfor

    mpbits (512);
    rotation = mp ([0, 1; -1, 0]);
    [V, D, W] = eig (rotation, "nobalance");
    values = nes_promote (diag (D), 768, 512);
    metrics = nes_metrics (nes_promote (rotation, 768, 512), ...
                           nes_promote (V, 768, 512), ...
                           nes_promote (D, 768, 512), ...
                           nes_promote (W, 768, 512), values);
    assert (metrics.right_residual < mp ("1e-200"));
    assert (metrics.left_residual < mp ("1e-200"));

    scaled_metrics = nes_metrics (nes_promote (rotation, 768, 512), ...
                                  nes_promote (V * mp ("2"), 768, 512), ...
                                  nes_promote (D, 768, 512), ...
                                  nes_promote (W * mp ("3"), 768, 512), values);
    assert (norm (metrics.condition_estimates ...
                  - scaled_metrics.condition_estimates) < mp ("1e-200"));
    W_bad = W(:, [2, 1]);
    bad_metrics = nes_metrics (nes_promote (rotation, 768, 512), ...
                               nes_promote (V, 768, 512), ...
                               nes_promote (D, 768, 512), ...
                               nes_promote (W_bad, 768, 512), values);
    assert (bad_metrics.left_residual > mp ("1e-5"));
    V_bad = V;
    V_bad(1, 1) = V_bad(1, 1) + mp ("1e-3");
    perturbed_metrics = nes_metrics (nes_promote (rotation, 768, 512), ...
                                     nes_promote (V_bad, 768, 512), ...
                                     nes_promote (D, 768, 512), ...
                                     nes_promote (W, 768, 512), values);
    assert (perturbed_metrics.right_residual > mp ("1e-6"));

    exhaustive_values = mp (transpose (1:6));
    permutations = perms (1:6);
    for permutation_row = 1:rows (permutations)
      candidate = exhaustive_values(permutations(permutation_row, :));
      exhaustive_match = nes_match (candidate, exhaustive_values, "absolute");
      assert (exhaustive_match.threshold == mp ("0"));
    endfor

    caught = false;
    try
      nes_match (mp (zeros (0, 1)), mp (zeros (0, 1)), "absolute");
    catch
      caught = true;
    end_try_catch
    assert (caught);
    caught = false;
    try
      nes_match (mp ([0; 1]), mp ([0; 0]), "relative");
    catch
      caught = true;
    end_try_catch
    assert (caught);
    caught = false;
    try
      nes_match (mp ([NaN; 1]), mp ([0; 1]), "absolute");
    catch
      caught = true;
    end_try_catch
    assert (caught);

    mpbits (333);
    assert (mpbits () == uint64 (333));
    caught = false;
    try
      mp_eig_suite ("smoke", struct ("family", "all"));
    catch
      caught = true;
    end_try_catch
    assert (caught);
    assert (mpbits () == uint64 (333));

    fprintf ("PASS: NEIG01 constructors, promotion, and precision isolation\n");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
