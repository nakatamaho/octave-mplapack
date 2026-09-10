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
    else
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

function answer = is_power_of_two (n)
  answer = false;
  k = 1;
  while (k < n)
    k = k * 2;
  endwhile
  answer = (k == n);
endfunction
