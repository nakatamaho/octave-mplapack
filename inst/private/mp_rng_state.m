## SPDX-License-Identifier: BSD-2-Clause

function result = mp_rng_state (action, varargin)
  persistent current_state;

  if (isempty (current_state))
    [first, second] = __mplapack_core__ ("rng_seed", uint64 (0));
    current_state = mp_rng_make_state (first, second);
  endif

  switch (action)
    case "get"
      result = current_state;
    case "set"
      if (numel (varargin) != 1)
        error ("mplapack:rng:InvalidState", ...
               "rng state setter expects one state struct");
      endif
      current_state = mp_rng_validate_state (varargin{1});
      result = current_state;
    case "set_raw"
      if (numel (varargin) != 2)
        error ("mplapack:rng:InvalidState", ...
               "raw rng state setter expects two words");
      endif
      current_state = mp_rng_make_state (varargin{1}, varargin{2});
      result = current_state;
    otherwise
      error ("mplapack:rng:InvalidState", "unknown private rng action");
  endswitch
endfunction

function state = mp_rng_make_state (first, second)
  first = uint64 (first);
  second = uint64 (second);
  if (first == 0 && second == 0)
    error ("mplapack:rng:InvalidState", ...
           "rng state must not contain two zero words");
  endif
  state = struct ("algorithm", "xorshift128plus-v1", ...
                  "version", uint64 (1), ...
                  "state", uint64 ([first, second]));
endfunction

function state = mp_rng_validate_state (state)
  if (! isstruct (state) || ! isscalar (state)
      || ! isfield (state, "algorithm") || ! isfield (state, "version")
      || ! isfield (state, "state"))
    error ("mplapack:rng:InvalidState", ...
           "rng state must be a scalar versioned state struct");
  endif
  if (! ischar (state.algorithm) || ! strcmp (state.algorithm, ...
                                               "xorshift128plus-v1")
      || ! isa (state.version, "uint64") || state.version != uint64 (1)
      || ! isa (state.state, "uint64") || numel (state.state) != 2)
    error ("mplapack:rng:InvalidState", ...
           "unsupported rng algorithm, version, or state representation");
  endif
  if (state.state(1) == 0 && state.state(2) == 0)
    error ("mplapack:rng:InvalidState", ...
           "rng state must not contain two zero words");
  endif
  state.state = reshape (state.state, 1, 2);
endfunction
