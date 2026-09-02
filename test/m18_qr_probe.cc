// SPDX-License-Identifier: BSD-2-Clause

#include <iostream>
#include <stdexcept>
#include <vector>

#include <mplapack_mpfr.h>
#include <mplapack_mpfr_precision.h>

namespace
{

using Real = mpfrxx::mpfr_class;

Real
at_precision (mpfr_prec_t precision)
{
  return Real::with_precision (precision);
}

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

void
set_power (Real& value, mpfr_exp_t exponent)
{
  mpfr_set_ui_2exp (value.mpfr_data (), 1, exponent, MPFR_RNDN);
}

void
run_case (mpfr_prec_t precision, mpfr_exp_t exponent)
{
  constexpr mplapackint m = 3;
  constexpr mplapackint n = 2;
  constexpr mplapackint k = 2;
  std::vector<Real> query_a (m * n, at_precision (precision));
  std::vector<Real> query_tau (k, at_precision (precision));
  std::vector<Real> query_work (1, at_precision (precision));
  set_power (query_a[4], exponent);
  mpfr_add_ui (query_a[4].mpfr_data (), query_a[4].mpfr_data (), 1,
               MPFR_RNDN);
  mpfr_set_ui (query_a[0].mpfr_data (), 1, MPFR_RNDN);
  mpfr_set_ui (query_a[3].mpfr_data (), 1, MPFR_RNDN);
  mplapackint info = 0;
  const auto before = mpfrxx::default_precision_bits ();
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rgeqrf (m, n, query_a.data (), m, query_tau.data (), query_work.data (),
            -1, info);
    check (mpfrxx::default_precision_bits () == precision,
           "Rgeqrf query changed scoped precision");
  }
  check (before == mpfrxx::default_precision_bits (),
         "Rgeqrf query leaked ambient precision");
  check (info == 0, "Rgeqrf query failed");
  check (mpfr_integer_p (query_work[0].mpfr_data ()) != 0
         && mpfr_sgn (query_work[0].mpfr_data ()) > 0,
         "Rgeqrf query returned invalid workspace");
  const auto lwork = static_cast<mplapackint> (
    mpfr_get_si (query_work[0].mpfr_data (), MPFR_RNDZ));

  std::vector<Real> a (m * n, at_precision (precision));
  std::vector<Real> tau (k, at_precision (precision));
  std::vector<Real> work (lwork, at_precision (precision));
  set_power (a[4], exponent);
  mpfr_add_ui (a[4].mpfr_data (), a[4].mpfr_data (), 1, MPFR_RNDN);
  mpfr_set_ui (a[0].mpfr_data (), 1, MPFR_RNDN);
  mpfr_set_ui (a[3].mpfr_data (), 1, MPFR_RNDN);
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rgeqrf (m, n, a.data (), m, tau.data (), work.data (), lwork, info);
  }
  check (info == 0, "Rgeqrf solve failed");
  Real expected = at_precision (precision);
  set_power (expected, exponent);
  mpfr_add_ui (expected.mpfr_data (), expected.mpfr_data (), 1, MPFR_RNDN);
  check (mpfr_equal_p (a[4].mpfr_data (), expected.mpfr_data ()) != 0,
         "Rgeqrf precision tail was not preserved");

  std::vector<Real> q (m * m, at_precision (precision));
  for (mplapackint column = 0; column < m; ++column)
    for (mplapackint row = 0; row < m; ++row)
      {
        if (column < n)
          mpfr_set (q[row + column * m].mpfr_data (),
                    a[row + column * m].mpfr_data (), MPFR_RNDN);
        else
          mpfr_set_zero (q[row + column * m].mpfr_data (), 0);
      }
  std::vector<Real> query_qwork (1, at_precision (precision));
  std::vector<Real> q_tau (tau);
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rorgqr (m, m, k, q.data (), m, q_tau.data (), query_qwork.data (), -1,
            info);
  }
  check (info == 0, "Rorgqr query failed");
  const auto q_lwork = static_cast<mplapackint> (
    mpfr_get_si (query_qwork[0].mpfr_data (), MPFR_RNDZ));
  std::vector<Real> q_actual (q);
  std::vector<Real> q_work (q_lwork, at_precision (precision));
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rorgqr (m, m, k, q_actual.data (), m, q_tau.data (), q_work.data (),
            q_lwork, info);
  }
  check (info == 0, "Rorgqr solve failed");
  check (mpfrxx::default_precision_bits () == before,
         "Rorgqr leaked ambient precision");
}

void
run_high_ambient ()
{
  mpfrxx::set_default_precision_bits (4096);
  std::vector<Real> a (1, at_precision (256));
  mpfr_set_ui (a[0].mpfr_data (), 4, MPFR_RNDN);
  std::vector<Real> tau (1, at_precision (256));
  std::vector<Real> work (1, at_precision (256));
  mplapackint info = 0;
  {
    MplapackMpfrPrecisionScope scope (256);
    Rgeqrf (1, 1, a.data (), 1, tau.data (), work.data (), -1, info);
  }
  check (info == 0 && mpfrxx::default_precision_bits () == 4096,
         "high ambient QR probe failed");
}

} // namespace

int
main ()
{
  try
    {
      mpfrxx::set_default_precision_bits (128);
      run_case (1024, -700);
      run_case (2048, -1500);
      run_high_ambient ();
      check (mpfrxx::default_precision_bits () == 4096,
             "QR probe did not preserve final ambient precision");
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
  std::cout << "PASS: installed MPLAPACK MPFR Rgeqrf/Rorgqr precision probe\n";
  return 0;
}
