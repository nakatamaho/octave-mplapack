// SPDX-License-Identifier: BSD-2-Clause

#include <array>
#include <cmath>
#include <complex>
#include <iostream>
#include <stdexcept>
#include <vector>

#include "mp_complex_cholesky.h"

namespace
{

using Matrix = octave_mplapack::MpfrComplexMatrixStorage;
using Real = mpfrxx::mpfr_class;

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

void
set_power_of_two_real (mpc_ptr value, long exponent)
{
  mpfr_set_ui_2exp (mpc_realref (value), 1, exponent, MPFR_RNDN);
  mpfr_set_zero (mpc_imagref (value), 0);
}

void
check_close (const Matrix& matrix, std::size_t row, std::size_t column,
             std::complex<double> expected, const char *message)
{
  const std::complex<double> actual
    = octave_mplapack::MpfrComplexScalarStorage (
        matrix.at (row, column)).to_double ();
  check (std::abs (actual - expected) < 1.0e-12, message);
}

void
test_triangle_selection ()
{
  const Matrix upper_input (2, 2, 1024,
                            std::vector<std::complex<double>> {
                              {4.0, 9.0}, {777.0, 888.0},
                              {2.0, 1.0}, {10.0, -7.0}});
  const Matrix upper_before = upper_input;
  const auto upper
    = octave_mplapack::mplapack_mpc_matrix_cholesky (upper_input, false);
  check (upper.info == 0 && upper.factor.rows () == 2
         && upper.factor.columns () == 2
         && upper.factor.precision_bits () == 1024,
         "upper complex Cholesky metadata mismatch");
  check_close (upper.factor, 0, 0, {2.0, 0.0},
               "upper complex Cholesky first diagonal mismatch");
  check_close (upper.factor, 0, 1, {1.0, 0.5},
               "upper complex Cholesky off-diagonal mismatch");
  check_close (upper.factor, 1, 1, {std::sqrt (8.75), 0.0},
               "upper complex Cholesky second diagonal mismatch");
  check (mpfr_zero_p (mpc_imagref (upper.factor.at (1, 0).mpc_data ())) != 0,
         "upper complex Cholesky lower triangle was not cleared");
  check (upper_input.element_exactly_equal (0, 0, upper_before, 0, 0)
         && upper_input.element_exactly_equal (1, 0, upper_before, 1, 0),
         "upper complex Cholesky modified input");

  const Matrix lower_input (2, 2, 1024,
                            std::vector<std::complex<double>> {
                              {4.0, 9.0}, {2.0, -1.0},
                              {777.0, 888.0}, {10.0, -7.0}});
  const auto lower
    = octave_mplapack::mplapack_mpc_matrix_cholesky (lower_input, true);
  check (lower.info == 0 && lower.factor.rows () == 2
         && lower.factor.columns () == 2,
         "lower complex Cholesky metadata mismatch");
  check_close (lower.factor, 0, 0, {2.0, 0.0},
               "lower complex Cholesky first diagonal mismatch");
  check_close (lower.factor, 1, 0, {1.0, -0.5},
               "lower complex Cholesky off-diagonal mismatch");
  check_close (lower.factor, 1, 1, {std::sqrt (8.75), 0.0},
               "lower complex Cholesky second diagonal mismatch");
  check (mpfr_zero_p (mpc_imagref (lower.factor.at (0, 1).mpc_data ())) != 0,
         "lower complex Cholesky upper triangle was not cleared");
}

void
test_precision_and_ambient ()
{
  mpfrxx::set_default_precision_bits (128);
  for (const auto setting : {std::array<long, 2> {{1024, -700}},
                             std::array<long, 2> {{2048, -1500}}})
    {
      const mpfr_prec_t precision = static_cast<mpfr_prec_t> (setting[0]);
      Matrix input (2, 2, precision);
      set_power_of_two_real (input.at (0, 0).mpc_data (), 0);
      set_power_of_two_real (input.at (0, 1).mpc_data (), 0);
      set_power_of_two_real (input.at (1, 0).mpc_data (), 0);
      Real delta = Real::with_precision (precision);
      mpfr_set_ui_2exp (delta.mpfr_data (), 1, setting[1], MPFR_RNDN);
      mpfr_add (mpc_realref (input.at (1, 1).mpc_data ()),
                mpc_realref (input.at (0, 0).mpc_data ()),
                delta.mpfr_data (), MPFR_RNDN);
      mpfr_set_zero (mpc_imagref (input.at (1, 1).mpc_data ()), 0);

      const auto result
        = octave_mplapack::mplapack_mpc_matrix_cholesky (input, false);
      check (result.info == 0 && result.factor.precision_bits () == precision
             && result.factor.all_elements_have_uniform_precision (),
             "complex Cholesky precision metadata mismatch");
      Real expected = Real::with_precision (precision);
      mpfr_set_ui_2exp (expected.mpfr_data (), 1, setting[1] / 2,
                        MPFR_RNDN);
      check (mpfr_equal_p (mpc_realref (result.factor.at (1, 1).mpc_data ()),
                           expected.mpfr_data ()) != 0,
             "complex Cholesky precision tail mismatch");
      check (mpfr_zero_p (mpc_imagref (result.factor.at (1, 1).mpc_data ()))
               != 0,
             "complex Cholesky diagonal acquired an imaginary part");
      check (mpfrxx::default_precision_bits () == 128,
             "complex Cholesky changed ambient precision");
    }

  const Matrix empty (0, 0, 2048);
  const auto empty_result
    = octave_mplapack::mplapack_mpc_matrix_cholesky (empty, false);
  check (empty_result.info == 0 && empty_result.factor.rows () == 0
         && empty_result.factor.columns () == 0
         && empty_result.factor.precision_bits () == 2048,
         "empty complex Cholesky shape mismatch");
}

void
test_nonpositive_and_shapes ()
{
  const Matrix semidefinite (2, 2, 512,
                             std::vector<std::complex<double>> {
                               {1.0, 0.0}, {1.0, 0.0},
                               {1.0, 0.0}, {1.0, 0.0}});
  const auto result
    = octave_mplapack::mplapack_mpc_matrix_cholesky (semidefinite, false);
  check (result.info == 2 && result.factor.rows () == 1
         && result.factor.columns () == 1,
         "complex Cholesky non-PD status mismatch");
  check_close (result.factor, 0, 0, {1.0, 0.0},
               "complex Cholesky partial factor mismatch");

  const Matrix nonsquare (2, 1, 256);
  bool rejected = false;
  try
    {
      octave_mplapack::mplapack_mpc_matrix_cholesky (nonsquare, false);
    }
  catch (const std::invalid_argument&)
    { rejected = true; }
  check (rejected, "complex Cholesky accepted a non-square matrix");
}

} // namespace

int
main ()
{
  try
    {
      test_triangle_selection ();
      test_precision_and_ambient ();
      test_nonpositive_and_shapes ();
      std::cout << "PASS: complex Cpotrf selected-triangle Hermitian Cholesky, diagonal behavior, non-PD status, precision, ambient scope, shapes, and immutability\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
