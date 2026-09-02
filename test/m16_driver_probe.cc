// SPDX-License-Identifier: BSD-2-Clause
// M16 rank-revealing MPLAPACK driver comparison probe.

#include <algorithm>
#include <cmath>
#include <limits>
#include <iostream>
#include <stdexcept>
#include <string>
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
set_int (Real& value, long source)
{
  mpfr_set_si (value.mpfr_data (), source, MPFR_RNDN);
}

void
set_pow2 (Real& value, long exponent)
{
  mpfr_set_ui_2exp (value.mpfr_data (), 1, exponent, MPFR_RNDN);
}

mplapackint
workspace (std::vector<Real>& a, mplapackint m, mplapackint n,
           mplapackint nrhs, std::vector<Real>& b, mplapackint lda,
           mplapackint ldb, mpfr_prec_t precision, int driver)
{
  Real query = at_precision (precision);
  Real rcond = at_precision (precision);
  std::vector<Real> s (static_cast<std::size_t> (std::max<mplapackint> (1,
                                                                         std::min (m, n))),
                       at_precision (precision));
  std::vector<mplapackint> jpvt (static_cast<std::size_t> (std::max<mplapackint> (1, n)),
                                 0);
  std::vector<mplapackint> iwork (1024, 0);
  mplapackint rank = -1;
  mplapackint info = -1;
  {
    MplapackMpfrPrecisionScope scope (precision);
    const Real epsilon = Rlamch_mpfr ("E");
    mpfr_set (rcond.mpfr_data (), epsilon.mpfr_data (), MPFR_RNDN);
    if (driver == 0)
      Rgelsy (m, n, nrhs, a.data (), lda, b.data (), ldb, jpvt.data (),
              rcond, rank, &query, -1, info);
    else if (driver == 1)
      Rgelss (m, n, nrhs, a.data (), lda, b.data (), ldb, s.data (), rcond,
              rank, &query, -1, info);
    else
      Rgelsd (m, n, nrhs, a.data (), lda, b.data (), ldb, s.data (), rcond,
              rank, &query, -1, iwork.data (), info);
  }
  if (info != 0)
    throw std::runtime_error ("workspace query failed");
  if (mpfr_integer_p (query.mpfr_data ()) == 0
      || mpfr_sgn (query.mpfr_data ()) <= 0)
    throw std::runtime_error ("invalid workspace query result");
  const auto result = mpfr_get_uj (query.mpfr_data (), MPFR_RNDZ);
  if (result == 0
      || result > static_cast<unsigned long long> (
           std::numeric_limits<mplapackint>::max ()))
    throw std::runtime_error ("workspace query out of range");
  return static_cast<mplapackint> (result);
}

void
run_driver (int driver, const char *name, mpfr_prec_t precision)
{
  // A = [1 2; 2 4; 3 6], B = [1;2;3], min-norm X = [1/5;2/5].
  std::vector<Real> a (6, at_precision (precision));
  std::vector<Real> b (3, at_precision (precision));
  for (auto& x : a)
    set_int (x, 0);
  set_int (a[0], 1); set_int (a[1], 2); set_int (a[2], 3);
  set_int (a[3], 2); set_int (a[4], 4); set_int (a[5], 6);
  set_int (b[0], 1); set_int (b[1], 2); set_int (b[2], 3);
  auto aq = a;
  auto bq = b;
  const mplapackint lwork = workspace (aq, 3, 2, 1, bq, 3, 3,
                                       precision, driver);
  std::vector<Real> s (2, at_precision (precision));
  std::vector<mplapackint> jpvt (2, 0);
  std::vector<mplapackint> iwork (1024, 0);
  std::vector<Real> work (static_cast<std::size_t> (lwork), at_precision (precision));
  mplapackint rank = -1;
  mplapackint info = -1;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Real rcond = at_precision (precision);
    const Real epsilon = Rlamch_mpfr ("E");
    mpfr_set (rcond.mpfr_data (), epsilon.mpfr_data (), MPFR_RNDN);
    if (driver == 0)
      Rgelsy (3, 2, 1, a.data (), 3, b.data (), 3, jpvt.data (), rcond,
              rank, work.data (), lwork, info);
    else if (driver == 1)
      Rgelss (3, 2, 1, a.data (), 3, b.data (), 3, s.data (), rcond,
              rank, work.data (), lwork, info);
    else
      Rgelsd (3, 2, 1, a.data (), 3, b.data (), 3, s.data (), rcond,
              rank, work.data (), lwork, iwork.data (), info);
  }
  std::cout << name << " p=" << precision << " rank=" << rank
            << " info=" << info << " x0="
            << mpfr_get_d (b[0].mpfr_data (), MPFR_RNDN) << " x1="
            << mpfr_get_d (b[1].mpfr_data (), MPFR_RNDN) << '\n';
}

void
run_rank_canary (int driver, const char *name, mpfr_prec_t precision)
{
  const long exponent = -700;
  std::vector<Real> a (6, at_precision (precision));
  std::vector<Real> b (3, at_precision (precision));
  for (auto& x : a)
    set_int (x, 0);
  for (auto& x : b)
    set_int (x, 0);
  set_int (a[0], 1);
  Real delta = at_precision (precision);
  set_pow2 (delta, exponent);
  mpfr_set (a[4].mpfr_data (), delta.mpfr_data (), MPFR_RNDN);
  mpfr_set (b[1].mpfr_data (), delta.mpfr_data (), MPFR_RNDN);
  auto aq = a;
  auto bq = b;
  const mplapackint lwork = workspace (aq, 3, 2, 1, bq, 3, 3,
                                       precision, driver);
  std::vector<Real> s (2, at_precision (precision));
  std::vector<mplapackint> jpvt (2, 0);
  std::vector<mplapackint> iwork (1024, 0);
  std::vector<Real> work (static_cast<std::size_t> (lwork), at_precision (precision));
  mplapackint rank = -1;
  mplapackint info = -1;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Real rcond = at_precision (precision);
    const Real epsilon = Rlamch_mpfr ("E");
    mpfr_set (rcond.mpfr_data (), epsilon.mpfr_data (), MPFR_RNDN);
    if (driver == 0)
      Rgelsy (3, 2, 1, a.data (), 3, b.data (), 3, jpvt.data (), rcond,
              rank, work.data (), lwork, info);
    else if (driver == 1)
      Rgelss (3, 2, 1, a.data (), 3, b.data (), 3, s.data (), rcond,
              rank, work.data (), lwork, info);
    else
      Rgelsd (3, 2, 1, a.data (), 3, b.data (), 3, s.data (), rcond,
              rank, work.data (), lwork, iwork.data (), info);
  }
  std::cout << name << " canary p=" << precision << " rank=" << rank
            << " info=" << info << " x1exp="
            << mpfr_get_exp (b[1].mpfr_data ()) << '\n';
}

void
run_underdetermined (int driver, const char *name, mpfr_prec_t precision)
{
  // A = [1 2 3; 2 4 6], B = [1;2].  The rank-one minimum-norm
  // solution is [1/14; 2/14; 3/14].
  std::vector<Real> a (6, at_precision (precision));
  std::vector<Real> b (3, at_precision (precision));
  set_int (a[0], 1); set_int (a[1], 2);
  set_int (a[2], 2); set_int (a[3], 4);
  set_int (a[4], 3); set_int (a[5], 6);
  set_int (b[0], 1); set_int (b[1], 2); set_int (b[2], 0);
  auto aq = a;
  auto bq = b;
  const mplapackint lwork = workspace (aq, 2, 3, 1, bq, 2, 3,
                                       precision, driver);
  std::vector<Real> s (3, at_precision (precision));
  std::vector<mplapackint> jpvt (3, 0);
  std::vector<mplapackint> iwork (1024, 0);
  std::vector<Real> work (static_cast<std::size_t> (lwork), at_precision (precision));
  mplapackint rank = -1;
  mplapackint info = -1;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Real rcond = at_precision (precision);
    const Real epsilon = Rlamch_mpfr ("E");
    mpfr_set (rcond.mpfr_data (), epsilon.mpfr_data (), MPFR_RNDN);
    if (driver == 0)
      Rgelsy (2, 3, 1, a.data (), 2, b.data (), 3, jpvt.data (), rcond,
              rank, work.data (), lwork, info);
    else if (driver == 1)
      Rgelss (2, 3, 1, a.data (), 2, b.data (), 3, s.data (), rcond,
              rank, work.data (), lwork, info);
    else
      Rgelsd (2, 3, 1, a.data (), 2, b.data (), 3, s.data (), rcond,
              rank, work.data (), lwork, iwork.data (), info);
  }
  std::cout << name << " under p=" << precision << " rank=" << rank
            << " info=" << info << " x="
            << mpfr_get_d (b[0].mpfr_data (), MPFR_RNDN) << ","
            << mpfr_get_d (b[1].mpfr_data (), MPFR_RNDN) << ","
            << mpfr_get_d (b[2].mpfr_data (), MPFR_RNDN) << '\n';
}

} // namespace

int
main ()
{
  try
    {
      mpfrxx::set_default_precision_bits (128);
      for (int driver = 0; driver < 3; ++driver)
        {
          const char *name = driver == 0 ? "Rgelsy" : driver == 1 ? "Rgelss" : "Rgelsd";
          run_driver (driver, name, 1024);
          run_driver (driver, name, 512);
          run_underdetermined (driver, name, 1024);
          run_driver (driver, name, 2048);
          run_underdetermined (driver, name, 2048);
          run_rank_canary (driver, name, 512);
          run_rank_canary (driver, name, 1024);
        }
      if (mpfrxx::default_precision_bits () != 128)
        throw std::runtime_error ("ambient precision was not restored");
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
  std::cout << "PASS: rank-revealing MPLAPACK MPFR driver comparison probe\n";
  return 0;
}
