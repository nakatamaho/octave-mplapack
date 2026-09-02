// SPDX-License-Identifier: BSD-2-Clause

#include "mp_lapack.h"

#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

namespace
{
using octave_mplapack::MpfrMatrixStorage;
using octave_mplapack::MpfrPivotedQrResult;
using Real = mpfrxx::mpfr_class;

void check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

MpfrMatrixStorage matrix (std::size_t rows, std::size_t columns,
                          mpfr_prec_t precision,
                          std::initializer_list<const char*> values)
{
  return MpfrMatrixStorage (rows, columns, precision,
                            std::vector<std::string> (values.begin (),
                                                      values.end ()));
}

void check_close (const Real& value, const Real& expected,
                  mpfr_prec_t precision, const char *message)
{
  Real difference = Real::with_precision (precision);
  mpfr_sub (difference.mpfr_data (), value.mpfr_data (), expected.mpfr_data (),
            MPFR_RNDN);
  mpfr_abs (difference.mpfr_data (), difference.mpfr_data (), MPFR_RNDN);
  Real tolerance = Real::with_precision (precision);
  mpfr_set_ui_2exp (tolerance.mpfr_data (), 1,
                    -static_cast<mpfr_exp_t> (precision / 2), MPFR_RNDN);
  check (mpfr_cmp (difference.mpfr_data (), tolerance.mpfr_data ()) < 0,
         message);
}

void check_reconstruction (const MpfrPivotedQrResult& result,
                           const MpfrMatrixStorage& input,
                           const char *message)
{
  const std::size_t m = input.rows ();
  const std::size_t n = input.columns ();
  const std::size_t q_columns = result.q.columns ();
  const mpfr_prec_t precision = input.precision_bits ();
  for (std::size_t column = 0; column < n; ++column)
    for (std::size_t row = 0; row < m; ++row)
      {
        Real reconstructed = Real::with_precision (precision);
        mpfr_set_zero (reconstructed.mpfr_data (), 0);
        for (std::size_t inner = 0; inner < q_columns; ++inner)
          {
            Real product = Real::with_precision (precision);
            mpfr_mul (product.mpfr_data (),
                      result.q.at (row, inner).mpfr_data (),
                      result.r.at (inner, column).mpfr_data (), MPFR_RNDN);
            mpfr_add (reconstructed.mpfr_data (), reconstructed.mpfr_data (),
                      product.mpfr_data (), MPFR_RNDN);
          }
        const std::size_t source
          = static_cast<std::size_t> (result.permutation[column] - 1);
        check_close (reconstructed, input.at (row, source), precision, message);
      }
}

void check_orthogonality (const MpfrPivotedQrResult& result,
                          const char *message)
{
  const std::size_t rows = result.q.rows ();
  const std::size_t columns = result.q.columns ();
  const mpfr_prec_t precision = result.q.precision_bits ();
  for (std::size_t column = 0; column < columns; ++column)
    for (std::size_t row = 0; row < columns; ++row)
      {
        Real value = Real::with_precision (precision);
        mpfr_set_zero (value.mpfr_data (), 0);
        for (std::size_t inner = 0; inner < rows; ++inner)
          {
            Real product = Real::with_precision (precision);
            mpfr_mul (product.mpfr_data (),
                      result.q.at (inner, row).mpfr_data (),
                      result.q.at (inner, column).mpfr_data (), MPFR_RNDN);
            mpfr_add (value.mpfr_data (), value.mpfr_data (), product.mpfr_data (),
                      MPFR_RNDN);
          }
        Real expected = Real::with_precision (precision);
        mpfr_set_ui (expected.mpfr_data (), row == column ? 1 : 0, MPFR_RNDN);
        check_close (value, expected, precision, message);
      }
}

void check_permutation (const MpfrPivotedQrResult& result,
                        std::initializer_list<MpfrMatrixStorage::MplapackInteger> expected,
                        const char *message)
{
  check (result.permutation.size () == expected.size (), message);
  std::size_t index = 0;
  for (const auto value : expected)
    check (result.permutation[index++] == value, message);
}

void test_deterministic_pivot ()
{
  const auto input = matrix (3, 3, 256,
                            {"1", "0", "0", "0", "4", "0", "0", "0", "2"});
  const auto full
    = octave_mplapack::mplapack_mpfr_matrix_pivoted_qr (input, false, true);
  check_permutation (full, {2, 3, 1}, "deterministic pivot mismatch");
  check (full.q.rows () == 3 && full.q.columns () == 3
         && full.r.rows () == 3 && full.r.columns () == 3,
         "pivoted square shape mismatch");
  check_reconstruction (full, input, "pivoted reconstruction mismatch");
  check_orthogonality (full, "pivoted orthogonality mismatch");

  const auto tall = matrix (4, 3, 256,
                            {"1", "0", "0", "0", "0", "5", "0", "0",
                             "0", "0", "2", "0"});
  const auto economy
    = octave_mplapack::mplapack_mpfr_matrix_pivoted_qr (tall, true, true);
  check_permutation (economy, {2, 3, 1}, "tall pivot mismatch");
  check (economy.q.rows () == 4 && economy.q.columns () == 3
         && economy.r.rows () == 3 && economy.r.columns () == 3,
         "pivoted economy shape mismatch");
  check_reconstruction (economy, tall, "pivoted economy reconstruction mismatch");
  check_orthogonality (economy, "pivoted economy orthogonality mismatch");

  const auto wide = matrix (2, 4, 256,
                            {"1", "0", "0", "4", "0", "2", "0", "0"});
  const auto wide_result
    = octave_mplapack::mplapack_mpfr_matrix_pivoted_qr (wide, false, true);
  check (wide_result.q.rows () == 2 && wide_result.q.columns () == 2
         && wide_result.r.rows () == 2 && wide_result.r.columns () == 4,
         "wide pivoted shape mismatch");
  check_reconstruction (wide_result, wide, "wide pivoted reconstruction mismatch");
  check_orthogonality (wide_result, "wide pivoted orthogonality mismatch");
}

void test_precision_and_immutability ()
{
  mpfrxx::set_default_precision_bits (128);
  auto input = matrix (1, 2, 1024, {"1", "1"});
  Real tail = Real::with_precision (1024);
  mpfr_set_ui_2exp (tail.mpfr_data (), 1, -700, MPFR_RNDN);
  mpfr_add (input.at (0, 1).mpfr_data (), input.at (0, 1).mpfr_data (),
            tail.mpfr_data (), MPFR_RNDN);
  const auto before = input;
  const auto result
    = octave_mplapack::mplapack_mpfr_matrix_pivoted_qr (input, false, true);
  check_permutation (result, {2, 1}, "precision pivot order mismatch");
  check (result.q.precision_bits () == 1024
         && result.r.precision_bits () == 1024,
         "pivoted precision metadata mismatch");
  check (input.element_exactly_equal (0, 1, before, 0, 1),
         "pivoted QR mutated input");
  check_reconstruction (result, input, "precision pivot reconstruction mismatch");
  check_orthogonality (result, "precision pivot orthogonality mismatch");
  check (mpfrxx::default_precision_bits () == 128,
         "pivoted QR leaked ambient precision");

  mpfrxx::set_default_precision_bits (4096);
  const auto high_ambient_input = matrix (2, 2, 256,
                                           {"1", "0", "0", "2"});
  const auto high_ambient
    = octave_mplapack::mplapack_mpfr_matrix_pivoted_qr (
        high_ambient_input, false, true);
  check (high_ambient.q.precision_bits () == 256
         && high_ambient.r.precision_bits () == 256,
         "high ambient pivoted QR widened result");
  check (mpfrxx::default_precision_bits () == 4096,
         "high ambient pivoted QR changed ambient precision");

  mpfrxx::set_default_precision_bits (128);
  auto high_precision_input = matrix (1, 2, 2048, {"1", "1"});
  Real high_precision_tail = Real::with_precision (2048);
  mpfr_set_ui_2exp (high_precision_tail.mpfr_data (), 1, -1500, MPFR_RNDN);
  mpfr_add (high_precision_input.at (0, 1).mpfr_data (),
            high_precision_input.at (0, 1).mpfr_data (),
            high_precision_tail.mpfr_data (), MPFR_RNDN);
  const auto high_precision
    = octave_mplapack::mplapack_mpfr_matrix_pivoted_qr (
        high_precision_input, false, true);
  check_permutation (high_precision, {2, 1},
                     "2048-bit precision pivot order mismatch");
  Real expected = Real::with_precision (2048);
  mpfr_set_ui (expected.mpfr_data (), 1, MPFR_RNDN);
  mpfr_add (expected.mpfr_data (), expected.mpfr_data (),
            high_precision_tail.mpfr_data (), MPFR_RNDN);
  Real absolute_factor = Real::with_precision (2048);
  mpfr_abs (absolute_factor.mpfr_data (),
            high_precision.r.at (0, 0).mpfr_data (), MPFR_RNDN);
  check (mpfr_cmp (absolute_factor.mpfr_data (), expected.mpfr_data ()) == 0,
         "2048-bit pivoted QR tail was not preserved");
  check (high_precision.q.precision_bits () == 2048
         && high_precision.r.precision_bits () == 2048,
         "2048-bit pivoted QR precision metadata mismatch");
  check (mpfrxx::default_precision_bits () == 128,
         "2048-bit pivoted QR changed ambient precision");
}

void test_empty ()
{
  const auto empty = matrix (0, 3, 512, {});
  const auto result
    = octave_mplapack::mplapack_mpfr_matrix_pivoted_qr (empty, false, true);
  check (result.q.rows () == 0 && result.q.columns () == 0
         && result.r.rows () == 0 && result.r.columns () == 3,
         "empty pivoted QR shape mismatch");
  check_permutation (result, {1, 2, 3}, "empty pivoted permutation mismatch");
  const auto no_columns = matrix (3, 0, 512, {});
  const auto econ
    = octave_mplapack::mplapack_mpfr_matrix_pivoted_qr (
        no_columns, true, true);
  check (econ.q.rows () == 3 && econ.q.columns () == 0
         && econ.r.rows () == 0 && econ.r.columns () == 0,
         "empty economy pivoted QR shape mismatch");
  check (econ.permutation.empty (), "empty pivoted vector mismatch");
}

} // namespace

int main ()
{
  try
    {
      test_deterministic_pivot ();
      test_precision_and_immutability ();
      test_empty ();
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
  std::cout << "PASS: native pivoted QR tests\n";
  return 0;
}
