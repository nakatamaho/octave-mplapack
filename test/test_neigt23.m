% NEIGT23: exact output, independent replay, tamper, and conflict gates.
test_root = fileparts (fileparts (mfilename ("fullpath")));
example_root = fullfile (test_root, "examples", "neig_tiers");
private_root = fullfile (example_root, "private");
inst_root = fullfile (test_root, "inst");
src_root = fullfile (test_root, "src");
addpath (example_root);
addpath (private_root);

saved_bits = mpbits ();
unwind_protect
  output_dir = tempname ();
  bundle = mp_neig_write_outputs ("smoke", output_dir, ...
                                  struct ("tier", "all", "plot", false));
  assert (bundle.ok && strcmp (bundle.status, "COMPLETE"));
  assert (bundle.ordinary.coverage.measured_eig_rows == 120);
  assert (bundle.replay.ok && ! bundle.replay.called_eig ...
          && ! bundle.replay.reconstructed_ideal_model);
  assert (exist (bundle.output.rows, "file") == 2);
  assert (exist (bundle.output.proof, "file") == 2);
  assert (exist (bundle.output.report, "file") == 2);
  assert (exist (fullfile (output_dir, "spectrum.png"), "file") == 0);
  rows_text = fileread (bundle.output.rows);
  assert (! isempty (strfind (rows_text, "case_id\tmode\twork_role")));
  assert (! isempty (strfind (fileread (bundle.output.report), ...
                              "NEIGT23_VS1_EXACT_REPLAY")) ...
          || ! isempty (strfind (fileread (bundle.output.report), ...
                                 "mp_neig_replay")));

  % A second writer invocation must not overwrite an existing directory.
  caught = false;
  try
    mp_neig_write_outputs ("smoke", output_dir, struct ("tier", "S", ...
                                                        "plot", false));
  catch exception
    caught = strcmp (exception.identifier, "mplapack:neigt:OutputExists");
  end_try_catch
  assert (caught);

  % Content tampering is detected before numerical replay.
  proof_text = fileread (bundle.output.proof);
  tampered = strcat (tempname (), ".json");
  handle = fopen (tampered, "w");
  fwrite (handle, strrep (proof_text, "VS1-01", "VS1-02"));
  fclose (handle);
  caught = false;
  try
    mp_neig_replay (tampered);
  catch exception
    caught = strcmp (exception.identifier, "mplapack:neigt:Deserialize");
  end_try_catch
  assert (caught);

  % The second process replays the same exact record without the capture path.
  replay_command = sprintf (["octave-cli --no-gui --quiet --no-init-file ", ...
    "--path \"%s\" --path \"%s\" --path \"%s\" --path \"%s\" --eval ", ...
    "\"r=mp_neig_replay('%s'); assert(r.ok); ", ...
    "assert(~r.called_eig && ~r.reconstructed_ideal_model);\""], ...
    inst_root, src_root, example_root, private_root, bundle.output.proof);
  [exit_status, replay_output] = system (replay_command);
  assert (exit_status == 0);
  assert (isempty (strfind (replay_output, "error:")));

  rmdir (output_dir, "s");
  unlink (tampered);
  fprintf ("PASS: NEIGT23 exact output, replay, tamper, conflict, and headless gates\n");
unwind_protect_cleanup
  mpbits (saved_bits);
  if (exist (output_dir, "dir")), rmdir (output_dir, "s"); endif
  if (exist (tampered, "file")), unlink (tampered); endif
  if (any (strcmp (strsplit (path (), pathsep), private_root)))
    rmpath (private_root);
  endif
  if (any (strcmp (strsplit (path (), pathsep), example_root)))
    rmpath (example_root);
  endif
end_unwind_protect
