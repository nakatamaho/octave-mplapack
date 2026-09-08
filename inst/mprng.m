## SPDX-License-Identifier: BSD-2-Clause

function result = mprng (varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{s} =} mprng ()
  ## @deftypefnx {} {@var{s} =} mprng ("state")
  ## @deftypefnx {} {@var{s} =} mprng ("state", @var{s})
  ## @deftypefnx {} {@var{s} =} mprng ("seed", @var{seed})
  ## @deftypefnx {} {@var{s} =} mprng ("reset")
  ## Return or update the versioned state of the package arbitrary-precision
  ## numerical random generator.  This is not a cryptographic generator.
  ## @end deftypefn
  if (nargin == 0 || (nargin == 1 && ischar (varargin{1})
                      && strcmp (varargin{1}, "state")))
    result = mp_rng_state ("get");
    return;
  endif

  if (! ischar (varargin{1}) || rows (varargin{1}) != 1)
    error ("mplapack:rng:InvalidState", ...
           "mprng command must be state, seed, or reset");
  endif
  command = varargin{1};
  switch (command)
    case "state"
      if (nargin != 2)
        error ("mplapack:rng:InvalidState", ...
               "mprng state setter expects one state struct");
      endif
      result = mp_rng_state ("set", varargin{2});
    case "seed"
      if (nargin != 2)
        error ("mplapack:rng:InvalidState", ...
               "mprng seed expects one nonnegative integer seed");
      endif
      seed = mp_rng_seed_value (varargin{2});
      [first, second] = __mplapack_core__ ("rng_seed", seed);
      result = mp_rng_state ("set_raw", first, second);
    case "reset"
      if (nargin != 1)
        error ("mplapack:rng:InvalidState", ...
               "mprng reset takes no arguments");
      endif
      [first, second] = __mplapack_core__ ("rng_seed", uint64 (0));
      result = mp_rng_state ("set_raw", first, second);
    otherwise
      error ("mplapack:rng:InvalidState", ...
             "mprng command must be state, seed, or reset");
  endswitch
endfunction

function seed = mp_rng_seed_value (value)
  if (! isnumeric (value) || islogical (value) || ! isreal (value)
      || ! isscalar (value))
    error ("mplapack:rng:InvalidState", ...
           "rng seed must be a nonnegative integer scalar");
  endif
  if (isinteger (value))
    if ((isa (value, "int8") || isa (value, "int16")
         || isa (value, "int32") || isa (value, "int64")) && value < 0)
      error ("mplapack:rng:InvalidState", ...
             "rng seed must be nonnegative");
    endif
    seed = uint64 (value);
    return;
  endif
  supplied = double (value);
  if (! isfinite (supplied) || supplied != fix (supplied) || supplied < 0
      || supplied > 9007199254740992)
    error ("mplapack:rng:InvalidState", ...
           "floating rng seeds must be exact nonnegative integers");
  endif
  seed = uint64 (supplied);
endfunction
