// SPDX-License-Identifier: BSD-2-Clause

#include <cmath>
#include <complex>
#include <iostream>
#include <stdexcept>
#include <vector>

#include "mp_complex_qr.h"

namespace
{

using Matrix = octave_mplapack::MpfrComplexMatrixStorage;
using Integer = Matrix::MplapackInteger;
using Real = mpfrxx::mpfr_class;

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
check_reconstruction (const Matrix& input,
                      const octave_mplapack::MpcPivotedQrResult& result,
                      const char *message)
{
  const double tolerance = 1.0e-10;
  check (result.permutation.size () == input.columns (), message);
  for (std::size_t column = 0; column < input.columns (); ++column)
    {
      const Integer pivot = result.permutation[column];
      check (pivot >= 1
               && pivot <= static_cast<Integer> (input.columns ()),
             message);
      const std::size_t source = static_cast<std::size_t> (pivot - 1);
      for (std::size_t row = 0; row < input.rows (); ++row)
        {
          std::complex<double> sum {0.0, 0.0};
          for (std::size_t inner = 0; inner < result.q.columns (); ++inner)
            sum += as_double (result.q, row, inner)
                   * as_double (result.r, inner, column);
          check (std::abs (sum - as_double (input, row, source)) < tolerance,
                 message);
        }
    }
}

void
check_permutation (const std::vector<Integer>& permutation,
                   const char *message)
{
  std::vector<bool> seen (permutation.size (), false);
  for (const Integer value : permutation)
    {
      check (value >= 1
               && value <= static_cast<Integer> (permutation.size ()),
             message);
      const std::size_t index = static_cast<std::size_t> (value - 1);
      check (! seen[index], message);
      seen[index] = true;
    }
}

void
check_r_structure (const Matrix& r, const char *message)
{
  for (std::size_t column = 0; column < r.columns (); ++column)
    for (std::size_t row = column + 1; row < r.rows (); ++row)
      check (mpfr_zero_p (mpc_realref (r.at (row, column).mpc_data ())) != 0
               && mpfr_zero_p (mpc_imagref (r.at (row, column).mpc_data ())) != 0,
             message);
}

void
test_full_economy_and_permutation ()
{
  const Matrix input (3, 3, 512,
                      std::vector<std::complex<double>> {
                        {1.0, 1.0}, {2.0, 0.0}, {0.0, 1.0},
                        {2.0, -1.0}, {1.0, 2.0}, {1.0, 0.0},
                        {0.0, 1.0}, {1.0, -2.0}, {3.0, 1.0}});
  const Matrix before (input);
  const auto full
    = octave_mplapack::mplapack_mpc_matrix_pivoted_qr (input, false, true);
  check (full.q.rows () == 3 && full.q.columns () == 3
           && full.r.rows () == 3 && full.r.columns () == 3,
         "full pivoted complex QR shape mismatch");
  check_permutation (full.permutation,
                     "full pivoted complex QR permutation mismatch");
  check_orthogonality (full.q,
                       "full pivoted complex QR is not unitary");
  check_reconstruction (input, full,
                        "full pivoted complex QR reconstruction mismatch");
  check_r_structure (full.r,
                     "full pivoted complex QR R lower entry is not zero");
  check (input.element_exactly_equal (0, 0, before, 0, 0),
         "pivoted complex QR modified its input");

  const Matrix tall (4, 3, 512,
                    std::vector<std::complex<double>> {
                      {1.0, 1.0}, {2.0, 0.0}, {0.0, 1.0}, {1.0, -1.0},
                      {2.0, -1.0}, {1.0, 2.0}, {1.0, 0.0}, {0.0, 2.0},
                      {0.0, 1.0}, {1.0, -2.0}, {3.0, 1.0}, {2.0, 0.0}});
  const auto economy
    = octave_mplapack::mplapack_mpc_matrix_pivoted_qr (tall, true, true);
  check (economy.q.rows () == 4 && economy.q.columns () == 3
           && economy.r.rows () == 3 && economy.r.columns () == 3,
         "economy pivoted complex QR shape mismatch");
  check_permutation (economy.permutation,
                     "economy pivoted complex QR permutation mismatch");
  check_orthogonality (economy.q,
                       "economy pivoted complex QR is not unitary");
  check_reconstruction (tall, economy,
                        "economy pivoted complex QR reconstruction mismatch");

  const Matrix wide (2, 4, 512,
                     std::vector<std::complex<double>> {
                       {1.0, 1.0}, {2.0, 0.0}, {0.0, 1.0}, {1.0, -1.0},
                       {2.0, -1.0}, {1.0, 2.0}, {1.0, 0.0}, {0.0, 2.0}});
  const auto wide_result
    = octave_mplapack::mplapack_mpc_matrix_pivoted_qr (wide, false, true);
  check (wide_result.q.rows () == 2 && wide_result.q.columns () == 2
           && wide_result.r.rows () == 2 && wide_result.r.columns () == 4,
         "wide pivoted complex QR shape mismatch");
  check_permutation (wide_result.permutation,
                     "wide pivoted complex QR permutation mismatch");
  check_orthogonality (wide_result.q,
                       "wide pivoted complex QR is not unitary");
  check_reconstruction (wide, wide_result,
                        "wide pivoted complex QR reconstruction mismatch");
}

void
test_precision_pivot_and_ambient_scope ()
{
  mpfrxx::set_default_precision_bits (128);
  for (const mpfr_prec_t precision : {mpfr_prec_t (1024), mpfr_prec_t (2048)})
    {
      Matrix input (1, 2, precision);
      mpfr_set_ui (mpc_realref (input.at (0, 0).mpc_data ()), 1, MPFR_RNDN);
      mpfr_set_zero (mpc_imagref (input.at (0, 0).mpc_data ()), 0);
      mpfr_set_ui (mpc_realref (input.at (0, 1).mpc_data ()), 1, MPFR_RNDN);
      mpfr_set_zero (mpc_imagref (input.at (0, 1).mpc_data ()), 0);
      Real delta = Real::with_precision (precision);
      mpfr_set_ui_2exp (delta.mpfr_data (), 1, -1500, MPFR_RNDN);
      mpfr_add (mpc_realref (input.at (0, 1).mpc_data ()),
                mpc_realref (input.at (0, 1).mpc_data ()),
                delta.mpfr_data (), MPFR_RNDN);

      const auto result
        = octave_mplapack::mplapack_mpc_matrix_pivoted_qr (input, false, true);
      check_permutation (result.permutation,
                         "precision pivot returned an invalid permutation");
      const Integer expected_first = precision == 1024 ? 1 : 2;
      check (result.permutation.front () == expected_first,
             "precision-sensitive complex pivot order mismatch");
      check (result.q.precision_bits () == precision
               && result.r.precision_bits () == precision
               && result.q.all_elements_have_uniform_precision ()
               && result.r.all_elements_have_uniform_precision (),
             "pivoted complex QR precision metadata mismatch");
      check (mpfrxx::default_precision_bits () == 128,
             "pivoted complex QR changed ambient precision");

      if (precision == 2048)
        {
          Real expected = Real::with_precision (precision);
          mpfr_set_ui (expected.mpfr_data (), 1, MPFR_RNDN);
          mpfr_add (expected.mpfr_data (), expected.mpfr_data (),
                    delta.mpfr_data (), MPFR_RNDN);
          Real absolute_factor = Real::with_precision (precision);
          mpfr_abs (absolute_factor.mpfr_data (),
                    mpc_realref (result.r.at (0, 0).mpc_data ()), MPFR_RNDN);
          check (mpfr_cmp (absolute_factor.mpfr_data (), expected.mpfr_data ())
                   == 0,
                 "2048-bit pivoted complex QR tail was not preserved");
        }
    }
}

void
test_empty_shapes ()
{
  const Matrix empty_rows (0, 3, 512);
  const auto rows_result
    = octave_mplapack::mplapack_mpc_matrix_pivoted_qr (
        empty_rows, false, true);
  check (rows_result.q.rows () == 0 && rows_result.q.columns () == 0
           && rows_result.r.rows () == 0 && rows_result.r.columns () == 3,
         "empty-row pivoted complex QR shape mismatch");
  check (rows_result.permutation == std::vector<Integer> {1, 2, 3},
         "empty-row pivoted complex QR permutation mismatch");

  const Matrix empty_columns (3, 0, 512);
  const auto columns_result
    = octave_mplapack::mplapack_mpc_matrix_pivoted_qr (
        empty_columns, true, true);
  check (columns_result.q.rows () == 3 && columns_result.q.columns () == 0
           && columns_result.r.rows () == 0 && columns_result.r.columns () == 0
           && columns_result.permutation.empty (),
         "empty-column pivoted complex QR shape mismatch");
}

} // namespace

int
main ()
{
  try
    {
      test_full_economy_and_permutation ();
      test_precision_pivot_and_ambient_scope ();
      test_empty_shapes ();
      std::cout << "PASS: complex Cgeqp3/Cungqr pivoted QR full, economy, wide, permutation, reconstruction, orthogonality, precision, ambient scope, shapes, and immutability\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
