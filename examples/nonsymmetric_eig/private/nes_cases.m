% Profile validation and NEIG01 case selection.
function cases = nes_cases (profile, family)
  if (nargin != 2 || ! ischar (profile) || ! ischar (family))
    error ("NEIG:CaseArguments", "profile and family must be character rows");
  endif
  if (! any (strcmp (profile, {"smoke", "demo", "stress"})))
    error ("NEIG:Profile", "profile must be smoke, demo, or stress");
  endif
  if (! any (strcmp (family, {"all", "hadamard", "frank", "companion", "forsythe"})))
    error ("NEIG:CaseFamily", ...
           "unknown nonsymmetric eigensystem family");
  endif
  if (strcmp (family, "all"))
    if (strcmp (profile, "smoke"))
      hadamard_n = 8; hadamard_s = 16; frank_n = 8; companion_n = 10;
      forsythe_n = 8; forsythe_a = 4;
    elseif (strcmp (profile, "demo"))
      hadamard_n = 16; hadamard_s = 128; frank_n = 24; companion_n = 20;
      forsythe_n = 20; forsythe_a = 20;
    else
      hadamard_n = 16; hadamard_s = 16; frank_n = 16; companion_n = 30;
      forsythe_n = 20; forsythe_a = 80;
    endif
    cases(1) = struct ("family", "hadamard", "representation", ...
                       "hadamard_similar", "n", hadamard_n, ...
                       "s", hadamard_s, "a", NaN);
    cases(2) = struct ("family", "frank", "representation", "frank", ...
                       "n", frank_n, "s", NaN, "a", NaN);
    cases(3) = struct ("family", "companion", "representation", ...
                       "companion", "n", companion_n, "s", NaN, "a", NaN);
    cases(4) = struct ("family", "forsythe", "representation", ...
                       "original", "n", forsythe_n, "s", NaN, ...
                       "a", forsythe_a);
    cases(5) = struct ("family", "forsythe", "representation", ...
                       "explicitly_scaled", "n", forsythe_n, "s", NaN, ...
                       "a", forsythe_a);
    return;
  endif
  if (strcmp (family, "frank"))
    if (strcmp (profile, "smoke"))
      cases = struct ("family", "frank", "representation", "frank", "n", 8);
    elseif (strcmp (profile, "demo"))
      cases = struct ("family", "frank", "representation", "frank", "n", 24);
    else
      cases = struct ("family", "frank", "representation", "frank", "n", 16);
    endif
    return;
  endif
  if (strcmp (family, "companion"))
    if (strcmp (profile, "smoke"))
      cases = struct ("family", "companion", "representation", "companion", "n", 10);
    elseif (strcmp (profile, "demo"))
      cases = struct ("family", "companion", "representation", "companion", "n", 20);
    else
      cases = struct ("family", "companion", "representation", "companion", "n", 30);
    endif
    return;
  endif
  if (strcmp (family, "forsythe"))
    if (strcmp (profile, "smoke"))
      n = 8; a = 4;
    elseif (strcmp (profile, "demo"))
      n = 20; a = 20;
    else
      n = 20; a = 80;
    endif
    cases(1) = struct ("family", "forsythe", "representation", "original", ...
                       "n", n, "a", a);
    cases(2) = struct ("family", "forsythe", "representation", ...
                       "explicitly_scaled", "n", n, "a", a);
    return;
  endif
  switch (profile)
    case "smoke"
      cases = struct ("family", "hadamard", "representation", "hadamard_similar", ...
                      "n", 8, "s", 16);
    case "demo"
      cases = struct ("family", "hadamard", "representation", "hadamard_similar", ...
                      "n", 16, "s", 128);
    otherwise
      cases = struct ("family", "hadamard", "representation", "hadamard_similar", ...
                      "n", 16, "s", 16);
  endswitch
endfunction
