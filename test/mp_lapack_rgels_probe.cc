// SPDX-License-Identifier: BSD-2-Clause

#include <cmath>
#include <iostream>
#include <stdexcept>
#include <vector>

#include <gmp.h>
#include <mplapack_mpfr.h>
#include <mplapack_mpfr_precision.h>

namespace
{

using Real = mpfrxx::mpfr_class;

void
require (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

Real
real_at (mpfr_prec_t precision)
{
  return Real::with_precision (precision);
}

void
set_power_two (Real& value, long exponent)
{
  mpfr_set_ui_2exp (value.mpfr_data (), 1, exponent, MPFR_RNDN);
}

mplapackint
workspace_size (std::vector<Real>& a, mplapackint m, mplapackint n,
                mplapackint nrhs, std::vector<Real>& b, mplapackint lda,
                mplapackint ldb, mpfr_prec_t precision)
{
  Real query = real_at (precision);
  mplapackint info = -1;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rgels ("N", m, n, nrhs, a.data (), lda, b.data (), ldb, &query, -1,
           info);
  }
  require (info == 0 && mpfr_integer_p (query.mpfr_data ()) != 0
             && mpfr_sgn (query.mpfr_data ()) > 0,
           "Rgels workspace query failed");
  mpz_t value;
  mpz_init (value);
  mpfr_get_z (value, query.mpfr_data (), MPFR_RNDZ);
  require (mpz_fits_slong_p (value) != 0, "Rgels workspace is too large");
  const long result = mpz_get_si (value);
  mpz_clear (value);
  require (result > 0, "Rgels workspace is not positive");
  return static_cast<mplapackint> (result);
}

void
check_tail (const Real& value, unsigned long base, long exponent)
{
  Real expected = real_at (value.precision ());
  mpfr_set_ui (expected.mpfr_data (), base, MPFR_RNDN);
  Real difference = real_at (value.precision ());
  mpfr_sub (difference.mpfr_data (), value.mpfr_data (), expected.mpfr_data (),
            MPFR_RNDN);
  require (mpfr_zero_p (difference.mpfr_data ()) == 0,
           "Rgels collapsed a precision-sensitive tail");
  require (std::abs (mpfr_get_exp (difference.mpfr_data ())
                     - static_cast<mpfr_exp_t> (exponent)) <= 20,
           "Rgels returned an unexpected precision-sensitive tail");
}

void
run_case (mpfr_prec_t precision, long exponent)
{
  Real t = real_at (precision);
  set_power_two (t, exponent);

  std::vector<Real> qr_a (6, real_at (precision));
  std::vector<Real> qr_b (3, real_at (precision));
  for (auto& value : qr_a)
    mpfr_set_zero (value.mpfr_data (), 0);
  mpfr_set_ui (qr_a[0].mpfr_data (), 1, MPFR_RNDN);
  mpfr_set_ui (qr_a[2].mpfr_data (), 1, MPFR_RNDN);
  mpfr_set_ui (qr_a[4].mpfr_data (), 1, MPFR_RNDN);
  mpfr_set_ui (qr_a[5].mpfr_data (), 1, MPFR_RNDN);
  mpfr_set (qr_b[0].mpfr_data (), t.mpfr_data (), MPFR_RNDN);
  mpfr_set_ui (qr_b[1].mpfr_data (), 1, MPFR_RNDN);
  mpfr_sub (qr_b[1].mpfr_data (), qr_b[1].mpfr_data (), t.mpfr_data (),
            MPFR_RNDN);
  mpfr_set_ui (qr_b[2].mpfr_data (), 4, MPFR_RNDN);
  auto qr_query_a = qr_a;
  auto qr_query_b = qr_b;
  const mplapackint qr_lwork
    = workspace_size (qr_query_a, 3, 2, 1, qr_query_b, 3, 3, precision);
  std::vector<Real> qr_work (static_cast<std::size_t> (qr_lwork),
                             real_at (precision));
  mplapackint info = -1;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rgels ("N", 3, 2, 1, qr_a.data (), 3, qr_b.data (), 3, qr_work.data (),
           qr_lwork, info);
    require (mpfrxx::default_precision_bits () == precision,
             "Rgels changed scoped precision");
  }
  require (info == 0, "overdetermined Rgels solve failed");
  check_tail (qr_b[0], 1, exponent);
  check_tail (qr_b[1], 2, exponent);

  std::vector<Real> lq_a (6, real_at (precision));
  std::vector<Real> lq_b (3, real_at (precision));
  for (auto& value : lq_a)
    mpfr_set_zero (value.mpfr_data (), 0);
  mpfr_set_ui (lq_a[0].mpfr_data (), 1, MPFR_RNDN);
  mpfr_set_ui (lq_a[3].mpfr_data (), 1, MPFR_RNDN);
  mpfr_set_ui (lq_a[4].mpfr_data (), 1, MPFR_RNDN);
  mpfr_set_ui (lq_a[5].mpfr_data (), 1, MPFR_RNDN);
  mpfr_set_ui (lq_b[0].mpfr_data (), 3, MPFR_RNDN);
  Real three_t = real_at (precision);
  mpfr_mul_ui (three_t.mpfr_data (), t.mpfr_data (), 3, MPFR_RNDN);
  mpfr_add (lq_b[0].mpfr_data (), lq_b[0].mpfr_data (), three_t.mpfr_data (),
            MPFR_RNDN);
  mpfr_set_ui (lq_b[1].mpfr_data (), 3, MPFR_RNDN);
  mpfr_set_zero (lq_b[2].mpfr_data (), 0);
  auto lq_query_a = lq_a;
  auto lq_query_b = lq_b;
  const mplapackint lq_lwork
    = workspace_size (lq_query_a, 2, 3, 1, lq_query_b, 2, 3, precision);
  std::vector<Real> lq_work (static_cast<std::size_t> (lq_lwork),
                             real_at (precision));
  info = -1;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rgels ("N", 2, 3, 1, lq_a.data (), 2, lq_b.data (), 3, lq_work.data (),
           lq_lwork, info);
    require (mpfrxx::default_precision_bits () == precision,
             "Rgels changed scoped precision");
  }
  require (info == 0, "underdetermined Rgels solve failed");
  check_tail (lq_b[0], 1, exponent);
  check_tail (lq_b[1], 1, exponent);
  check_tail (lq_b[2], 2, exponent);
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
      require (mpfrxx::default_precision_bits () == 128,
               "Rgels did not restore outside precision");
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
  std::cout << "PASS: installed MPLAPACK MPFR Rgels precision probe\n";
  return 0;
}
