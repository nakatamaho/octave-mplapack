## SPDX-License-Identifier: BSD-2-Clause

function certificate = svt_certify_factor_boxes (a, u, s, v, q, indices)
  ## V2 conservative compatible factor boxes for positive simple values.
  value_certificate = svt_certify_values (a, u, s, v, q);
  certificate = value_certificate;
  certificate.schema = "svt-v2-factor-box-certificate-v1";
  certificate.method = "svt_dilation_factor_boxes_v1";
  if (nargin < 6 || isempty (indices))
    indices = 1:min (size (a));
  endif
  indices = indices(:).';
  certificate.indices = indices;
  certificate.individual_status = cell (1, numel (indices));
  if (! strcmp (value_certificate.status, "CERTIFIED"))
    certificate.status = value_certificate.status;
    certificate.factor_status = "INCONCLUSIVE";
    return;
  endif
  k = min (size (a));
  if (isempty (indices) || any (indices < 1) || any (indices > k) ...
      || any (indices != fix (indices)) || numel (unique (indices)) != numel (indices))
    error ("mplapack:svt:FactorBoxIndices", "factor-box indices are invalid");
  endif
  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (q);
  uq = svt_widen (u, q);
  vq = svt_widen (v, q);
  boxes_u = struct ("real_lower", mp (zeros (size (u))), ...
                    "real_upper", mp (zeros (size (u))), ...
                    "imag_lower", mp (zeros (size (u))), ...
                    "imag_upper", mp (zeros (size (u))));
  boxes_v = struct ("real_lower", mp (zeros (size (v))), ...
                    "real_upper", mp (zeros (size (v))), ...
                    "imag_lower", mp (zeros (size (v))), ...
                    "imag_upper", mp (zeros (size (v))));
  all_certified = true;
  unsupported = false;
  for position = 1:numel (indices)
    index = indices(position);
    repeated = false;
    for other = 1:k
      if (other != index && s(other, other) == s(index, index))
        repeated = true;
      endif
    endfor
    if (repeated)
      certificate.individual_status{position} = "UNSUPPORTED_MULTIPLICITY";
      all_certified = false;
      unsupported = true;
      continue;
    endif
    if (value_certificate.values_lower(index) <= mp (0))
      certificate.individual_status{position} = "INCONCLUSIVE_NONPOSITIVE";
      all_certified = false;
      continue;
    endif
    target = svt_iv ("point", s(index, index), q);
    delta_lower = [];
    for other = 1:k
      if (other != index)
        difference = svt_iv ("sub", target, svt_iv ("point", s(other, other), q));
        delta_lower = append_factor_min (delta_lower, factor_abs_lower (difference));
      endif
      negative_sum = svt_iv ("add", target, svt_iv ("point", s(other, other), q));
      delta_lower = append_factor_min (delta_lower, negative_sum.lo);
    endfor
    if (size (a, 1) != size (a, 2))
      delta_lower = append_factor_min (delta_lower, target.lo);
    endif
    epsilon = value_certificate.epsilon;
    if (isempty (delta_lower) || delta_lower <= mp (2) * epsilon.hi)
      certificate.individual_status{position} = "INCONCLUSIVE_GAP";
      all_certified = false;
      continue;
    endif
    delta = svt_iv ("point", delta_lower, q);
    denominator = svt_iv ("sub", delta, epsilon);
    z = svt_iv ("div", svt_iv ("mul", svt_iv ("point", mp (2), q), epsilon), denominator);
    radius_u = svt_iv ("add", value_certificate.dU, z);
    radius_v = svt_iv ("add", value_certificate.dV, z);
    if (isreal (uq))
      [boxes_u, unused] = set_real_box (boxes_u, real (uq), position, ...
                                        radius_u.hi, q);
      [boxes_v, unused] = set_real_box (boxes_v, real (vq), position, ...
                                        radius_v.hi, q);
    else
      [boxes_u, unused] = set_complex_box (boxes_u, uq, position, radius_u.hi, q);
      [boxes_v, unused] = set_complex_box (boxes_v, vq, position, radius_v.hi, q);
    endif
    certificate.individual_status{position} = "CERTIFIED";
  endfor
  certificate.boxes_U = boxes_u;
  certificate.boxes_V = boxes_v;
  certificate.common_phase = true;
  certificate.compatibility_claim = "one common phase per simple pair; boxes are conservative norm-derived rectangles";
  if (unsupported)
    certificate.status = "UNSUPPORTED_MULTIPLICITY";
    certificate.factor_status = "UNSUPPORTED_MULTIPLICITY";
  elseif (all_certified)
    certificate.status = "CERTIFIED";
    certificate.factor_status = "CERTIFIED";
  else
    certificate.status = "INCONCLUSIVE";
    certificate.factor_status = "INCONCLUSIVE";
  endif
  clear cleanup;
endfunction

function [boxes, unused] = set_real_box(boxes, centers, position, radius, q)
  unused = false;
  for row = 1:size (centers, 1)
    lower = svt_iv ("sub", svt_iv ("point", centers(row, position), q), ...
                    svt_iv ("point", radius, q));
    upper = svt_iv ("add", svt_iv ("point", centers(row, position), q), ...
                    svt_iv ("point", radius, q));
    boxes.real_lower(row, position) = lower.lo;
    boxes.real_upper(row, position) = upper.hi;
  endfor
endfunction

function [boxes, unused] = set_complex_box(boxes, centers, position, radius, q)
  unused = false;
  [boxes, unused] = set_real_box (boxes, real (centers), position, radius, q);
  for row = 1:size (centers, 1)
    lower = svt_iv ("sub", svt_iv ("point", imag (centers(row, position)), q), ...
                    svt_iv ("point", radius, q));
    upper = svt_iv ("add", svt_iv ("point", imag (centers(row, position)), q), ...
                    svt_iv ("point", radius, q));
    boxes.imag_lower(row, position) = lower.lo;
    boxes.imag_upper(row, position) = upper.hi;
  endfor
endfunction

function lower = factor_abs_lower(interval)
  if (interval.lo <= mp (0) && interval.hi >= mp (0))
    lower = mp (0);
  else
    lower = abs (interval.lo);
    if (abs (interval.hi) < lower), lower = abs (interval.hi); endif
  endif
endfunction

function current = append_factor_min(current, candidate)
  if (isempty (current) || candidate < current), current = candidate; endif
endfunction
