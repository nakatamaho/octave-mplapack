// SPDX-License-Identifier: BSD-2-Clause

#include "mp_lapack.h"

#include <cmath>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

namespace
{

using octave_mplapack::MpfrMatrixStorage;
using Real = mpfrxx::mpfr_class;

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

MpfrMatrixStorage
make_qr_system (mpfr_prec_t precision, mpfr_exp_t exponent)
{
  MpfrMatrixStorage b (3, 1, precision);
  Real t = Real::with_precision (precision);
  mpfr_set_ui_2exp (t.mpfr_data (), 1, exponent, MPFR_RNDN);
  mpfr_set (b.at (0, 0).mpfr_data (), t.mpfr_data (), MPFR_RNDN);
  mpfr_set_ui (b.at (1, 0).mpfr_data (), 1, MPFR_RNDN);
  mpfr_sub (b.at (1, 0).mpfr_data (), b.at (1, 0).mpfr_data (),
            t.mpfr_data (), MPFR_RNDN);
  mpfr_set_ui (b.at (2, 0).mpfr_data (), 4, MPFR_RNDN);
  return b;
}

MpfrMatrixStorage
make_qr_matrix (mpfr_prec_t precision)
{
  return MpfrMatrixStorage (3, 2, precision,
                            std::vector<std::string> {"1", "0", "1",
                                                       "0", "1", "1"});
}

MpfrMatrixStorage
make_lq_matrix (mpfr_prec_t precision)
{
  return MpfrMatrixStorage (2, 3, precision,
                            std::vector<std::string> {"1", "0", "0",
                                                       "1", "1", "1"});
}

MpfrMatrixStorage
make_lq_system (mpfr_prec_t precision, mpfr_exp_t exponent)
{
  MpfrMatrixStorage b (2, 1, precision);
  Real t = Real::with_precision (precision);
  mpfr_set_ui_2exp (t.mpfr_data (), 1, exponent, MPFR_RNDN);
  mpfr_set_ui (b.at (0, 0).mpfr_data (), 3, MPFR_RNDN);
  Real three_t = Real::with_precision (precision);
  mpfr_mul_ui (three_t.mpfr_data (), t.mpfr_data (), 3, MPFR_RNDN);
  mpfr_add (b.at (0, 0).mpfr_data (), b.at (0, 0).mpfr_data (),
            three_t.mpfr_data (), MPFR_RNDN);
  mpfr_set_ui (b.at (1, 0).mpfr_data (), 3, MPFR_RNDN);
  return b;
}

void
check_tail (const Real& value, unsigned long base, long exponent,
            const char *message)
{
  Real one = Real::with_precision (value.precision ());
  mpfr_set_ui (one.mpfr_data (), base, MPFR_RNDN);
  Real difference = Real::with_precision (value.precision ());
  mpfr_sub (difference.mpfr_data (), value.mpfr_data (), one.mpfr_data (),
            MPFR_RNDN);
  check (mpfr_zero_p (difference.mpfr_data ()) == 0, message);
  const mpfr_exp_t observed = mpfr_get_exp (difference.mpfr_data ());
  check (std::abs (observed - static_cast<mpfr_exp_t> (exponent)) <= 3,
         message);
}

void
test_qr_and_lq (mpfr_prec_t precision, mpfr_exp_t exponent)
{
  mpfrxx::set_default_precision_bits (128);
  const auto qr_a = make_qr_matrix (precision);
  const auto qr_b = make_qr_system (precision, exponent);
  const auto qr_x
    = octave_mplapack::mplapack_mpfr_matrix_rectangular_solve (qr_a, qr_b);
  check (qr_x.rows () == 2 && qr_x.columns () == 1,
         "overdetermined shape mismatch");
  check (qr_x.precision_bits () == precision,
         "overdetermined precision mismatch");
  check_tail (qr_x.at (0, 0), 1, exponent, "overdetermined first tail lost");
  check_tail (qr_x.at (1, 0), 2, exponent, "overdetermined second tail lost");
  check (mpfrxx::default_precision_bits () == 128,
         "overdetermined scope leaked");

  const auto lq_a = make_lq_matrix (precision);
  const auto lq_b = make_lq_system (precision, exponent);
  const auto lq_x
    = octave_mplapack::mplapack_mpfr_matrix_rectangular_solve (lq_a, lq_b);
  check (lq_x.rows () == 3 && lq_x.columns () == 1,
         "underdetermined shape mismatch");
  check (lq_x.precision_bits () == precision,
         "underdetermined precision mismatch");
  check_tail (lq_x.at (0, 0), 1, exponent, "underdetermined first tail lost");
  check_tail (lq_x.at (1, 0), 1, exponent, "underdetermined second tail lost");
  check_tail (lq_x.at (2, 0), 2, exponent, "underdetermined third tail lost");
  check (mpfrxx::default_precision_bits () == 128,
         "underdetermined scope leaked");
}

void
test_mixed_precision ()
{
  const auto a = make_qr_matrix (256);
  const auto b = make_qr_system (1024, -700);
  const auto x
    = octave_mplapack::mplapack_mpfr_matrix_rectangular_solve (a, b);
  check (x.precision_bits () == 1024, "mixed rectangular precision mismatch");
  const auto reverse
    = octave_mplapack::mplapack_mpfr_matrix_rectangular_solve (
        make_qr_matrix (1024), make_qr_system (256, -100));
  check (reverse.precision_bits () == 1024,
         "reverse mixed rectangular precision mismatch");
}

void
test_empty ()
{
  const MpfrMatrixStorage a (2, 0, 256);
  const MpfrMatrixStorage b (2, 3, 1024);
  const auto x
    = octave_mplapack::mplapack_mpfr_matrix_rectangular_solve (a, b);
  check (x.rows () == 0 && x.columns () == 3 && x.precision_bits () == 1024,
         "empty Mx0 shape/precision mismatch");
  const MpfrMatrixStorage a0 (0, 2, 256);
  const MpfrMatrixStorage b0 (0, 1, 256);
  const auto x0
    = octave_mplapack::mplapack_mpfr_matrix_rectangular_solve (a0, b0);
  check (x0.rows () == 2 && x0.columns () == 1,
         "empty 0xN shape mismatch");
  check (mpfr_zero_p (x0.at (0, 0).mpfr_data ()) != 0
         && mpfr_zero_p (x0.at (1, 0).mpfr_data ()) != 0,
         "empty 0xN solution not zero");
}

} // namespace

int
main ()
{
  try
    {
      test_qr_and_lq (1024, -700);
      test_qr_and_lq (2048, -1500);
      test_mixed_precision ();
      test_empty ();
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
  std::cout << "PASS: MPLAPACK MPFR Rgels rectangular solve tests\n";
  return 0;
}
