% Focused NEIGT04 Ozaki--Ogita generator test.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "neig_tiers"));
addpath (fullfile (test_root, "examples", "neig_tiers", "private"));
saved_bits = mpbits ();
unwind_protect
  kinds = {"OO53_REAL", "OO53_PAIR", "OO128_CLOSE"};
  dimensions = [8, 16];
  hashes = cell (numel (kinds), numel (dimensions));
  for kind_index = 1:numel (kinds)
    for dimension_index = 1:numel (dimensions)
      kind = kinds{kind_index};
      n = dimensions(dimension_index);
      model = net_oo_generator (kind, n);
      assert (model.generation_bits == 53 || model.generation_bits == 128);
      assert (model.theorem_predicate);
      assert (model.xy_exact && model.yx_exact && model.products_exact);
      assert (model.quantization_changed);
      assert (strcmp (model.method, ...
                      "fixed_precision_two_step_RN_triple_product_v1"));
      assert (model.A == model.A_exact);
      assert (any (model.S_requested(:) == mp (0)));
      if (strcmp (kind, "OO53_PAIR"))
        assert (any (model.S_requested(:) < mp (0)));
      endif
      pair = net_oo_validate_pair (model.X, model.Y, model.generation_bits);
      assert (pair.valid);
      hashes{kind_index, dimension_index} = model.model_hash;
      repeat = net_oo_generator (kind, n);
      assert (strcmp (repeat.model_hash, model.model_hash));
      assert (repeat.A == model.A);
      if (strcmp (kind, "OO53_PAIR"))
        for block = 0:(n / 2 - 1)
          first = 2 * block + 1;
          assert (model.S_realized(first + 1, first + 1) ...
                  == model.S_realized(first, first));
          assert (model.S_realized(first + 1, first) ...
                  == -model.S_realized(first, first + 1));
        endfor
        assert (any (model.S_realized(2:2:n, 1:2:n) != mp (0)));
      elseif (strcmp (kind, "OO128_CLOSE"))
        assert (model.realized_gap == net_pow2 (-80, 128));
        assert (model.S_requested(2, 2) - model.S_requested(1, 1) ...
                == net_pow2 (-80, 128) + net_pow2 (-120, 128));
        assert (model.S_realized(2, 2) != model.S_requested(2, 2));
      endif
    endfor
  endfor

  bad_Y = model.Y;
  bad_Y(1, 1) = bad_Y(1, 1) + mp (1);
  caught = false;
  try
    net_oo_validate_pair (model.X, bad_Y, model.generation_bits);
  catch
    caught = true;
  end_try_catch
  assert (caught);

  caught = false;
  try
    net_exact_product_dyadic (mp ("0.1"), mp (1), 128);
  catch
    caught = true;
  end_try_catch
  assert (caught);
  fprintf ("PASS: NEIGT04 Ozaki--Ogita exact triple-product generator and paired rule\n");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
