## SPDX-License-Identifier: BSD-2-Clause

function info = mplapack_version ()
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{info} =} mplapack_version ()
  ## Report the loaded Octave, MPLAPACK, and MPFR backend versions.
  ## This diagnostic does not perform numerical conversion or change the
  ## current arbitrary-precision default. @seealso{mp, mpbits}
  ## @end deftypefn
  if (nargin != 0)
    print_usage ();
  endif

  info = __mplapack_core__ ("version");

  if (nargout == 0)
    printf ("Octave: %s\n", info.octave);
    printf ("MPLAPACK: %s\n", info.mplapack);
    printf ("Backend: %s\n", info.backend);
    printf ("MPFR: %s\n", info.mpfr);
    printf ("Probe: %s\n", info.probe_routine);
    printf ("Probe value: %.17g\n", info.probe_value);
    if (info.probe_ok)
      printf ("Probe result: PASS\n");
    else
      printf ("Probe result: FAIL\n");
    endif
  endif
endfunction
