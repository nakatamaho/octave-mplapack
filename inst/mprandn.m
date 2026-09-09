## SPDX-License-Identifier: BSD-2-Clause

function result = mprandn (varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{r} =} mprandn ()
  ## @deftypefnx {} {@var{r} =} mprandn (@var{n})
  ## @deftypefnx {} {@var{r} =} mprandn (@var{m}, @var{n})
  ## Generate deterministic standard-normal arbitrary-precision values.
  ## Box-Muller is evaluated entirely with MPFR operations.  This is a
  ## numerical PRNG, not a cryptographic generator.
  ## @end deftypefn
  [rows_out, columns_out] = mp_random_dimensions (varargin, "mprandn");
  state = mp_rng_state ("get");
  [payload, first, second] = __mplapack_core__ (
    "rng_normal", rows_out, columns_out, state.state(1), state.state(2));
  state.state = uint64 ([first, second]);
  mp_rng_state ("set", state);
  result = mp ("0");
  result.payload_ = payload;
endfunction
