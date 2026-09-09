// SPDX-License-Identifier: BSD-2-Clause

#include <array>
#include <cmath>
#include <complex>
#include <iostream>
#include <stdexcept>
#include <vector>

#include "mp_complex_qr.h"

namespace
{

using Matrix = octave_mplapack::MpfrComplexMatrixStorage;

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

std::complex<double>
as_double (const Matrix& matrix, std::size_t row, std::size_t column)
{
  return octave_mplapack::MpfrComplexScalarStorage (
    matrix.at (row, column)).to_double ();
}

void
check_zero (const Matrix& matrix, std::size_t row, std::size_t column,
            const char *message)
{
  check (mpfr_zero_p (mpc_realref (matrix.at (row, column).mpc_data ())) != 0
         && mpfr_zero_p (mpc_imagref (matrix.at (row, column).mpc_data ())) != 0,
         message);
}

void
check_orthogonality (const Matrix& q, const char *message)
{
  const double tolerance = 1.0e-10;
  for (std::size_t first = 0; first < q.columns (); ++first)
    for (std::size_t second = 0; second < q.columns (); ++second)
      {
        std::complex<double> sum {0.0, 0.0};
        for (std::size_t row = 0; row < q.rows (); ++row)
          sum += std::conj (as_double (q, row, first))
                 * as_double (q, row, second);
        const std::complex<double> expected
          = first == second ? std::complex<double> {1.0, 0.0}
                            : std::complex<double> {0.0, 0.0};
        check (std::abs (sum - expected) < tolerance, message);
      }
}

void
check_reconstruction (const Matrix& input, const Matrix& q, const Matrix& r,
                      const char *message)
{
  const double tolerance = 1.0e-10;
  for (std::size_t column = 0; column < input.columns (); ++column)
    for (std::size_t row = 0; row < input.rows (); ++row)
      {
        std::complex<double> sum {0.0, 0.0};
        for (std::size_t inner = 0; inner < q.columns (); ++inner)
          sum += as_double (q, row, inner) * as_double (r, inner, column);
        check (std::abs (sum - as_double (input, row, column)) < tolerance,
               message);
      }
}

void
test_full_economy_and_one_output ()
{
  const Matrix input (3, 2, 512,
                      std::vector<std::complex<double>> {
                        {1.0, 1.0}, {2.0, 0.0}, {0.0, 1.0},
                        {2.0, -1.0}, {1.0, 2.0}, {1.0, 0.0}});
  const auto before = input;
  const auto full
    = octave_mplapack::mplapack_mpc_matrix_qr (input, false, true);
  check (full.q.rows () == 3 && full.q.columns () == 3
         && full.r.rows () == 3 && full.r.columns () == 2,
         "full complex QR shape mismatch");
  check_orthogonality (full.q, "full complex QR is not unitary");
  check_reconstruction (input, full.q, full.r,
                        "full complex QR reconstruction mismatch");
  check_zero (full.r, 1, 0, "full complex QR R lower entry is not zero");
  check_zero (full.r, 2, 0, "full complex QR R lower entry is not zero");
  check_zero (full.r, 2, 1, "full complex QR R lower entry is not zero");
  check (input.element_exactly_equal (0, 0, before, 0, 0),
         "complex QR modified its input");

  const auto economy
    = octave_mplapack::mplapack_mpc_matrix_qr (input, true, true);
  check (economy.q.rows () == 3 && economy.q.columns () == 2
         && economy.r.rows () == 2 && economy.r.columns () == 2,
         "economy complex QR shape mismatch");
  check_orthogonality (economy.q, "economy complex QR is not unitary");
  check_reconstruction (input, economy.q, economy.r,
                        "economy complex QR reconstruction mismatch");
  check_zero (economy.r, 1, 0,
              "economy complex QR R lower entry is not zero");

  const auto one_output
    = octave_mplapack::mplapack_mpc_matrix_qr (input, false, false);
  check (one_output.q.rows () == 0 && one_output.q.columns () == 0
         && one_output.r.rows () == 3 && one_output.r.columns () == 2,
         "one-output complex QR constructed Q");
}

void
test_precision_and_empty ()
{
  mpfrxx::set_default_precision_bits (128);
  for (const auto setting : {std::array<mpfr_prec_t, 2> {{1024, 700}},
                             std::array<mpfr_prec_t, 2> {{2048, 1500}}})
    {
      const mpfr_prec_t precision = setting[0];
      Matrix input (2, 2, precision);
      mpfr_set_ui (mpc_realref (input.at (0, 0).mpc_data ()), 1, MPFR_RNDN);
      mpfr_set_zero (mpc_imagref (input.at (0, 0).mpc_data ()), 0);
      mpfr_set_zero (mpc_realref (input.at (1, 0).mpc_data ()), 0);
      mpfr_set_zero (mpc_imagref (input.at (1, 0).mpc_data ()), 0);
      mpfr_set_ui_2exp (mpc_realref (input.at (0, 1).mpc_data ()), 1,
                        -static_cast<long> (setting[1]), MPFR_RNDN);
      mpfr_set_ui_2exp (mpc_imagref (input.at (0, 1).mpc_data ()), 1,
                        -static_cast<long> (setting[1]), MPFR_RNDN);
      mpfr_set_ui (mpc_realref (input.at (1, 1).mpc_data ()), 1, MPFR_RNDN);
      mpfr_set_zero (mpc_imagref (input.at (1, 1).mpc_data ()), 0);

      const auto result
        = octave_mplapack::mplapack_mpc_matrix_qr (input, true, true);
      check (result.q.precision_bits () == precision
             && result.r.precision_bits () == precision
             && result.q.all_elements_have_uniform_precision ()
             && result.r.all_elements_have_uniform_precision (),
             "complex QR precision metadata mismatch");
      check (mpfr_equal_p (mpc_realref (result.r.at (0, 1).mpc_data ()),
                           mpc_realref (input.at (0, 1).mpc_data ())) != 0
             && mpfr_equal_p (mpc_imagref (result.r.at (0, 1).mpc_data ()),
                              mpc_imagref (input.at (0, 1).mpc_data ())) != 0,
             "complex QR precision canary changed");
      check (mpfrxx::default_precision_bits () == 128,
             "complex QR changed ambient precision");
    }

  const Matrix empty (0, 3, 2048);
  const auto empty_result
    = octave_mplapack::mplapack_mpc_matrix_qr (empty, false, true);
  check (empty_result.q.rows () == 0 && empty_result.q.columns () == 0
         && empty_result.r.rows () == 0 && empty_result.r.columns () == 3,
         "empty complex QR shape mismatch");
}

} // namespace

int
main ()
{
  try
    {
      test_full_economy_and_one_output ();
      test_precision_and_empty ();
      std::cout << "PASS: complex Cgeqrf/Cungqr full, economy, one-output, workspace, orthogonality, reconstruction, precision, ambient scope, shapes, and immutability\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
