% Precision-aware nonlinear solve, quadrature, and optimization.
if (exist ("mpbits", "file") != 2)
  pkg load mplapack-interop
endif

saved_bits = mpbits ();
unwind_protect
  mpbits (256);
  target = mp ("1.25");
  options = struct ("TolX", mp ("1e-35"), "TolFun", mp ("1e-35"), ...
                    "MaxIter", 600);
  [root_value, fval, info] = fzero (@(x) x * x - target * target, ...
                              mp ({"0", "2"}), options);
  assert (info == 1);
  assert (abs (root_value - target) < mp ("1e-30"));
  assert (abs (fval) < mp ("1e-30"));

  quad_options = struct ("AbsTol", mp ("1e-25"), "RelTol", mp ("1e-25"));
  [value, err] = integral (@(x) x * x, mp ("0"), mp ("1"), quad_options);
  assert (abs (value - mp ("1") / mp ("3")) < mp ("1e-25"));
  assert (err < mp ("1e-25"));

  [argument, minimum, opt_info] = fminbnd ( ...
    @(x) (x - target) * (x - target), mp ("0"), mp ("2"), options);
  assert (opt_info == 1);
  assert (abs (argument - target) < mp ("1e-20"));
  assert (minimum < mp ("1e-35"));
  fprintf ("solver/quadrature/optimization PASS\n");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
