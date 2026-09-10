% Profile validation and NEIG01 case selection.
function cases = nes_cases (profile, family)
  if (nargin != 2 || ! ischar (profile) || ! ischar (family))
    error ("NEIG:CaseArguments", "profile and family must be character rows");
  endif
  if (! any (strcmp (profile, {"smoke", "demo", "stress"})))
    error ("NEIG:Profile", "profile must be smoke, demo, or stress");
  endif
  if (! any (strcmp (family, {"hadamard", "frank", "companion"})))
    error ("NEIG:CaseFamily", ...
           "current milestones implement only family=hadamard, frank, or companion");
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
