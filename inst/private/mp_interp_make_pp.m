## SPDX-License-Identifier: BSD-2-Clause

function pp = mp_interp_make_pp (x, y, method)
  n = rows (x);
  pieces = n - 1;
  zero = mp_interp_element (y, 1) * 0;
  coefficients = repmat (zero, pieces, 4);
  h = repmat (zero, pieces, 1);
  delta = repmat (zero, pieces, 1);
  for index = 1:pieces
    xi = mp_interp_element (x, index);
    xnext = mp_interp_element (x, index + 1);
    yi = mp_interp_element (y, index);
    ynext = mp_interp_element (y, index + 1);
    h = mp_interp_put (h, index, 1, xnext - xi);
    delta = mp_interp_put (delta, index, 1, (ynext - yi) / (xnext - xi));
  endfor

  slopes = repmat (zero, n, 1);
  if (strcmp (method, "pchip"))
    if (n == 2)
      slopes = mp_interp_put (slopes, 1, 1, mp_interp_element (delta, 1));
      slopes = mp_interp_put (slopes, 2, 1, mp_interp_element (delta, 1));
    elseif (isreal (y))
      for index = 2:(n - 1)
        previous = mp_interp_element (delta, index - 1);
        next_value = mp_interp_element (delta, index);
        if (previous * next_value <= 0)
          slope = zero;
        else
          hp = mp_interp_element (h, index - 1);
          hn = mp_interp_element (h, index);
          w1 = 2 * hn + hp;
          w2 = hn + 2 * hp;
          slope = (w1 + w2) / (w1 / previous + w2 / next_value);
        endif
        slopes = mp_interp_put (slopes, index, 1, slope);
      endfor
      slopes = mp_interp_put (slopes, 1, 1, ...
                              mp_interp_pchip_endpoint (h, delta, 1));
      slopes = mp_interp_put (slopes, n, 1, ...
                              mp_interp_pchip_endpoint (h, delta, n));
    else
      ## Complex shape preservation has no scalar ordering.  The same
      ## weighted Hermite slope is used without a real sign clamp.
      slopes = mp_interp_put (slopes, 1, 1, mp_interp_element (delta, 1));
      slopes = mp_interp_put (slopes, n, 1, mp_interp_element (delta, pieces));
      for index = 2:(n - 1)
        previous = mp_interp_element (delta, index - 1);
        next_value = mp_interp_element (delta, index);
        hp = mp_interp_element (h, index - 1);
        hn = mp_interp_element (h, index);
        w1 = 2 * hn + hp;
        w2 = hn + 2 * hp;
        slopes = mp_interp_put (slopes, index, 1, ...
                                (w1 + w2) / (w1 / previous + w2 / next_value));
      endfor
    endif
  else
    ## Spline coefficients use second derivatives from the not-a-knot
    ## tridiagonal system.  The system is assembled with MP arithmetic.
    if (n == 2)
      second = repmat (zero, n, 1);
    else
      system = repmat (zero, n, n);
      rhs = repmat (zero, n, 1);
      h1 = mp_interp_element (h, 1);
      h2 = mp_interp_element (h, min (2, pieces));
      system = mp_interp_put (system, 1, 1, -h2);
      system = mp_interp_put (system, 1, 2, h1 + h2);
      system = mp_interp_put (system, 1, 3, -h1);
      for index = 2:(n - 1)
        hp = mp_interp_element (h, index - 1);
        hn = mp_interp_element (h, index);
        system = mp_interp_put (system, index, index - 1, hp);
        system = mp_interp_put (system, index, index, 2 * (hp + hn));
        system = mp_interp_put (system, index, index + 1, hn);
        rhs = mp_interp_put (rhs, index, 1, ...
                             6 * (mp_interp_element (delta, index) ...
                                  - mp_interp_element (delta, index - 1)));
      endfor
      hm = mp_interp_element (h, pieces);
      hp = mp_interp_element (h, pieces - 1);
      system = mp_interp_put (system, n, n - 2, -hm);
      system = mp_interp_put (system, n, n - 1, hm + hp);
      system = mp_interp_put (system, n, n, -hp);
      second = system \ rhs;
    endif
  endif

  for index = 1:pieces
    yi = mp_interp_element (y, index);
    di = mp_interp_element (delta, index);
    hi = mp_interp_element (h, index);
    if (strcmp (method, "pchip"))
      d0 = mp_interp_element (slopes, index);
      d1 = mp_interp_element (slopes, index + 1);
      c2 = (3 * di - 2 * d0 - d1) / hi;
      c3 = (d0 + d1 - 2 * di) / (hi * hi);
      c1 = d0;
    elseif (n == 2)
      c1 = di;
      c2 = zero;
      c3 = zero;
    else
      m0 = mp_interp_element (second, index);
      m1 = mp_interp_element (second, index + 1);
      c1 = di - hi * (2 * m0 + m1) / 6;
      c2 = m0 / 2;
      c3 = (m1 - m0) / (6 * hi);
    endif
    coefficients = mp_interp_put (coefficients, index, 1, c3);
    coefficients = mp_interp_put (coefficients, index, 2, c2);
    coefficients = mp_interp_put (coefficients, index, 3, c1);
    coefficients = mp_interp_put (coefficients, index, 4, yi);
  endfor

  pp = struct ("form", "pp", "breaks", x, "coefs", coefficients, ...
               "pieces", pieces, "order", 4, "dim", 1, ...
               "method", method);
endfunction

function slope = mp_interp_pchip_endpoint (h, delta, endpoint)
  if (endpoint == 1)
    h0 = mp_interp_element (h, 1);
    h1 = mp_interp_element (h, 2);
    d0 = mp_interp_element (delta, 1);
    d1 = mp_interp_element (delta, 2);
    slope = ((2 * h0 + h1) * d0 - h0 * d1) / (h0 + h1);
    if (slope * d0 <= 0)
      slope = d0 * 0;
    elseif (abs (slope) > 3 * abs (d0))
      slope = 3 * d0;
    endif
  else
    count = rows (h);
    h0 = mp_interp_element (h, count);
    h1 = mp_interp_element (h, count - 1);
    d0 = mp_interp_element (delta, count);
    d1 = mp_interp_element (delta, count - 1);
    slope = ((2 * h0 + h1) * d0 - h0 * d1) / (h0 + h1);
    if (slope * d0 <= 0)
      slope = d0 * 0;
    elseif (abs (slope) > 3 * abs (d0))
      slope = 3 * d0;
    endif
  endif
endfunction
