% Focused NEIGT02 exact construction and widening test.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "neig_tiers"));
addpath (fullfile (test_root, "examples", "neig_tiers", "private"));
saved_bits = mpbits ();
unwind_protect
  mpbits (512);
  pair = net_exact_similarity (8, 512);
  assert (pair.exact && pair.xy_error == mp (0) && pair.yx_error == mp (0));
  H = net_hadamard (8, 512);
  assert (norm (H * ctranspose (H) - 8 * mp (eye (8)), "fro") == mp (0));
  fixture = net_similarity_model ("jordan", 8, 24, 512);
  assert (fixture.model_products_exact);
  assert (norm (fixture.similarity.X * fixture.A_model ...
                - fixture.J * fixture.similarity.X, "fro") == mp (0));
  before = fixture.A_frozen;
  mpbits (1024);
  widened = net_widen (fixture.A_frozen, 1024, 512);
  assert (norm (widened - fixture.A_frozen, "fro") == mp (0));
  assert (norm (fixture.A_frozen - before, "fro") == mp (0));
  for setting = {[1024, 700], [2048, 1500]}
    mpbits (setting{1}(1));
    tiny = net_pow2 (-setting{1}(2), setting{1}(1));
    widened_tiny = net_widen (tiny, setting{1}(1), setting{1}(1));
    assert (widened_tiny != mp (0));
  endfor
  caught = false;
  try
    net_widen (fixture.A_frozen, 256, 512);
  catch
    caught = true;
  end_try_catch
  assert (caught);
  fprintf ("PASS: NEIGT02 exact similarities, Hadamard, guards, widening, and tails\n");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
