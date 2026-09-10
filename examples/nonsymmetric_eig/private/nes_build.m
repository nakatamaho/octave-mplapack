% Exact mathematical constructors used by the nonsymmetric eigensystem suite.
function result = nes_build (family, parameters, work_bits)
  if (nargin != 3 || ! ischar (family) || ! isstruct (parameters))
    error ("NEIG:BuildArguments", "nes_build expects a family, parameter struct, and precision");
  endif
  if (! (isnumeric (work_bits) && isscalar (work_bits) && isreal (work_bits)
         && isfinite (work_bits) && work_bits == fix (work_bits)
         && work_bits >= 1))
    error ("NEIG:BuildPrecision", "work precision must be a positive integer");
  endif
  if (strcmp (family, "hadamard"))
    if (! isfield (parameters, "n") || ! isfield (parameters, "s"))
      error ("NEIG:BuildParameters", "Hadamard construction requires n and s");
    endif
    n = parameters.n;
    s = parameters.s;
    if (! (isnumeric (n) && isscalar (n) && isreal (n) && isfinite (n)
           && n == fix (n) && n >= 1 && is_power_of_two (n)))
      error ("NEIG:BuildParameters", "Hadamard n must be a positive power of two");
    endif
    if (! (isnumeric (s) && isscalar (s) && isreal (s) && isfinite (s)
           && s == fix (s) && s >= 1))
      error ("NEIG:BuildParameters", "Hadamard s must be a positive integer");
    endif
  elseif (strcmp (family, "frank"))
    if (! isfield (parameters, "n"))
      error ("NEIG:BuildParameters", "Frank construction requires n");
    endif
    n = parameters.n;
    if (! (isnumeric (n) && isscalar (n) && isreal (n) && isfinite (n)
           && n == fix (n) && n >= 2))
      error ("NEIG:BuildParameters", "Frank n must be an integer at least two");
    endif
  elseif (strcmp (family, "companion"))
    if (! isfield (parameters, "n"))
      error ("NEIG:BuildParameters", "companion construction requires n");
    endif
    n = parameters.n;
    if (! (isnumeric (n) && isscalar (n) && isreal (n) && isfinite (n)
           && n == fix (n) && n >= 1))
      error ("NEIG:BuildParameters", "companion n must be a positive integer");
    endif
    if (work_bits < nes_companion_min_bits (n))
      error ("NEIG:BuildPrecision", ...
             "companion work precision is below its exact-coefficient guard");
    endif
  elseif (strcmp (family, "forsythe"))
    if (! isfield (parameters, "n") || ! isfield (parameters, "a")
        || ! isfield (parameters, "representation"))
      error ("NEIG:BuildParameters", ...
             "Forsythe construction requires n, a, and representation");
    endif
    n = parameters.n;
    a = parameters.a;
    representation = parameters.representation;
    if (! (isnumeric (n) && isscalar (n) && isreal (n) && isfinite (n)
           && n == fix (n) && n >= 3))
      error ("NEIG:BuildParameters", "Forsythe n must be an integer at least three");
    endif
    if (! (isnumeric (a) && isscalar (a) && isreal (a) && isfinite (a)
           && a == fix (a) && a >= 1))
      error ("NEIG:BuildParameters", "Forsythe a must be a positive integer");
    endif
    if (! any (strcmp (representation, {"original", "explicitly_scaled"})))
      error ("NEIG:BuildParameters", "invalid Forsythe representation");
    endif
  else
    error ("NEIG:BuildFamily", "family is not implemented by the current milestone");
  endif

  saved_bits = mpbits ();
  unwind_protect
    mpbits (work_bits);
    if (strcmp (family, "hadamard"))
      H_native = nes_hadamard_native (n);
      T = mp (zeros (n, n));
      for k = 1:n
        T(k, k) = mp (k);
        if (k < n)
          T(k, k + 1) = mp (s);
        endif
      endfor
      H = mp (H_native);
      A = (H * T * transpose (H)) / n;
      result = struct ("family", family, "representation", "hadamard_similar", ...
                       "n", n, "s", s, "H", H, "T", T, "A", A, ...
                       "work_bits", work_bits, "native_A", ...
                       nes_hadamard_native_matrix (n, s), ...
                       "native_exact_bound", n * (n + s), ...
                       "native_exact_safe", n * (n + s) < 2^53);
    elseif (strcmp (family, "frank"))
      A = mp (zeros (n, n));
      for i = 1:n
        for j = 1:n
          if (j >= i - 1)
            A(i, j) = mp (n + 1 - max (i, j));
          endif
        endfor
      endfor
      result = struct ("family", family, "representation", "frank", ...
                       "n", n, "A", A, "work_bits", work_bits, ...
                       "native_A", nes_frank_native_matrix (n));
    elseif (strcmp (family, "companion"))
      coefficients = nes_companion_coefficients (n, work_bits);
      A = mp (zeros (n, n));
      for j = 1:n
        A(1, j) = -coefficients(j + 1);
      endfor
      for i = 2:n
        A(i, i - 1) = mp ("1");
      endfor
      result = struct ("family", family, "representation", "companion", ...
                       "n", n, "A", A, "coefficients", coefficients, ...
                       "work_bits", work_bits, "native_A", ...
                       nes_companion_native_matrix (n, work_bits));
    else
      radius = mp ("1");
      for k = 1:a
        radius = radius * mp ("0.5");
      endfor
      epsilon = mp ("1");
      for k = 1:(a * n)
        epsilon = epsilon * mp ("0.5");
      endfor
      original = mp (eye (n));
      for k = 1:(n - 1)
        original(k, k + 1) = mp ("1");
      endfor
      original(n, 1) = epsilon;
      shift = mp (zeros (n, n));
      for k = 1:(n - 1)
        shift(k, k + 1) = mp ("1");
      endfor
      shift(n, 1) = mp ("1");
      scaled = mp (eye (n)) + radius * shift;
      scaling = mp (zeros (n, n));
      power = mp ("1");
      for k = 1:n
        scaling(k, k) = power;
        power = power * radius;
      endfor
      if (strcmp (representation, "original"))
        A = original;
      else
        A = scaled;
      endif
      result = struct ("family", family, "representation", representation, ...
                       "n", n, "a", a, "radius", radius, ...
                       "epsilon", epsilon, "A", A, "original_A", original, ...
                       "scaled_A", scaled, "scaling", scaling, ...
                       "native_A", nes_forsythe_native_matrix (n, a, representation), ...
                       "native_epsilon", 2^(-(a * n)), ...
                       "native_underflow", 2^(-(a * n)) == 0);
    endif
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function answer = nes_hadamard_native (n)
  answer = 1;
  while (rows (answer) < n)
    answer = [answer, answer; answer, -answer];
  endwhile
endfunction

function answer = nes_hadamard_native_matrix (n, s)
  H = nes_hadamard_native (n);
  T = diag (1:n) + s * diag (ones (n - 1, 1), 1);
  answer = H * T * transpose (H) / n;
endfunction

function answer = nes_frank_native_matrix (n)
  answer = zeros (n, n);
  for i = 1:n
    for j = 1:n
      if (j >= i - 1)
        answer(i, j) = n + 1 - max (i, j);
      endif
    endfor
  endfor
endfunction

function answer = nes_companion_native_matrix (n, bits)
  coefficients = double (nes_companion_coefficients (n, bits));
  answer = zeros (n, n);
  answer(1, :) = -coefficients(2:end);
  for i = 2:n
    answer(i, i - 1) = 1;
  endfor
endfunction

function answer = nes_forsythe_native_matrix (n, a, representation)
  radius = 2^(-a);
  epsilon = 2^(-(a * n));
  shift = zeros (n, n);
  for k = 1:(n - 1)
    shift(k, k + 1) = 1;
  endfor
  shift(n, 1) = 1;
  if (strcmp (representation, "original"))
    answer = eye (n) + shift;
    answer(n, 1) = epsilon;
  else
    answer = eye (n) + radius * shift;
  endif
endfunction

function answer = is_power_of_two (n)
  answer = false;
  k = 1;
  while (k < n)
    k = k * 2;
  endwhile
  answer = (k == n);
endfunction
