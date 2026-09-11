% NEIGT13: outward primitive, rectangle, range, and exact replay checks.
test_root = fileparts (fileparts (mfilename ("fullpath")));
private_root = fullfile (test_root, "examples", "neig_tiers", "private");
addpath (private_root);

saved_bits = mpbits ();
unwind_protect
  for q = [64, 128, 256]
    mpbits (q);
    one = mp (1);
    three = mp (3);
    quotient = net_iv_primitive ("div", one, three, q);
    assert (three * quotient.lo <= one);
    assert (three * quotient.hi >= one);

    radical = net_iv_primitive ("sqrt", mp (2), mp (0), q);
    assert (radical.lo * radical.lo <= mp (2));
    assert (radical.hi * radical.hi >= mp (2));

    cancellation = net_iv_primitive ("add", one, -one, q);
    assert (cancellation.lo == mp (0) && cancellation.hi == mp (0));
    caught = false;
    try
      net_iv_round (mp (0), q, false, "adversarial-zero");
    catch
      caught = true;
    end_try_catch
    assert (caught);
  endfor

  q = 256;
  mpbits (q);
  real_box = net_iv_point (mp ("1.25"), q);
  complex_box = net_iv_complex_point (net_mp_complex (mp ("1.25"), mp ("-0.75")), q);
  product = net_iv_complex_mul (complex_box, ...
    net_iv_complex_point (net_mp_complex (mp ("-2"), mp ("0.5")), q), q);
  conjugated = net_iv_complex_conj (complex_box);
  assert (conjugated.il == -complex_box.ih && conjugated.ih == -complex_box.il);
  modulus = net_iv_complex_abs (complex_box, q);
  assert (modulus.lo >= mp (0) && modulus.hi >= modulus.lo);
  assert (product.rl <= mp ("-2.125") && product.rh >= mp ("-2.125"));

  matrix = mp ([2, 1; -1, 3]) + net_mp_complex (mp (0), mp (0));
  inverse_candidate = mp ([3, -1; 1, 2]) / mp (7);
  inverse_witness = net_iv_inverse_residual (matrix, inverse_candidate, q);
  assert (inverse_witness.nonsingular);
  assert (inverse_witness.e < mp ("0.01"));
  product_box = net_iv_cmatrix_mul (net_iv_cmatrix_point (matrix, q), ...
                                    net_iv_cmatrix_point (inverse_candidate, q), q);
  assert (product_box.rl(1,1) <= mp (1) && product_box.rh(1,1) >= mp (1));
  assert (net_iv_cmatrix_inf_upper (product_box, q) > mp (0));
  assert (net_iv_cmatrix_fro_upper (product_box, q) > mp (0));

  caught = false;
  try
    net_iv_primitive ("div", mp (1), mp (0), q);
  catch
    caught = true;
  end_try_catch
  assert (caught);
  caught = false;
  try
    net_iv_real_sqrt (net_iv_real (mp ("-1"), mp ("1")), q);
  catch
    caught = true;
  end_try_catch
  assert (caught);
  caught = false;
  try
    net_iv_primitive ("add", net_pow2 (-9000, q), mp (0), q);
  catch
    caught = true;
  end_try_catch
  assert (caught);

  tiny = net_pow2 (-1500, q);
  dyadic = net_dyadic_encode_matrix ...
    (mp ([1, -2; 3, 4]) + tiny * mp ([0, 1; -1, 0]), q);
  witness = strcat (tempname (), ".json");
  net_dyadic_write_json (dyadic, witness);
  loaded = net_dyadic_read_json (witness);
  decoded = net_dyadic_decode_matrix (loaded, 512);
  assert (isequal (size (decoded), [2, 2]));
  for index = 1:numel (decoded)
    assert (isequal (net_dyadic_encode_scalar (decoded(index), 512), ...
                     dyadic.values{index}));
  endfor

  caught = false;
  tampered = strcat (tempname (), ".json");
  text = fileread (witness);
  text = strrep (text, "neigt-dyadic-v1", "neigt-dyadic-tampered");
  h = fopen (tampered, "w");
  fwrite (h, text);
  fclose (h);
  try
    net_dyadic_read_json (tampered);
  catch
    caught = true;
  end_try_catch
  assert (caught);

  caught = false;
  try
    net_dyadic_decode_matrix (loaded, q - 1);
  catch
    caught = true;
  end_try_catch
  assert (caught);
  fprintf ("PASS: NEIGT13 outward primitives, complex rectangles, range checks, and replay hash\n");
unwind_protect_cleanup
  mpbits (saved_bits);
  if (any (strcmp (strsplit (path (), pathsep), private_root)))
    rmpath (private_root);
  endif
end_unwind_protect
