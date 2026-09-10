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

    small_reference = nes_reference ("hadamard", struct ("n", 2, "s", 1), 512);
    assert (double (small_reference.condition_numbers(1)) == sqrt (2));
    assert (double (small_reference.condition_numbers(2)) == sqrt (2));

    frank5 = nes_build ("frank", struct ("n", 5), 512);
    expected_frank5 = mp ([5, 4, 3, 2, 1; 4, 4, 3, 2, 1; ...
                           0, 3, 3, 2, 1; 0, 0, 2, 2, 1; ...
                           0, 0, 0, 1, 1]);
    assert (double (norm (frank5.A - expected_frank5, "fro")) == 0);
    expected_coefficients = {[1, -3, 1], [1, -6, 6, -1], ...
                             [1, -10, 21, -10, 1], ...
                             [1, -15, 55, -55, 15, -1]};
    for degree = 2:5
      coefficients = nes_frank_characteristic_coefficients (degree, 512);
      assert (double (norm (coefficients - mp (expected_coefficients{degree - 1}))) == 0);
      for x = -1:6
        polynomial_value = mp ("0");
        for coefficient = 1:(degree + 1)
          polynomial_value = polynomial_value * mp (x) + coefficients(coefficient);
        endfor
        matrix = nes_build ("frank", struct ("n", degree), 512).A;
        determinant = nes_exact_small_determinant (mp (x) * mp (eye (degree)) - matrix);
        assert (polynomial_value == determinant);
      endfor
    endfor
    frank_reference = nes_reference ("frank", struct ("n", 8), 640, 512);
    assert (strcmp (frank_reference.reference_status, "evaluated_consistent"));
    assert (isreal (frank_reference.eigenvalues));
    assert (all (isfinite (frank_reference.eigenvalues)));
    for j = 1:4
      assert (abs (frank_reference.eigenvalues(j) ...
                   * frank_reference.eigenvalues(9 - j) - mp ("1")) < mp ("1e-150"));
    endfor
    odd_reference = nes_reference ("frank", struct ("n", 7), 640, 512);
    assert (abs (odd_reference.eigenvalues(4) - mp ("1")) < mp ("1e-150"));

    companion4 = nes_companion_coefficients (4, 512);
    assert (double (norm (companion4 - mp ([1, -10, 35, -50, 24]))) == 0);
    for degree = [10, 20]
      low_coefficients = nes_companion_coefficients (degree, 128);
      high_coefficients = nes_companion_coefficients (degree, 512);
      widened_coefficients = nes_promote (low_coefficients, 512, 128);
      assert (double (norm (widened_coefficients - high_coefficients)) == 0);
      q_check = 2 * degree * nes_ceil_log2_integer (degree + 1) + 32;
      check_coefficients = nes_companion_coefficients (degree, q_check);
      for root = 1:degree
        polynomial_value = mp ("0");
        for coefficient = 1:(degree + 1)
          polynomial_value = polynomial_value * mp (root) ...
                             + check_coefficients(coefficient);
        endfor
        assert (polynomial_value == mp ("0"));
      endfor
    endfor
    exact20 = nes_companion_coefficients (20, 512);
    native20 = mp (poly (1:20));
    assert (double (norm (native20 - exact20)) > 0);
    saved_for_guard = mpbits ();
    caught = false;
    try
      nes_companion_coefficients (20, nes_companion_min_bits (20) - 1);
    catch
      caught = true;
    end_try_catch
    assert (caught && mpbits () == saved_for_guard);
    companion_fixture = nes_build ("companion", struct ("n", 20), 512);
    native_fixture_q = nes_promote (companion_fixture.native_A, 768, 53);
    exact_fixture_q = nes_promote (companion_fixture.A, 768, 512);
    assert (norm (native_fixture_q - exact_fixture_q, "fro") > mp ("0"));

    for representation = {"original", "explicitly_scaled"}
      forsythe_parameters = struct ("n", 8, "a", 4, ...
                                    "representation", representation{1});
      forsythe_fixture = nes_build ("forsythe", forsythe_parameters, 512);
      assert (strcmp (forsythe_fixture.representation, representation{1}));
      assert (forsythe_fixture.epsilon == mp ("2")^(-32));
      assert (forsythe_fixture.radius == mp ("2")^(-4));
      assert (all (isfinite (forsythe_fixture.A)));
      if (strcmp (representation{1}, "original"))
        assert (norm (forsythe_fixture.A * forsythe_fixture.A' ...
                      - forsythe_fixture.A' * forsythe_fixture.A, "fro") > mp ("0"));
      else
        assert (norm (forsythe_fixture.A * forsythe_fixture.A' ...
                      - forsythe_fixture.A' * forsythe_fixture.A, "fro") == mp ("0"));
      endif
    endfor
    original_forsythe = nes_build ("forsythe", ...
                                   struct ("n", 8, "a", 4, ...
                                           "representation", "original"), 512);
    scaled_forsythe = nes_build ("forsythe", ...
                                 struct ("n", 8, "a", 4, ...
                                         "representation", "explicitly_scaled"), 512);
    assert (norm (original_forsythe.A * original_forsythe.scaling ...
                  - original_forsythe.scaling * scaled_forsythe.A, "fro") == mp ("0"));
    forsythe_even_reference = nes_reference ("forsythe", ...
                                             struct ("n", 8, "a", 4, ...
                                                     "representation", "original"), ...
                                             640, 512);
    assert (strcmp (forsythe_even_reference.reference_status, ...
                    "evaluated_consistent"));
    assert (all (isfinite (forsythe_even_reference.eigenvalues)));
    assert (all (abs (abs (forsythe_even_reference.unit_roots)) ...
                 - mp ("1") < mp ("1e-150")));
    assert (abs (forsythe_even_reference.eigenvalues(1) ...
                 - (mp ("1") + mp ("2")^(-4))) < mp ("1e-150"));
    assert (abs (forsythe_even_reference.eigenvalues(5) ...
                 - (mp ("1") - mp ("2")^(-4))) < mp ("1e-150"));
    forsythe_odd_reference = nes_reference ("forsythe", ...
                                            struct ("n", 7, "a", 4, ...
                                                    "representation", "original"), ...
                                            640, 512);
    assert (abs (forsythe_odd_reference.eigenvalues(1) ...
                 - (mp ("1") + mp ("2")^(-4))) < mp ("1e-150"));
    assert (abs (forsythe_odd_reference.eigenvalues(2) ...
                 - conj (forsythe_odd_reference.eigenvalues(7))) < mp ("1e-150"));
    high_a_forsythe = nes_build ("forsythe", ...
                                 struct ("n", 20, "a", 80, ...
                                         "representation", "original"), 2048);
    assert (high_a_forsythe.epsilon > mp ("0"));
    assert (high_a_forsythe.native_underflow);
    high_a_scaled = nes_build ("forsythe", ...
                               struct ("n", 20, "a", 80, ...
                                       "representation", "explicitly_scaled"), 2048);
    assert (high_a_scaled.A(1, 2) == mp ("2")^(-80));

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
    assert (mpbits () == uint64 (333));

    fprintf ("PASS: NEIG06 Forsythe constructors, references, and precision isolation\n");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
