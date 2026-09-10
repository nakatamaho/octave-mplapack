% Independent references for the nonsymmetric eigensystem suite.
function result = nes_reference (family, parameters, reference_bits, reference_low_bits)
  if (nargin < 3 || nargin > 4 || ! ischar (family) || ! isstruct (parameters))
    error ("NEIG:ReferenceArguments", ...
           "nes_reference expects a family, parameter struct, and precision");
  endif
  if (! any (strcmp (family, {"hadamard", "frank", "companion", "forsythe"})))
    error ("NEIG:ReferenceFamily", "family reference is not implemented yet");
  endif
  n = parameters.n;
  if (! (isnumeric (reference_bits) && isscalar (reference_bits)
         && isreal (reference_bits) && isfinite (reference_bits)
         && reference_bits == fix (reference_bits) && reference_bits >= 1))
    error ("NEIG:ReferencePrecision", "reference precision must be a positive integer");
  endif

  saved_bits = mpbits ();
  unwind_protect
    mpbits (reference_bits);
    if (strcmp (family, "hadamard"))
      values = mp (transpose (1:n));
      condition_numbers = mp (zeros (n, 1));
      for root = 1:n
        left_sum = mp ("1");
        term = mp ("1");
        for j = 1:(root - 1)
          term = term * mp (parameters.s) / mp (j);
          left_sum = left_sum + term * term;
        endfor
        right_sum = mp ("1");
        term = mp ("1");
        for j = 1:(n - root)
          term = term * mp (parameters.s) / mp (j);
          right_sum = right_sum + term * term;
        endfor
        condition_numbers(root) = sqrt (left_sum) * sqrt (right_sum);
      endfor
      result = struct ("family", family, "reference_status", "analytic_exact", ...
                       "reference_bits", reference_bits, "eigenvalues", values, ...
                       "condition_numbers", condition_numbers);
    elseif (strcmp (family, "frank"))
      if (nargin == 4)
        low_bits = reference_low_bits;
      else
        low_bits = reference_bits - 128;
      endif
      if (! (isnumeric (low_bits) && isscalar (low_bits) && isreal (low_bits)
             && isfinite (low_bits) && low_bits == fix (low_bits)
             && low_bits >= 1 && low_bits < reference_bits))
        error ("NEIG:ReferencePrecision", ...
               "low Frank reference precision must be below high reference precision");
      endif
      low_values = nes_frank_reference_at (parameters.n, low_bits);
      values = nes_frank_reference_at (parameters.n, reference_bits);
      promoted_low = nes_promote (low_values, reference_bits, low_bits);
      agreement = nes_match (values, promoted_low, "relative");
      agreement_limit = nes_reference_power (floor (low_bits / 2), reference_bits);
      if (agreement.threshold <= agreement_limit)
        status = "evaluated_consistent";
      else
        status = "unresolved";
      endif
      result = struct ("family", family, "reference_status", status, ...
                       "reference_bits", reference_bits, "low_reference_bits", ...
                       low_bits, "eigenvalues", values, "condition_numbers", ...
                       mp ("NaN"), "reference_agreement", agreement.threshold, ...
                       "reference_agreement_limit", agreement_limit);
    elseif (strcmp (family, "companion"))
      values = mp (transpose (1:n));
      result = struct ("family", family, "reference_status", "analytic_exact", ...
                       "reference_bits", reference_bits, "eigenvalues", values, ...
                       "condition_numbers", mp ("NaN"));
    else
      if (nargin == 4)
        low_bits = reference_low_bits;
      else
        low_bits = reference_bits - 128;
      endif
      low = nes_forsythe_reference_at (parameters.n, parameters.a, low_bits);
      high = nes_forsythe_reference_at (parameters.n, parameters.a, reference_bits);
      low_units = nes_promote (low.unit_roots, reference_bits, low_bits);
      agreement = nes_match (high.unit_roots, low_units, "absolute");
      agreement_limit = nes_reference_power (floor (low_bits / 2), reference_bits);
      if (agreement.threshold <= agreement_limit)
        status = "evaluated_consistent";
      else
        status = "unresolved";
      endif
      result = struct ("family", family, "reference_status", status, ...
                       "reference_bits", reference_bits, "low_reference_bits", ...
                       low_bits, "eigenvalues", high.eigenvalues, ...
                       "unit_roots", high.unit_roots, "radius", high.radius, ...
                       "reference_agreement", agreement.threshold, ...
                       "reference_agreement_limit", agreement_limit, ...
                       "condition_numbers", mp ("NaN"));
    endif
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function result = nes_forsythe_reference_at (n, a, bits)
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    radius = nes_reference_power (a, bits);
    unit_roots = mp (complex (zeros (n, 1), zeros (n, 1)));
    eigenvalues = unit_roots;
    pi_value = acos (mp ("-1"));
    for k = 0:floor (n / 2)
      if (k == 0)
        real_part = mp ("1");
        imaginary_part = mp ("0");
      else
        angle = mp ("2") * pi_value * mp (k) / mp (n);
        real_part = cos (angle);
        imaginary_part = sin (angle);
      endif
      if (k == 0)
        root = mp (char (mp ("1") + radius), "0");
      elseif (mod (n, 2) == 0 && k == n / 2)
        root = mp (char (mp ("1") - radius), "0");
      else
        root = mp (char (mp ("1") + radius * real_part), ...
                   char (radius * imaginary_part));
      endif
      unit = mp (char (real_part), char (imaginary_part));
      unit_roots(k + 1) = unit;
      eigenvalues(k + 1) = root;
      if (k > 0 && k < n / 2)
        unit_roots(n - k + 1) = conj (unit);
        eigenvalues(n - k + 1) = conj (root);
      endif
    endfor
    result = struct ("radius", radius, "unit_roots", unit_roots, ...
                     "eigenvalues", eigenvalues);
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function value = nes_reference_power (exponent, bits)
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    value = mp ("1");
    half = mp ("0.5");
    for k = 1:exponent
      value = value * half;
    endfor
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function values = nes_frank_reference_at (n, bits)
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    K = mp (zeros (n, n));
    for j = 1:(n - 1)
      entry = sqrt (mp (j));
      K(j, j + 1) = entry;
      K(j + 1, j) = entry;
    endfor
    [unused, diagonal] = eig (K, "nobalance");
    z = diag (diagonal);
    values = mp (zeros (n, 1));
    for j = 1:n
      radical = sqrt (z(j) * z(j) + mp ("4"));
      if (z(j) >= mp ("0"))
        root = (z(j) + radical) / mp ("2");
      else
        root = mp ("2") / (radical - z(j));
      endif
      values(j) = root * root;
    endfor
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
