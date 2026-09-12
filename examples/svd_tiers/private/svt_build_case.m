## SPDX-License-Identifier: BSD-2-Clause

function fixture = svt_build_case (case_data, work_bits)
  ## Dispatch one manifest record to its already-audited constructor.
  if (! isstruct (case_data) || numel (case_data) != 1 ...
      || ! isfield (case_data, "id") || ! isfield (case_data, "family") ...
      || ! isfield (case_data, "parameters"))
    error ("mplapack:svt:InvalidCase", "manifest case is incomplete");
  endif
  case_id = char (case_data.id);
  family = char (case_data.family);
  parameters = case_data.parameters;
  switch (family)
    case "nro_block"
      fixture = svt_make_nro (case_id, parameters, work_bits);
    case "jacobi_stirling"
      fixture = svt_make_jacobi_stirling (case_id, parameters, work_bits);
    case "lah"
      fixture = svt_make_lah (case_id, parameters, work_bits);
    case "dd_path"
      fixture = svt_make_dd_path (case_id, parameters, work_bits);
    case "pascal"
      fixture = svt_make_pascal (case_id, parameters, work_bits);
    case "vandermonde"
      fixture = svt_make_vandermonde (case_id, parameters, work_bits);
    case "bidiagonal"
      fixture = svt_make_bidiagonal (case_id, parameters, work_bits);
    case "lauchli"
      fixture = svt_make_lauchli (case_id, parameters, work_bits);
    case "hadamard_spectrum"
      fixture = svt_make_hadamard_spectrum (case_id, parameters, work_bits);
    case "nro_companion"
      fixture = svt_make_nro_companion (case_id, parameters, work_bits);
    otherwise
      error ("mplapack:svt:UnknownCaseFamily", "unknown case family: %s", family);
  endswitch
endfunction
