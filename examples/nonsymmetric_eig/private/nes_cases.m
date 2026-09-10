% Profile validation and NEIG01 case selection.
function cases = nes_cases (profile, family)
  if (nargin != 2 || ! ischar (profile) || ! ischar (family))
    error ("NEIG:CaseArguments", "profile and family must be character rows");
  endif
  if (! any (strcmp (profile, {"smoke", "demo", "stress"})))
    error ("NEIG:Profile", "profile must be smoke, demo, or stress");
  endif
  if (! strcmp (family, "hadamard"))
    error ("NEIG:CaseFamily", ...
           "NEIG01 implements only family=hadamard; other families are deferred");
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
