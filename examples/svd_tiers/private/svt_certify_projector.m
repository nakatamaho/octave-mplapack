## SPDX-License-Identifier: BSD-2-Clause

function certificate = svt_certify_projector (a, u, s, v, q, indices)
  ## V1b signed-dilation positive-cluster projector certificate.
  value_certificate = svt_certify_values (a, u, s, v, q);
  certificate = value_certificate;
  certificate.schema = "svt-v1b-projector-certificate-v1";
  certificate.method = "svt_dilation_projector_v1";
  certificate.cluster_indices = indices(:).';
  certificate.projector_status = "INCONCLUSIVE";
  if (! strcmp (value_certificate.status, "CERTIFIED"))
    certificate.reason = "V1a value certificate is unavailable";
    return;
  endif
  k = min (size (a));
  indices = indices(:).';
  if (isempty (indices) || any (indices < 1) || any (indices > k) ...
      || any (indices != fix (indices)) || numel (unique (indices)) != numel (indices))
    error ("mplapack:svt:ProjectorIndices", "cluster indices are invalid");
  endif
  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (q);
  target_positive = true;
  for index = indices
    if (value_certificate.values_lower(index) <= mp (0))
      target_positive = false;
    endif
  endfor
  certificate.target_positive = target_positive;
  if (! target_positive)
    certificate.reason = "target cluster has no certified positive lower endpoint";
    certificate.status = "INCONCLUSIVE";
    clear cleanup;
    return;
  endif
  ## Build the separation of target +/-s_j from every complementary dilation
  ## eigenvalue.  All differences and sums are interval operations.
  delta_lower = [];
  complement_count = 0;
  for target = indices
    target_point = svt_iv ("point", s(target, target), q);
    for other = 1:k
      if (! any (indices == other)
          && s(other, other) >= mp (0))
        other_point = svt_iv ("point", s(other, other), q);
        difference = svt_iv ("sub", target_point, other_point);
        candidate = interval_abs_lower (difference);
        delta_lower = append_minimum (delta_lower, candidate);
        complement_count = complement_count + 1;
      endif
      ## The negative branch contains -s_other, including the target itself.
      other_point = svt_iv ("point", s(other, other), q);
      sum_value = svt_iv ("add", target_point, other_point);
      delta_lower = append_minimum (delta_lower, sum_value.lo);
      complement_count = complement_count + 1;
    endfor
    if (size (a, 1) != size (a, 2))
      delta_lower = append_minimum (delta_lower, target_point.lo);
      complement_count = complement_count + 1;
    endif
  endfor
  certificate.complement_count = complement_count;
  certificate.delta_lower = delta_lower;
  certificate.cluster_size = numel (indices);
  epsilon_upper = value_certificate.epsilon.hi;
  certificate.epsilon_upper = epsilon_upper;
  if (isempty (delta_lower))
    ## The full square dilation is exhausted by the selected +/- cluster.
    b_sub = svt_iv ("point", mp (0), q);
    certificate.delta_trivial = true;
  else
    certificate.delta_trivial = false;
    if (delta_lower <= mp (2) * epsilon_upper)
      certificate.reason = "external dilation gap is not greater than 2*epsilon";
      certificate.status = "INCONCLUSIVE";
      clear cleanup;
      return;
    endif
    delta = svt_iv ("point", delta_lower, q);
    rank_interval = svt_iv ("point", mp (numel (indices)), q);
    numerator = svt_iv ("mul", svt_iv ("point", mp (2), q), ...
                        svt_iv ("sqrt", rank_interval));
    denominator = svt_iv ("sub", delta, value_certificate.epsilon);
    b_sub = svt_iv ("div", svt_iv ("mul", numerator, value_certificate.epsilon), denominator);
  endif
  one = svt_iv ("point", mp (1), q);
  correction_u = svt_iv ("mul", svt_iv ("add", ...
                            svt_iv ("sqrt", svt_iv ("add", one, value_certificate.gU)), one), ...
                         value_certificate.dU);
  correction_v = svt_iv ("mul", svt_iv ("add", ...
                            svt_iv ("sqrt", svt_iv ("add", one, value_certificate.gV)), one), ...
                         value_certificate.dV);
  certificate.b_sub = b_sub;
  certificate.bU = svt_iv ("add", b_sub, correction_u);
  certificate.bV = svt_iv ("add", b_sub, correction_v);
  certificate.projector_status = "CERTIFIED";
  certificate.status = "CERTIFIED";
  certificate.claim = "raw-factor cluster projectors are enclosed by bU/bV";
  clear cleanup;
endfunction

function lower = interval_abs_lower(interval)
  if (interval.lo <= mp (0) && interval.hi >= mp (0))
    lower = mp (0);
  else
    left = abs (interval.lo);
    right = abs (interval.hi);
    lower = left;
    if (right < lower), lower = right; endif
  endif
endfunction

function current = append_minimum(current, candidate)
  if (isempty (current) || candidate < current)
    current = candidate;
  endif
endfunction
