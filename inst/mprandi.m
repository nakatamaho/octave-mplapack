## SPDX-License-Identifier: BSD-2-Clause

function result = mprandi (varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{r} =} mprandi (@var{imax})
  ## @deftypefnx {} {@var{r} =} mprandi (@var{imax}, [@var{m} @var{n}])
  ## @deftypefnx {} {@var{r} =} mprandi (@var{imin}, @var{imax})
  ## @deftypefnx {} {@var{r} =} mprandi (@var{imin}, @var{imax}, [@var{m} @var{n}])
  ## Generate exact integer mp values using rejection sampling.  The one-
  ## argument form samples [0,imax]; two bounds sample [imin,imax].
  ## @end deftypefn
  if (nargin < 1 || nargin > 4)
    error ("mplapack:rng:InvalidArguments", ...
           "mprandi expects a bound and optional dimensions");
  endif

  lower = mp ("0");
  upper = [];
  dimensions = {};
  if (nargin == 1)
    upper = mp_rng_integer_bound (varargin{1}, "upper bound");
  elseif (nargin == 2 && mp_rng_is_dimension_vector (varargin{2}))
    upper = mp_rng_integer_bound (varargin{1}, "upper bound");
    dimensions = {varargin{2}};
  else
    lower = mp_rng_integer_bound (varargin{1}, "lower bound");
    upper = mp_rng_integer_bound (varargin{2}, "upper bound");
    if (nargin == 3)
      dimensions = {varargin{3}};
    elseif (nargin == 4)
      dimensions = {varargin{3}, varargin{4}};
    endif
  endif

  [rows_out, columns_out] = mp_random_dimensions (dimensions, "mprandi");
  state = mp_rng_state ("get");
  [payload, first, second] = __mplapack_core__ (
    "rng_integer", lower, upper, rows_out, columns_out,
    state.state(1), state.state(2));
  state.state = uint64 ([first, second]);
  mp_rng_state ("set", state);
  result = mp ("0");
  result.payload_ = payload;
endfunction

function result = mp_rng_is_dimension_vector (value)
  result = isnumeric (value) && ! islogical (value) && isreal (value) ...
           && numel (value) == 2;
endfunction

function result = mp_rng_integer_bound (value, description)
  if (isa (value, "mp"))
    if (! isreal (value) || ! isscalar (value) || isnan (value)
        || ! isfinite (value) || value != fix (value))
      error ("mplapack:rng:InvalidBound", ...
             "%s must be a finite exact integer mp scalar", description);
    endif
    result = value;
    return;
  endif
  if (! isnumeric (value) || islogical (value) || ! isreal (value)
      || ! isscalar (value) || ! isfinite (value) || value != fix (value))
    error ("mplapack:rng:InvalidBound", ...
           "%s must be a finite integer scalar", description);
  endif
  result = mp (value);
endfunction
