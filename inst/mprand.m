## SPDX-License-Identifier: BSD-2-Clause

function result = mprand (varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{r} =} mprand ()
  ## @deftypefnx {} {@var{r} =} mprand (@var{n})
  ## @deftypefnx {} {@var{r} =} mprand (@var{m}, @var{n})
  ## Generate deterministic uniform arbitrary-precision values on [0,1).
  ## The current @code{mpbits} default selects the output precision.
  ## @end deftypefn
  [rows_out, columns_out] = mp_random_dimensions (varargin, "mprand");
  state = mp_rng_state ("get");
  [payload, first, second] = __mplapack_core__ (
    "rng_uniform", rows_out, columns_out, state.state(1), state.state(2));
  state.state = uint64 ([first, second]);
  mp_rng_state ("set", state);
  result = mp ("0");
  result.payload_ = payload;
endfunction
