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
