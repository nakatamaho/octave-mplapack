// SPDX-License-Identifier: BSD-2-Clause

#include <iostream>
#include <stdexcept>
#include <vector>

#include <mplapack_mpfr.h>
#include <mplapack_mpfr_precision.h>

namespace
{
using Real = mpfrxx::mpfr_class;

void check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

Real at_precision (mpfr_prec_t p)
{
  return Real::with_precision (p);
}

void set_ui (Real& x, unsigned long v)
{
  mpfr_set_ui (x.mpfr_data (), v, MPFR_RNDN);
}

void set_power (Real& x, mpfr_exp_t e)
{
  mpfr_set_ui_2exp (x.mpfr_data (), 1, e, MPFR_RNDN);
}

void run_case (mpfr_prec_t p)
{
  constexpr mplapackint m = 3;
  constexpr mplapackint n = 3;
  constexpr mplapackint k = 3;
  std::vector<Real> query_a (m*n, at_precision (p));
  std::vector<Real> query_tau (k, at_precision (p));
  std::vector<Real> query_work (1, at_precision (p));
  set_ui (query_a[0], 1);
  set_ui (query_a[4], 4);
  set_ui (query_a[8], 2);
  std::vector<mplapackint> query_jpvt (n, 0);
  mplapackint info = 0;
  {
    MplapackMpfrPrecisionScope scope (p);
    Rgeqp3 (m, n, query_a.data (), m, query_jpvt.data (), query_tau.data (),
            query_work.data (), -1, info);
  }
  check (info == 0, "Rgeqp3 query failed");
  check (mpfr_integer_p (query_work[0].mpfr_data ()) != 0
         && mpfr_sgn (query_work[0].mpfr_data ()) > 0,
         "Rgeqp3 query workspace invalid");
  const mplapackint lwork = static_cast<mplapackint> (
    mpfr_get_si (query_work[0].mpfr_data (), MPFR_RNDZ));
  std::vector<Real> a (m*n, at_precision (p));
  std::vector<Real> tau (k, at_precision (p));
  std::vector<Real> work (lwork, at_precision (p));
  std::vector<mplapackint> jpvt (n, 0);
  set_ui (a[0], 1);
  set_ui (a[4], 4);
  set_ui (a[8], 2);
  {
    MplapackMpfrPrecisionScope scope (p);
    Rgeqp3 (m, n, a.data (), m, jpvt.data (), tau.data (), work.data (),
            lwork, info);
  }
  check (info == 0, "Rgeqp3 failed");
  check (jpvt[0] == 2 && jpvt[1] == 3 && jpvt[2] == 1,
         "Rgeqp3 JPVT mapping mismatch");

  std::vector<Real> q (m*m, at_precision (p));
  for (mplapackint col = 0; col < m; ++col)
    for (mplapackint row = 0; row < m; ++row)
      if (col < n)
        mpfr_set (q[row + col*m].mpfr_data (),
                  a[row + col*m].mpfr_data (), MPFR_RNDN);
      else
        mpfr_set_zero (q[row + col*m].mpfr_data (), 0);
  std::vector<Real> tau_q (tau);
  std::vector<Real> qquery (1, at_precision (p));
  {
    MplapackMpfrPrecisionScope scope (p);
    Rorgqr (m, m, k, q.data (), m, tau_q.data (), qquery.data (), -1, info);
  }
  check (info == 0, "Rorgqr query failed");
  const auto qwork_len = static_cast<mplapackint> (
    mpfr_get_si (qquery[0].mpfr_data (), MPFR_RNDZ));
  std::vector<Real> qwork (qwork_len, at_precision (p));
  {
    MplapackMpfrPrecisionScope scope (p);
    Rorgqr (m, m, k, q.data (), m, tau_q.data (), qwork.data (), qwork_len,
            info);
  }
  check (info == 0, "Rorgqr failed");
}

void run_precision_canary ()
{
  const mpfr_prec_t p = 1024;
  const mpfr_exp_t e = -700;
  std::vector<Real> a (2, at_precision (p));
  std::vector<Real> tau (1, at_precision (p));
  std::vector<Real> work_query (1, at_precision (p));
  set_ui (a[0], 1);
  set_power (a[1], e);
  mpfr_add_ui (a[1].mpfr_data (), a[1].mpfr_data (), 1, MPFR_RNDN);
  std::vector<mplapackint> jpvt (2, 0);
  mplapackint info = 0;
  {
    MplapackMpfrPrecisionScope scope (p);
    Rgeqp3 (1, 2, a.data (), 1, jpvt.data (), tau.data (),
            work_query.data (), -1, info);
  }
  check (info == 0, "Rgeqp3 canary query failed");
  const auto lwork = static_cast<mplapackint> (
    mpfr_get_si (work_query[0].mpfr_data (), MPFR_RNDZ));
  std::vector<Real> work (lwork, at_precision (p));
  a[0] = at_precision (p);
  set_ui (a[0], 1);
  set_power (a[1], e);
  mpfr_add_ui (a[1].mpfr_data (), a[1].mpfr_data (), 1, MPFR_RNDN);
  jpvt.assign (2, 0);
  {
    MplapackMpfrPrecisionScope scope (p);
    Rgeqp3 (1, 2, a.data (), 1, jpvt.data (), tau.data (), work.data (),
            lwork, info);
  }
  check (info == 0 && jpvt[0] == 2 && jpvt[1] == 1,
         "Rgeqp3 precision pivot canary failed");
  check (mpfrxx::default_precision_bits () == 512,
         "Rgeqp3 precision probe leaked default");
}

} // namespace

int main ()
{
  try
    {
      mpfrxx::set_default_precision_bits (512);
      run_case (1024);
      run_case (2048);
      run_precision_canary ();
    }
  catch (const std::exception& e)
    {
      std::cerr << "FAIL: " << e.what () << '\n';
      return 1;
    }
  std::cout << "PASS: installed MPLAPACK MPFR Rgeqp3/JPVT precision probe\n";
  return 0;
}

